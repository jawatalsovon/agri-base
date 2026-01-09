"""
Agricultural Data Scraping from Bangladesh Statistical Yearbooks (2012-2024)
Extracts tables and converts to CSV format for database import

Usage:
    python scrape_agri_yearbooks.py --url <pdf_url> --output <csv_file>
    python scrape_agri_yearbooks.py --batch <config.json>
"""

import os
import json
import pandas as pd
import pdfplumber
import argparse
from pathlib import Path
from typing import List, Dict, Optional
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class YearbookScraper:
    def __init__(self, output_dir='./scraped_data'):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

    def download_pdf(self, url: str, filename: str) -> Optional[str]:
        """Download PDF from URL"""
        try:
            import requests
            logger.info(f"Downloading {url}...")
            response = requests.get(url, timeout=30)
            
            if response.status_code == 200:
                filepath = self.output_dir / filename
                with open(filepath, 'wb') as f:
                    f.write(response.content)
                logger.info(f"✅ Downloaded to {filepath}")
                return str(filepath)
            else:
                logger.error(f"❌ Failed to download: HTTP {response.status_code}")
                return None
        except Exception as e:
            logger.error(f"❌ Error downloading PDF: {e}")
            return None

    def extract_tables_from_pdf(
        self,
        pdf_path: str,
        pages: Optional[List[int]] = None,
    ) -> List[pd.DataFrame]:
        """Extract tables from PDF using pdfplumber"""
        tables = []
        
        try:
            with pdfplumber.open(pdf_path) as pdf:
                total_pages = len(pdf.pages)
                logger.info(f"PDF has {total_pages} pages")
                
                # Determine which pages to process
                if pages is None:
                    pages = list(range(total_pages))
                
                for page_num in pages:
                    if page_num >= total_pages:
                        logger.warning(f"Page {page_num} doesn't exist")
                        continue
                    
                    try:
                        page = pdf.pages[page_num]
                        page_tables = page.extract_tables()
                        
                        if page_tables:
                            logger.info(f"Found {len(page_tables)} table(s) on page {page_num + 1}")
                            
                            for table in page_tables:
                                df = pd.DataFrame(table[1:], columns=table[0])
                                tables.append(df)
                        
                    except Exception as e:
                        logger.warning(f"Error processing page {page_num + 1}: {e}")
                        continue
        
        except Exception as e:
            logger.error(f"Error extracting tables: {e}")
        
        return tables

    def clean_dataframe(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean and standardize dataframe"""
        try:
            # Remove completely empty rows and columns
            df = df.dropna(how='all')
            df = df.dropna(axis=1, how='all')
            
            # Strip whitespace from all cells
            df = df.applymap(
                lambda x: str(x).strip() if isinstance(x, str) else x,
                na_action='ignore'
            )
            
            # Try to convert numeric columns
            for col in df.columns:
                try:
                    df[col] = pd.to_numeric(df[col], errors='coerce')
                except:
                    pass
            
            return df
        except Exception as e:
            logger.warning(f"Error cleaning dataframe: {e}")
            return df

    def save_as_csv(self, df: pd.DataFrame, filename: str) -> str:
        """Save dataframe as CSV"""
        try:
            filepath = self.output_dir / filename
            df.to_csv(filepath, index=False, encoding='utf-8')
            logger.info(f"✅ Saved {filename} ({len(df)} rows)")
            return str(filepath)
        except Exception as e:
            logger.error(f"❌ Error saving CSV: {e}")
            return ""

    def process_pdf(
        self,
        pdf_path: str,
        output_prefix: str,
        pages: Optional[List[int]] = None,
    ) -> List[str]:
        """Process PDF and save tables as CSVs"""
        logger.info(f"\nProcessing {pdf_path}...")
        
        tables = self.extract_tables_from_pdf(pdf_path, pages)
        saved_files = []
        
        for idx, table in enumerate(tables):
            df = self.clean_dataframe(table)
            
            if len(df) > 0:
                filename = f"{output_prefix}_table_{idx + 1}.csv"
                saved = self.save_as_csv(df, filename)
                if saved:
                    saved_files.append(saved)
        
        return saved_files

    def batch_process(self, config_file: str):
        """Process multiple PDFs from config"""
        try:
            with open(config_file, 'r') as f:
                config = json.load(f)
            
            logger.info(f"Processing {len(config.get('pdfs', []))} PDFs...")
            
            all_files = []
            for pdf_config in config.get('pdfs', []):
                url = pdf_config.get('url')
                year = pdf_config.get('year')
                output_prefix = pdf_config.get('output_prefix', f'yearbook_{year}')
                pages = pdf_config.get('pages')
                
                if not url:
                    logger.warning(f"No URL for {year}")
                    continue
                
                # Download PDF
                filename = f"yearbook_{year}.pdf"
                pdf_path = self.download_pdf(url, filename)
                
                if pdf_path:
                    # Process PDF
                    self.process_pdf(pdf_path, output_prefix, pages)
        
        except Exception as e:
            logger.error(f"Error in batch processing: {e}")


class DataIntegration:
    """Integrate scraped data into database"""
    
    @staticmethod
    def standardize_district_names(df: pd.DataFrame, district_col: str) -> pd.DataFrame:
        """Standardize district names across datasets"""
        # Define standard district names and variations
        district_map = {
            'dhaka': 'Dhaka',
            'dhaka (sadar)': 'Dhaka',
            'chittagong': 'Chittagong',
            'sylhet': 'Sylhet',
            'rajshahi': 'Rajshahi',
            'khulna': 'Khulna',
            'barishal': 'Barishal',
            'rangpur': 'Rangpur',
        }
        
        df[district_col] = df[district_col].str.lower().str.strip()
        df[district_col] = df[district_col].map(
            lambda x: next((v for k, v in district_map.items() if k in x), x)
        )
        
        return df
    
    @staticmethod
    def merge_crop_data(dataframes: List[pd.DataFrame]) -> pd.DataFrame:
        """Merge crop data from multiple years"""
        # Assumes DataFrames have columns: Year, District, Crop, Area, Production, Yield
        
        try:
            merged = pd.concat(dataframes, ignore_index=True)
            
            # Clean up
            merged = merged.dropna(subset=['District', 'Crop'])
            
            # Standardize names
            merged = DataIntegration.standardize_district_names(
                merged, 'District'
            )
            
            return merged
        except Exception as e:
            logger.error(f"Error merging data: {e}")
            return pd.DataFrame()


def main():
    parser = argparse.ArgumentParser(
        description='Scrape agricultural data from Bangladesh Yearbooks'
    )
    parser.add_argument('--url', help='Single PDF URL to process')
    parser.add_argument('--output', default='output.csv', help='Output CSV filename')
    parser.add_argument('--batch', help='Batch config JSON file')
    parser.add_argument('--output-dir', default='./scraped_data', help='Output directory')
    
    args = parser.parse_args()
    
    scraper = YearbookScraper(args.output_dir)
    
    if args.batch:
        # Batch processing
        scraper.batch_process(args.batch)
    elif args.url:
        # Single PDF
        import requests
        pdf_path = scraper.download_pdf(args.url, 'yearbook.pdf')
        if pdf_path:
            scraper.process_pdf(
                pdf_path,
                args.output.replace('.csv', '')
            )
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
