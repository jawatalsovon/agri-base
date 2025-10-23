# Improved pdf -> CSV extractor that:
# - uses pdfplumber to detect tables
# - extracts a nearby text line above a table as the table name
# - detects multi-page tables by matching headers + contiguous pages and appends them
# - saves each final table as a CSV named from the detected table title (sanitized)
import re
import sys
from pathlib import Path

def sanitize_filename(name: str) -> str:
    name = name.strip()
    name = re.sub(r'\s+', '_', name)
    name = re.sub(r'[^0-9A-Za-z_\-\.]', '', name)
    return name[:120] if len(name) > 120 else name or "table"

def is_mostly_text(row):
    # Return True if majority of cells are non-numeric (likely a header)
    non_empty = [c for c in row if str(c).strip() != ""]
    if not non_empty:
        return False
    text_like = 0
    for c in non_empty:
        s = str(c).strip()
        # consider numeric if it matches a number (with commas, decimals, negative)
        if re.fullmatch(r'[-+]?\d{1,3}(?:[,]\d{3})*(?:\.\d+)?|[-+]?\d+(\.\d+)?', s):
            continue
        text_like += 1
    return (text_like / len(non_empty)) >= 0.6

def row_to_list(row):
    # table.extract() can return strings or dict-like objects; normalize to list[str]
    out = []
    for cell in row:
        if isinstance(cell, dict):
            out.append(cell.get("text", "").strip())
        else:
            out.append(str(cell).strip())
    return out

def title_from_words_above(table_bbox, words, max_above_px=160):
    # words: page.extract_words() items with 'top' and 'bottom' floats and 'text'
    x0, top, x1, bottom = table_bbox
    # pick words whose bottom is less than table top and not too far above
    candidates = [w for w in words if float(w.get("bottom", 0)) < top and float(w.get("bottom", 0)) > top - max_above_px]
    if not candidates:
        return None
    # group by approximate line (by 'top' position)
    lines = {}
    for w in candidates:
        key = round(float(w.get("top", 0)), 1)
        lines.setdefault(key, []).append(w["text"])
    if not lines:
        return None
    # choose the line closest to the table (largest top)
    best_key = sorted(lines.keys(), reverse=True)[0]
    raw = " ".join(lines[best_key]).strip()
    # common cleaning: remove leading "Table 3:" etc and trailing "cont." markers
    m = re.search(r'(?:Table\s*\d+\s*[:\-\–]?\s*)?(.*?)(?:\bContd\.?|\bContinued\.?)?$', raw, flags=re.I)
    title = m.group(1).strip() if m else raw
    # discard very short/garbled lines
    if len(title) < 3 or re.fullmatch(r'[-\s\.\d]+', title):
        return None
    return title

def normalize_header(header_row):
    # Normalize header strings to consistent column names
    return [re.sub(r'\s+', ' ', str(h).strip()) for h in header_row]

def overlap_ratio(h1, h2):
    # simple overlap ratio between two header lists
    s1 = set([c.lower() for c in h1 if c])
    s2 = set([c.lower() for c in h2 if c])
    if not s1 or not s2:
        return 0.0
    return len(s1 & s2) / max(len(s1), len(s2))

def extract(pdf_path, out_dir):
    import pdfplumber
    import pandas as pd
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    last_table = None  # dict: {name, header, df, last_page}
    saved_count = 0

    with pdfplumber.open(pdf_path) as pdf:
        for pnum, page in enumerate(pdf.pages, start=1):
            tables = page.find_tables()
            if not tables:
                # If no tables on page, reset nothing; multi-page detection requires contiguous pages with tables
                continue

            words = page.extract_words()  # used to find title above each table

            for tidx, table in enumerate(tables, start=1):
                try:
                    rows = table.extract()
                except Exception:
                    # fallback: use table.rows if available, else skip
                    rows = []
                    continue
                if not rows:
                    continue

                # Normalize rows to list of lists of strings
                norm_rows = [row_to_list(r) for r in rows]
                df = pd.DataFrame(norm_rows)

                # detect header row heuristically (first row looks textual)
                header = None
                if len(df) >= 2 and is_mostly_text(df.iloc[0].tolist()):
                    header = normalize_header(df.iloc[0].tolist())
                    df = df[1:].reset_index(drop=True)
                    df.columns = header
                else:
                    # no clear header; keep numeric column indices as names
                    header = normalize_header([f"col_{i}" for i in range(len(df.columns))])
                    df.columns = header

                # try to find a title above the table
                title = title_from_words_above(table.bbox, words, max_above_px=160)

                # Determine if this table is a continuation of the last_table
                is_continuation = False
                if title is None and last_table:
                    # require contiguous pages
                    if pnum == last_table["last_page"] + 1:
                        # if header overlap high enough, treat as continuation
                        if overlap_ratio(header, last_table["header"]) >= 0.6:
                            is_continuation = True

                if is_continuation:
                    # append rows to last_table DataFrame
                    # reindex/align columns if slight differences exist
                    combine_df = df.copy()
                    # if columns differ, attempt to align by lower-case match
                    if list(combine_df.columns) != last_table["df"].columns.tolist():
                        # create mapping
                        new_cols = []
                        for c in combine_df.columns:
                            # try to find best match in last_table columns
                            matches = [lc for lc in last_table["df"].columns if lc.lower() == c.lower()]
                            new_cols.append(matches[0] if matches else c)
                        combine_df.columns = new_cols
                        # reindex to last_table columns, filling missing with ''
                        combine_df = combine_df.reindex(columns=last_table["df"].columns, fill_value='')
                    last_table["df"] = pd.concat([last_table["df"], combine_df], ignore_index=True)
                    last_table["last_page"] = pnum
                    # overwrite CSV to include appended rows
                    csv_path = last_table["csv_path"]
                    last_table["df"].to_csv(csv_path, index=False)
                else:
                    # New table: determine a file name
                    if title:
                        name = sanitize_filename(title)
                    else:
                        name = f"page{pnum:03d}_table{tidx:02d}"
                    csv_path = out_dir / f"{name}.csv"
                    # avoid overwriting: append index
                    k = 1
                    base = csv_path.stem
                    while csv_path.exists():
                        csv_path = out_dir / f"{base}_{k}.csv"
                        k += 1
                    # Save df
                    df.to_csv(csv_path, index=False)
                    saved_count += 1
                    # update last_table
                    last_table = {
                        "name": name,
                        "header": header,
                        "df": df,
                        "last_page": pnum,
                        "csv_path": csv_path
                    }
                    # If the title contains 'cont' or 'continued' it's probably start of a multi-page table.
                    # We still rely on header overlap + contiguous pages to continue.
    print(f"Done. Saved/updated {saved_count} tables to {out_dir}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 extract_tables.py /path/to/Adri_data_2024.pdf /path/to/out_dir")
        sys.exit(1)
    extract(sys.argv[1], sys.argv[2])
