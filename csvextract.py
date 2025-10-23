import tabula
import pandas as pd
import os
import re

# Path to your PDF file
pdf_path = "Agri_data_2024.pdf" # Replace with your actual file path

# Output directory for CSVs
output_dir = "extracted_tables"
os.makedirs(output_dir, exist_ok=True)

# Function to clean and generate a filename from table title or first row
def generate_csv_name(df, page_num):
    # Try to extract title from first row (common in reports: e.g., "3.1 Aus Rice")
    potential_title = ' '.join(df.iloc[0].astype(str).values[:3]) # First 3 cells
    # Clean for filename: remove special chars, limit length
    clean_title = re.sub(r'[^a-zA-Z0-9_\-\.]', '_', potential_title.strip())[:50] 
    if clean_title:
        return f"Table_{clean_title}.csv"
    else:
        return f"Table_Page_{page_num}.csv" # Fallback

# Extract tables from all pages (lattice=True for grid-based tables, common in stats docs)
# Use stream=True if tables lack borders
tables = tabula.read_pdf(pdf_path, pages="all", multiple_tables=True, lattice=True, silent=True)

# If the above fails due to memory, batch process like this:
# for start_page in range(1, 697, 100): # Batch every 100 pages
# end_page = min(start_page + 99, 696)
# batch_tables = tabula.read_pdf(pdf_path, pages=f"{start_page}-{end_page}", multiple_tables=True, lattice=True)
# tables.extend(batch_tables)

# Process and save each extracted table
for i, table in enumerate(tables):
    if not table.empty: # Skip empty detections
        df = pd.DataFrame(table)
        # Clean data: drop empty rows/columns, fix NaNs if needed
        df = df.dropna(how='all').dropna(axis=1, how='all').fillna('')
        # Generate name (you can manually map from contents if needed, e.g., page 51 -> "Aus Rice")
        csv_name = generate_csv_name(df, i + 1) # i+1 as page proxy
        csv_path = os.path.join(output_dir, csv_name)
        df.to_csv(csv_path, index=False, encoding='utf-8')
        print(f"Saved: {csv_path}")

print("Extraction complete. Check the 'extracted_tables' folder.")
