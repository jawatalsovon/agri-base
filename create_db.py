import sqlite3
import pandas as pd
import os

# Connect to SQLite database
conn = sqlite3.connect('database.db')
cursor = conn.cursor()

# Base directory
base_dir = 'home/ubuntu/project'

# Define the directory structure and corresponding table names
data_files = {
    # Top-level data files
    os.path.join(base_dir, 'data', 'area_summary.csv'): 'area_summary',
    os.path.join(base_dir, 'data', 'yield_summary.csv'): 'yield_summary',
    # Pie directory files
    os.path.join(base_dir, 'data', 'pie', 'cd_data_mnkir_pie'): 'pie_cd_data_mnkir',
    # Major cereals variety files
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aman', 'aman_area_by_variety.csv'): 'aman_area_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aman', 'aman_broadcast_by_district.csv'): 'aman_broadcast_by_district',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aman_hybrid_by_district.csv'): 'aman_hybrid_by_district',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aman', 'aman_production_by_variety.csv'): 'aman_production_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aman', 'aman_total_area_by_variety.csv'): 'aman_total_area_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aman', 'aman_yield_rate_by_variety.csv'): 'aman_yield_rate_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aus', 'aus_area_by_variety.csv'): 'aus_area_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aus', 'aus_hybrid_by_district.csv'): 'aus_hybrid_by_district',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aus', 'aus_production_by_variety.csv'): 'aus_production_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aus_total_area_by_variety.csv'): 'aus_total_area_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'aus', 'aus_yield_rate_by_variety.csv'): 'aus_yield_rate_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'boro', 'boro_area_by_variety.csv'): 'boro_area_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'boro', 'boro_hybrid_by_district.csv'): 'boro_hybrid_by_district',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'boro', 'boro_production_by_variety.csv'): 'boro_production_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'boro', 'boro_total_area_by_district.csv'): 'boro_total_area_by_district',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'boro', 'boro_yield_rate_by_variety.csv'): 'boro_yield_rate_by_variety',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'wheat', 'wheat_area.csv'): 'wheat_area',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'wheat', 'wheat_estimates_districts.csv'): 'wheat_estimates_districts',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'wheat', 'wheat_production.csv'): 'wheat_production',
    os.path.join(base_dir, 'data', 'crops', 'major_cereals', 'varieties', 'wheat', 'wheat_yield.csv'): 'wheat_yield',


}

# Read each CSV and create table
for file_path, table_name in data_files.items():
    if os.path.exists(file_path):
        df = pd.read_csv(file_path)
        df.to_sql(table_name, conn, if_exists='replace', index=False)
    else:
        print(f"Warning: File {file_path} not found.")

# Commit changes and close connection
conn.commit()
conn.close()

print("Database created successfully!")
