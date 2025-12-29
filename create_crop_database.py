"""
Script to convert CSV files to SQLite database for Flutter app.
Run this once to create the database from CSV files.
"""
import sqlite3
import csv
import os
from pathlib import Path

def create_crop_database():
    """Create SQLite database from CSV files"""
    
    # Database path
    db_path = 'app/assets/databases/crops.db'
    
    # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(db_path), exist_ok=True)
    
    # Remove existing database
    if os.path.exists(db_path):
        os.remove(db_path)
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    print("Creating crops database...")
    
    # 1. Create table for individual crop data (from model/crops/)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS crop_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            crop_name TEXT NOT NULL,
            district TEXT NOT NULL,
            year TEXT NOT NULL,
            hectares REAL,
            production_mt REAL,
            UNIQUE(crop_name, district, year)
        )
    ''')
    
    # 2. Create table for predictions (from model/predictions/)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS crop_predictions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            crop_name TEXT NOT NULL,
            district TEXT NOT NULL,
            area_hectares_pred REAL,
            production_mt_pred REAL,
            UNIQUE(crop_name, district)
        )
    ''')
    
    # 3. Create table for area summary (from data/area_summary.csv)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS area_summary (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            crop TEXT NOT NULL,
            area_2019_20 REAL,
            area_2020_21 REAL,
            area_2021_22 REAL,
            area_2022_23 REAL,
            area_2023_24 REAL,
            production_2019_20 REAL,
            production_2020_21 REAL,
            production_2021_22 REAL,
            production_2022_23 REAL,
            production_2023_24 REAL,
            UNIQUE(crop)
        )
    ''')
    
    # 4. Create table for yield summary (from data/yield_summery.csv)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS yield_summary (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            crop TEXT NOT NULL,
            area_2021_22 REAL,
            yield_per_acre_2021_22 REAL,
            production_2021_22 REAL,
            area_2022_23 REAL,
            yield_per_acre_2022_23 REAL,
            production_2022_23 REAL,
            area_2023_24 REAL,
            yield_per_acre_2023_24 REAL,
            production_2023_24 REAL,
            UNIQUE(crop)
        )
    ''')
    
    # 5. Create index for faster queries
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_crop_data ON crop_data(crop_name, district, year)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_crop_predictions ON crop_predictions(crop_name, district)')
    
    # Load individual crop CSVs
    print("\nLoading individual crop data...")
    crops_dir = Path('model/crops')
    if crops_dir.exists():
        csv_files = list(crops_dir.glob('*.csv'))
        print(f"Found {len(csv_files)} crop CSV files")
        
        for csv_file in csv_files:
            crop_name = csv_file.stem  # filename without extension
            print(f"  Processing {crop_name}...")
            
            try:
                with open(csv_file, 'r', encoding='utf-8') as f:
                    reader = csv.DictReader(f)
                    rows_inserted = 0
                    
                    for row in reader:
                        district = row.get('District', '').strip()
                        year = row.get('Year', '').strip()
                        hectares = _parse_float(row.get('Hectares', ''))
                        production = _parse_float(row.get('Production_MT', ''))
                        
                        # Skip empty rows and division totals
                        if not district or not year or 'Division' in district:
                            continue
                        
                        try:
                            cursor.execute('''
                                INSERT OR REPLACE INTO crop_data 
                                (crop_name, district, year, hectares, production_mt)
                                VALUES (?, ?, ?, ?, ?)
                            ''', (crop_name, district, year, hectares, production))
                            rows_inserted += 1
                        except Exception as e:
                            print(f"    Error inserting row: {e}")
                    
                    print(f"    Inserted {rows_inserted} rows")
            except Exception as e:
                print(f"  Error processing {crop_name}: {e}")
    
    # Load predictions
    print("\nLoading prediction data...")
    predictions_dir = Path('model/predictions')
    if predictions_dir.exists():
        csv_files = list(predictions_dir.glob('*_predictions.csv'))
        print(f"Found {len(csv_files)} prediction CSV files")
        
        for csv_file in csv_files:
            # Extract crop name (remove _predictions suffix)
            crop_name = csv_file.stem.replace('_predictions', '')
            print(f"  Processing {crop_name} predictions...")
            
            try:
                with open(csv_file, 'r', encoding='utf-8') as f:
                    reader = csv.DictReader(f)
                    rows_inserted = 0
                    
                    for row in reader:
                        district = row.get('District', '').strip()
                        area_pred = _parse_float(row.get('Area_Hectares_Pred', ''))
                        prod_pred = _parse_float(row.get('Production_MT_Pred', ''))
                        
                        if not district or 'Division' in district:
                            continue
                        
                        try:
                            cursor.execute('''
                                INSERT OR REPLACE INTO crop_predictions 
                                (crop_name, district, area_hectares_pred, production_mt_pred)
                                VALUES (?, ?, ?, ?)
                            ''', (crop_name, district, area_pred, prod_pred))
                            rows_inserted += 1
                        except Exception as e:
                            print(f"    Error inserting row: {e}")
                    
                    print(f"    Inserted {rows_inserted} rows")
            except Exception as e:
                print(f"  Error processing {crop_name}: {e}")
    
    # Load area summary
    print("\nLoading area summary...")
    area_summary_path = Path('data/area_summary.csv')
    if area_summary_path.exists():
        with open(area_summary_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            rows_inserted = 0
            
            for row in reader:
                crop = row.get('Crop', '').strip()
                if not crop or crop.startswith('CEREALS') or crop.startswith('Pulses') or not crop:
                    continue
                
                try:
                    cursor.execute('''
                        INSERT OR REPLACE INTO area_summary 
                        (crop, area_2019_20, area_2020_21, area_2021_22, area_2022_23, area_2023_24,
                         production_2019_20, production_2020_21, production_2021_22, production_2022_23, production_2023_24)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ''', (
                        crop,
                        _parse_float(row.get('Area_2019-20', '')),
                        _parse_float(row.get('Area_2020-21', '')),
                        _parse_float(row.get('Area_2021-22', '')),
                        _parse_float(row.get('Area_2022-23', '')),
                        _parse_float(row.get('Area_2023-24', '')),
                        _parse_float(row.get('Production_2019-20', '')),
                        _parse_float(row.get('Production_2020-21', '')),
                        _parse_float(row.get('Production_2021-22', '')),
                        _parse_float(row.get('Production_2022-23', '')),
                        _parse_float(row.get('Production_2023-24', '')),
                    ))
                    rows_inserted += 1
                except Exception as e:
                    print(f"  Error inserting {crop}: {e}")
            
            print(f"  Inserted {rows_inserted} rows")
    
    # Load yield summary
    print("\nLoading yield summary...")
    yield_summary_path = Path('data/yield_summery.csv')
    if yield_summary_path.exists():
        with open(yield_summary_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            rows_inserted = 0
            
            for row in reader:
                crop = row.get('Crop', '').strip()
                # Skip header rows
                if not crop or crop.startswith('MAJOR') or crop.startswith('Rice') or crop.startswith('Total') or crop.startswith('MINOR'):
                    continue
                
                try:
                    cursor.execute('''
                        INSERT OR REPLACE INTO yield_summary 
                        (crop, area_2021_22, yield_per_acre_2021_22, production_2021_22,
                         area_2022_23, yield_per_acre_2022_23, production_2022_23,
                         area_2023_24, yield_per_acre_2023_24, production_2023_24)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ''', (
                        crop,
                        _parse_float(row.get('2021-22_Area', '')),
                        _parse_float(row.get('2021-22_Per_Acre_Yield_Kg', '')),
                        _parse_float(row.get('2021-22_Production_MT', '')),
                        _parse_float(row.get('2022-23_Area', '')),
                        _parse_float(row.get('2022-23_Per_Acre_Yield_Kg', '')),
                        _parse_float(row.get('2022-23_Production_MT', '')),
                        _parse_float(row.get('2023-24_Area', '')),
                        _parse_float(row.get('2023-24_Per_Acre_Yield_Kg', '')),
                        _parse_float(row.get('2023-24_Production_MT', '')),
                    ))
                    rows_inserted += 1
                except Exception as e:
                    print(f"  Error inserting {crop}: {e}")
            
            print(f"  Inserted {rows_inserted} rows")
    
    conn.commit()
    
    # Print statistics
    print("\n=== Database Statistics ===")
    cursor.execute('SELECT COUNT(*) FROM crop_data')
    print(f"Total crop data rows: {cursor.fetchone()[0]}")
    
    cursor.execute('SELECT COUNT(DISTINCT crop_name) FROM crop_data')
    print(f"Unique crops: {cursor.fetchone()[0]}")
    
    cursor.execute('SELECT COUNT(DISTINCT district) FROM crop_data')
    print(f"Unique districts: {cursor.fetchone()[0]}")
    
    cursor.execute('SELECT COUNT(*) FROM crop_predictions')
    print(f"Total prediction rows: {cursor.fetchone()[0]}")
    
    cursor.execute('SELECT COUNT(*) FROM area_summary')
    print(f"Area summary rows: {cursor.fetchone()[0]}")
    
    cursor.execute('SELECT COUNT(*) FROM yield_summary')
    print(f"Yield summary rows: {cursor.fetchone()[0]}")
    
    conn.close()
    print(f"\nDatabase created successfully at: {db_path}")
    print("You can now use this database in your Flutter app!")

def _parse_float(value):
    """Parse float value, handling empty strings and commas"""
    if not value or value == '-' or value == '':
        return None
    try:
        # Remove commas and parse
        return float(str(value).replace(',', '').strip())
    except (ValueError, AttributeError):
        return None

if __name__ == '__main__':
    create_crop_database()

