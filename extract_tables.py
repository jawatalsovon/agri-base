# ...existing code...
"""
Robust PDF table extractor with fixes for duplicate column labels when merging multi-page tables.
"""
import re
import sys
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


def title_from_words_above(table_bbox, words, max_above_px=160) -> Optional[str]:
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
    """Return a list of unique column names by appending suffixes to duplicates."""
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

    last_table = None  # dict: {name, header, df, last_page, csv_path}
    saved_files = set()

    with pdfplumber.open(pdf_path) as pdf:
        for pnum, page in enumerate(pdf.pages, start=1):
            try:
                tables = page.find_tables()
            except Exception:
                tables = []
            if not tables:
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
                try:
                    title = title_from_words_above(bbox, words, max_above_px=160)
                except Exception:
                    title = None

                # detect continuation of previous table
                is_continuation = False
                if title is None and last_table:
                    if pnum == last_table["last_page"] + 1:
                        if overlap_ratio(header, last_table["header"]) >= 0.55:
                            is_continuation = True

                if is_continuation:
                    combine_df = df.copy()
                    # Ensure last_table df columns are unique
                    last_cols = list(last_table["df"].columns)
                    if len(set(last_cols)) != len(last_cols):
                        new_last_cols = make_unique(last_cols)
                        last_table["df"].columns = new_last_cols
                        last_table["header"] = new_last_cols
                        last_cols = new_last_cols

                    # Align combine_df columns to last_table columns (case-insensitive match)
                    if list(combine_df.columns) != last_cols:
                        mapped_cols = []
                        for c in combine_df.columns:
                            matches = [lc for lc in last_cols if lc.lower() == c.lower()]
                            mapped_cols.append(matches[0] if matches else c)
                        combine_df.columns = mapped_cols
                        # Reindex to last_cols safely (last_cols are unique now)
                        combine_df = combine_df.reindex(columns=last_cols, fill_value='')

                    last_table["df"] = pd.concat([last_table["df"], combine_df], ignore_index=True)
                    last_table["last_page"] = pnum
                    try:
                        last_table["df"].to_csv(last_table["csv_path"], index=False)
                    except Exception:
                        last_table["df"].to_csv(last_table["csv_path"], index=False, encoding="utf-8-sig")
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
                    except Exception:
                        df.to_csv(csv_path, index=False, encoding="utf-8-sig")
                    saved_files.add(str(csv_path))
                    last_table = {
                        "name": name,
                        "header": list(df.columns),
                        "df": df,
                        "last_page": pnum,
                        "csv_path": csv_path
                    }

    print(f"Done. Saved/updated {len(saved_files)} CSV files to {out_dir}")
    # ...existing code...
