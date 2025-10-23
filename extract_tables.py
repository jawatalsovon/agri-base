# ...existing code...
"""
Memory-safe PDF table extractor (page-by-page streaming):
- Avoids building large combined DataFrames in memory.
- Writes first page of a table with header; appends subsequent pages directly to the CSV.
- Keeps only small per-page DataFrames in memory; handles duplicate column names safely.
- Emits progress prints and flushes to help identify where a termination occurs.
"""
import re
import sys
import gc
from pathlib import Path
from typing import List, Optional

import pdfplumber
import pandas as pd


def sanitize_filename(name: str) -> str:
    name = (name or "").strip()
    name = re.sub(r'\s+', '_', name)
    name = re.sub(r'[^0-9A-Za-z_\-\.]', '', name)
    return name[:120] if len(name) > 120 else (name or "table")


def is_mostly_text(row: List[str]) -> bool:
    non_empty = [c for c in row if str(c).strip() != ""]
    if not non_empty:
        return False
    text_like = 0
    for c in non_empty:
        s = str(c).strip()
        if re.fullmatch(r'[-+]?\d{1,3}(?:[,]\d{3})*(?:\.\d+)?|[-+]?\d+(\.\d+)?', s):
            continue
        text_like += 1
    return (text_like / len(non_empty)) >= 0.6


def row_to_list(row) -> List[str]:
    out = []
    for cell in row:
        if isinstance(cell, dict):
            out.append(cell.get("text", "").strip())
        else:
            out.append(str(cell).strip())
    return out


def title_from_words_above(table_bbox, words, max_above_px=200) -> Optional[str]:
    if not table_bbox:
        return None
    x0, top, x1, bottom = table_bbox
    candidates = [
        w for w in words
        if float(w.get("bottom", 0)) < top and float(w.get("bottom", 0)) > top - max_above_px
    ]
    if not candidates:
        return None
    lines = {}
    for w in candidates:
        key = round(float(w.get("top", 0)), 1)
        lines.setdefault(key, []).append(w.get("text", ""))
    if not lines:
        return None
    best_key = sorted(lines.keys(), reverse=True)[0]
    raw = " ".join(lines[best_key]).strip()
    m = re.search(r'(?:Table\s*\d+\s*[:\-\–]?\s*)?(.*?)(?:\bContd\.?|\bContinued\.?)?$', raw, flags=re.I)
    title = m.group(1).strip() if m else raw
    if len(title) < 3 or re.fullmatch(r'[-\s\.\d]+', title):
        return None
    return title


def normalize_header(header_row: List[str]) -> List[str]:
    return [re.sub(r'\s+', ' ', str(h).strip()) for h in header_row]


def overlap_ratio(h1: List[str], h2: List[str]) -> float:
    s1 = set([c.lower() for c in h1 if c])
    s2 = set([c.lower() for c in h2 if c])
    if not s1 or not s2:
        return 0.0
    return len(s1 & s2) / max(len(s1), len(s2))


def safe_table_extract(table) -> List[List]:
    try:
        rows = table.extract()
        return rows or []
    except Exception:
        try:
            rows = table.extract_table()
            return rows or []
        except Exception:
            return []


def make_unique(cols: List[str]) -> List[str]:
    counts = {}
    out = []
    for c in cols:
        key = c if c is not None else ""
        if key in counts:
            counts[key] += 1
            out.append(f"{key}_{counts[key]}")
        else:
            counts[key] = 0
            out.append(key)
    return out


