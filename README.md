# AgriBase - Agricultural Dashboard

A comprehensive Flask web application for analyzing agricultural data from Bangladesh.

## Features

- **Area Summary**: Visualize crop cultivation area statistics with interactive charts
- **Yield Summary**: Analyze crop yield and production data
- **Crop Search**: Search for specific crops by district and variety (Aman, Aus, Boro, Wheat)
- **Best Analysis**: Find top-performing crops and districts

## Project Structure

```
agribase/
│
├── app.py                  # Main Flask application
├── database.db             # SQLite database (your existing file)
├── requirements.txt        # Python dependencies
│
└── templates/              # HTML templates
    ├── index.html
    ├── area_summary.html
    ├── yield_summary.html
    ├── crop_search.html
    └── best.html
```

## Installation & Setup

1. **Create a project directory**:
```bash
mkdir agribase
cd agribase
```

2. **Copy your database file**:
   - Place your `database.db` file in the root directory

3. **Create a virtual environment** (recommended):
```bash
python -m venv venv

# On Windows:
venv\Scripts\activate

# On Mac/Linux:
source venv/bin/activate
```

4. **Install dependencies**:
```bash
pip install -r requirements.txt
```

5. **Create the templates folder**:
```bash
mkdir templates
```

6. **Add all HTML files** to the `templates` folder:
   - index.html
   - area_summary.html
   - yield_summary.html
   - crop_search.html
   - best.html

## Running the Application

1. **Start the Flask server**:
```bash
python app.py
```

2. **Open your browser** and navigate to:
```
http://127.0.0.1:5000
```

## Database Tables Used

The application uses the following tables from your database:

- **Rice Crops**:
  - `aman_total_by_district`, `aman_hybrid_by_district`, `aman_hyv_by_district`, `aman_broadcast_by_district`
  - `aus_total_by_district`, `aus_hybrid_by_district`, `aus_hyv_by_district`, `aus_local_by_district`
  - `boro_total_by_district`, `boro_hybrid_by_district`, `boro_hyv_by_district`, `boro_local_by_district`

- **Wheat**:
  - `wheat_area`, `wheat_estimates_district`, `wheat_production`, `wheat_yield`

- **Summary Tables**:
  - `area_summary`, `yield_summery`

## Key Features

### 1. Area Summary
- Displays crop cultivation area from the `area_summary` table
- Interactive bar chart visualization
- Detailed data table

### 2. Yield Summary
- Shows crop production data from the `yield_summery` table
- Visual representation of production statistics
- Comprehensive data display

### 3. Crop Search
- Select crop type: Aman, Aus, Boro, or Wheat
- Choose district to view specific data
- Displays all related tables for the selected crop and district

### 4. Best Analysis
- **Best Crop for District**: Find which crop performs best in a specific district
- **Best Districts for Crop**: Identify top 10 districts for a specific crop
- Based on production data (MT)

## Troubleshooting

### Common Issues

1. **Module not found error**:
   - Ensure you've installed all requirements: `pip install -r requirements.txt`

2. **Database not found**:
   - Make sure `database.db` is in the same directory as `app.py`

3. **Empty charts or tables**:
   - Check if your database tables contain data
   - Verify table names match exactly

4. **Port already in use**:
   - Change the port in `app.py`: `app.run(debug=True, port=5001)`

## Development Notes

- Debug mode is enabled for development
- For production, set `debug=False` in `app.run()`
- The application uses Bootstrap 5 for styling
- Charts are powered by Chart.js

## Future Enhancements

- Add export functionality (CSV, PDF)
- Implement user authentication
- Add more advanced analytics
- Create comparison views
- Add data filtering options

## License

This project is for educational and research purposes.
