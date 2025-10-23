
# filepath: /home/ubuntu/project/extract_tables.py
# Quick script: pdf -> separate CSVs named from nearby titles (uses pdfplumber + pandas)
import sys, os, re
from pathlib import Path

def sanitize(fn):
    fn = fn.strip()
    fn = re.sub(r'\s+', '_', fn)
    fn = re.sub(r'[^0-9A-Za-z_\-\.]', '', fn)
    fn = fn[:120] if len(fn) > 120 else fn
    return fn or None

def extract(pdf_path, out_dir):
    import pdfplumber
    import pandas as pd

    pdf_path = Path(pdf_path)
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    with pdfplumber.open(pdf_path) as pdf:
        file_count = 0
        for pidx, page in enumerate(pdf.pages, start=1):
            tables = page.find_tables()
            if not tables:
                continue
            words = page.extract_words()  # list of word dicts with 'text','top','bottom','x0','x1'
            for tidx, table in enumerate(tables, start=1):
                rows = table.extract()  # list of rows (list of cells)
                if not rows:
                    continue
                # Build DataFrame: try header detection
                df = pd.DataFrame(rows)
                # If first row looks like header (non-numeric), use it
                header = None
                if len(df) >= 2 and any(isinstance(x, str) and x.strip() for x in df.iloc[0].tolist()):
                    header = [str(x).strip() for x in df.iloc[0].tolist()]
                    df = df[1:]
                    df.columns = header
                # Find text immediately above table bbox to use as title
                x0, top, x1, bottom = table.bbox  # bbox: (x0, top, x1, bottom)
                # choose words with bottom < top and bottom > top - 90 (approx)
                candidate_words = [w for w in words if float(w.get('bottom', 0)) < top and float(w.get('bottom', 0)) > top - 90]
                # group into lines by y coordinate
                lines = {}
                for w in candidate_words:
                    key = round(float(w.get('top', 0)), 1)
                    lines.setdefault(key, []).append(w['text'])
                title = None
                if lines:
                    # pick the closest line (max bottom)
                    best_key = sorted(lines.keys(), reverse=True)[0]
                    title = ' '.join(lines[best_key]).strip()
                # fallback name
                if title:
                    name = sanitize(title)
                else:
                    name = None
                if not name:
                    name = f"page{pidx:03d}_table{tidx:02d}"
                csv_path = out_dir / f"{name}.csv"
                # If name already exists, append index
                k = 1
                base = csv_path.stem
                while csv_path.exists():
                    csv_path = out_dir / f"{base}_{k}.csv"
                    k += 1
                # Save
                try:
                    df.to_csv(csv_path, index=False)
                    file_count += 1
                    print(f"Saved: {csv_path}")
                except Exception as e:
                    # as fallback save raw rows
                    import csv
                    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
                        writer = csv.writer(f)
                        for r in rows:
                            writer.writerow([str(c) for c in r])
                    file_count += 1
                    print(f"Saved (fallback): {csv_path}  -- {e}")
    print(f"Done. {file_count} tables saved to {out_dir}")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python3 extract_tables.py /path/to/Adri_data_2024.pdf /path/to/out_dir")
        sys.exit(1)
    extract(sys.argv[1], sys.argv[2])