def extract(pdf_path: str, out_dir: str):
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    last_table = None  # {name, header, last_page, csv_path}
    saved_files = set()
    page_counter = 0

    with pdfplumber.open(pdf_path) as pdf:
        for pnum, page in enumerate(pdf.pages, start=1):
            page_counter += 1
            print(f"[page {pnum}] processing...", flush=True)
            try:
                tables = page.find_tables()
            except Exception as e:
                print(f"[page {pnum}] find_tables failed: {e}", flush=True)
                tables = []
            if not tables:
                # reset last_table if many empty pages to avoid accidental merges
                # (but we keep last_table so contiguous detection still works)
                continue

            try:
                words = page.extract_words()
            except Exception:
                words = []

            for tidx, table in enumerate(tables, start=1):
                rows = safe_table_extract(table)
                if not rows:
                    continue

                norm_rows = [row_to_list(r) for r in rows]
                df = pd.DataFrame(norm_rows)

                if len(df) >= 2 and is_mostly_text(df.iloc[0].tolist()):
                    header = normalize_header(df.iloc[0].tolist())
                    header = make_unique(header)
                    df = df[1:].reset_index(drop=True)
                    df.columns = header
                else:
                    header = make_unique(normalize_header([f"col_{i}" for i in range(len(df.columns))]))
                    df.columns = header

                bbox = getattr(table, "bbox", None)
                title = None
                try:
                    title = title_from_words_above(bbox, words, max_above_px=200)
                except Exception:
                    title = None

                is_continuation = False
                if title is None and last_table:
                    if pnum == last_table["last_page"] + 1:
                        if overlap_ratio(header, last_table["header"]) >= 0.5:
                            is_continuation = True

                if is_continuation:
                    # align and append to existing CSV (streaming append)
                    last_cols = last_table["header"]
                    # ensure last_cols unique
                    last_cols = make_unique(last_cols)
                    try:
                        mapped = []
                        for c in df.columns:
                            matches = [lc for lc in last_cols if lc.lower() == c.lower()]
                            mapped.append(matches[0] if matches else c)
                        df.columns = mapped
                        # reindex safely to target unique columns
                        df = df.reindex(columns=last_cols, fill_value='')
                    except Exception as e:
                        # fallback: make df columns unique and align by position
                        print(f"[page {pnum}] append-align failed ({e}), aligning by position", flush=True)
                        new_cols = make_unique(list(df.columns))
                        df.columns = new_cols
                        # reindex by position: extend/trim to match last_cols length
                        if df.shape[1] < len(last_cols):
                            # add missing columns
                            for i in range(len(last_cols) - df.shape[1]):
                                df[f"_extra_{i}"] = ''
                        df = df.iloc[:, :len(last_cols)]
                        df.columns = last_cols

                    # append rows without header
                    try:
                        df.to_csv(last_table["csv_path"], mode='a', header=False, index=False)
                        last_table["last_page"] = pnum
                        print(f"[page {pnum}] appended to {last_table['csv_path'].name}", flush=True)
                    except Exception as e:
                        print(f"[page {pnum}] append write failed: {e}", flush=True)
                else:
                    name = sanitize_filename(title) if title else f"page{pnum:03d}_table{tidx:02d}"
                    csv_path = out_dir / f"{name}.csv"
                    base = csv_path.stem
                    k = 1
                    while csv_path.exists():
                        csv_path = out_dir / f"{base}_{k}.csv"
                        k += 1
                    try:
                        df.to_csv(csv_path, index=False)
                        print(f"[page {pnum}] saved new table {csv_path.name}", flush=True)
                    except Exception as e:
                        print(f"[page {pnum}] write failed ({e}), retrying with utf-8-sig", flush=True)
                        df.to_csv(csv_path, index=False, encoding="utf-8-sig")
                    saved_files.add(str(csv_path))
                    last_table = {
                        "name": name,
                        "header": list(df.columns),
                        "last_page": pnum,
                        "csv_path": csv_path
                    }

                # free memory of per-page df
                del df
                gc.collect()

    print(f"Done. {len(saved_files)} tables saved to {out_dir}", flush=True)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 extract_tables.py /path/to/Adri_data_2024.pdf /path/to/out_dir")
        sys.exit(1)
    extract(sys.argv[1], sys.argv[2])
# ...existing code...
