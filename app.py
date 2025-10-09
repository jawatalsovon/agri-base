from flask import Flask, render_template, request, jsonify
import sqlite3
import pandas as pd

app = Flask(__name__)

def get_db_connection():
    conn = sqlite3.connect('database.db')
    conn.row_factory = sqlite3.Row
    return conn

def get_all_districts():
    conn = get_db_connection()
    try:
        query = "SELECT DISTINCT District_Division FROM aman_total_by_district ORDER BY District_Division"
        df = pd.read_sql_query(query, conn)
        districts = df['District_Division'].tolist()
    except Exception as e:
        districts = []
    finally:
        conn.close()
    return districts

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/area_summary')
def area_summary():
    conn = get_db_connection()
    try:
        df = pd.read_sql_query("SELECT * FROM area_summary", conn)

        # Get crop names and latest year data
        if 'Crop' in df.columns and 'Area_2023-24' in df.columns:
            labels = df['Crop'].tolist()
            values = df['Area_2023-24'].tolist()
        else:
            labels = []
            values = []

        chart_data = {'labels': labels, 'values': values}
        table_html = df.to_html(classes='table table-striped', index=False)
    except Exception as e:
        chart_data = {'labels': [], 'values': []}
        table_html = f"<p>Error loading data: {str(e)}</p>"
    finally:
        conn.close()

    return render_template('area_summary.html', chart_data=chart_data, table=table_html)

@app.route('/yield_summary')
def yield_summary():
    conn = get_db_connection()
    try:
        df = pd.read_sql_query("SELECT * FROM yield_summery", conn)

        if 'Crop' in df.columns and '2023-24_Production_000_MT' in df.columns:
            labels = df['Crop'].tolist()
            values = df['2023-24_Production_000_MT'].tolist()
        else:
            labels = []
            values = []

        chart_data = {'labels': labels, 'values': values}
        table_html = df.to_html(classes='table table-striped', index=False)
    except Exception as e:
        chart_data = {'labels': [], 'values': []}
        table_html = f"<p>Error loading data: {str(e)}</p>"
    finally:
        conn.close()

    return render_template('yield_summary.html', chart_data=chart_data, table=table_html)

@app.route('/crop_search', methods=['GET', 'POST'])
def crop_search():
    crops = ['aman', 'aus', 'boro', 'wheat']
    districts = get_all_districts()

    if request.method == 'POST':
        crop = request.form.get('crop', 'aman')
        district = request.form.get('district', '')

        conn = get_db_connection()
        results = {}

        crop_tables = {
            'aman': ['aman_broadcast_by_district', 'aman_hybrid_by_district', 'aman_hyv_by_district', 'aman_total_by_district'],
            'aus': ['aus_hybrid_by_district', 'aus_hyv_by_district', 'aus_local_by_district', 'aus_total_by_district'],
            'boro': ['boro_hybrid_by_district', 'boro_hyv_by_district', 'boro_local_by_district', 'boro_total_by_district'],
            'wheat': ['wheat_area', 'wheat_estimates_district', 'wheat_production', 'wheat_yield']
        }

        tables = crop_tables.get(crop, [])

        for table in tables:
            try:
                query = f"SELECT * FROM {table} WHERE District_Division = ?"
                df = pd.read_sql_query(query, conn, params=(district,))

                if not df.empty:
                    results[table] = df.to_html(classes='table table-striped', index=False)
                else:
                    results[table] = "<p>No data found for this district in this table.</p>"
            except Exception as e:
                results[table] = f"<p>Error fetching data: {str(e)}</p>"

        conn.close()
        return render_template('crop_search.html', crops=crops, districts=districts,
                             results=results, selected_crop=crop, selected_district=district)

    return render_template('crop_search.html', crops=crops, districts=districts)

@app.route('/best', methods=['GET', 'POST'])
def best():
    crops = ['aman', 'aus', 'boro', 'wheat']
    districts = get_all_districts()

    if request.method == 'POST':
        query_type = request.form.get('query_type', 'best_crop')
        value = request.form.get('value', '')

        conn = get_db_connection()
        result = ""
        table_html = ""

        if query_type == 'best_crop':
            # Find best crop for a district
            data = []
            crop_tables = {
                'aman': ('aman_total_by_district', '2023-24_Production_MT'),
                'aus': ('aus_total_by_district', '2023-24_Production_MT'),
                'boro': ('boro_total_by_district', '2023-24_Production_MT'),
                'wheat': ('wheat_estimates_district', '2023-24_Production_MT')
            }

            for crop, (table, col) in crop_tables.items():
                try:
                    query = f"SELECT {col} FROM {table} WHERE District_Division = ?"
                    df = pd.read_sql_query(query, conn, params=(value,))
                    if not df.empty and df[col].iloc[0]:
                        total = float(df[col].iloc[0])
                        data.append({'Crop': crop, 'Production (MT)': total})
                except Exception:
                    continue

            if data:
                df = pd.DataFrame(data)
                df = df.sort_values('Production (MT)', ascending=False)
                table_html = df.to_html(classes='table table-striped', index=False)
                result = f"Best crop in {value}: {df.iloc[0]['Crop']} (Production: {df.iloc[0]['Production (MT)']} MT)"
            else:
                table_html = "<p>No data found.</p>"
                result = "No data available to determine best crop."

        elif query_type == 'best_districts':
            # Find top districts for a crop
            crop = value
            crop_table_map = {
                'aman': ('aman_total_by_district', '2023-24_Production_MT'),
                'aus': ('aus_total_by_district', '2023-24_Production_MT'),
                'boro': ('boro_total_by_district', '2023-24_Production_MT'),
                'wheat': ('wheat_estimates_district', '2023-24_Production_MT')
            }

            if crop in crop_table_map:
                table, col = crop_table_map[crop]
                try:
                    query = f"SELECT District_Division, {col} FROM {table} ORDER BY {col} DESC LIMIT 10"
                    df = pd.read_sql_query(query, conn)

                    if not df.empty:
                        df.columns = ['District', 'Production (MT)']
                        table_html = df.to_html(classes='table table-striped', index=False)
                        result = f"Top 10 districts for {crop.upper()} production"
                    else:
                        table_html = "<p>No data found.</p>"
                        result = ""
                except Exception as e:
                    table_html = f"<p>Error: {str(e)}</p>"
                    result = ""
            else:
                table_html = "<p>Invalid crop selected.</p>"
                result = ""

        conn.close()
        return render_template('best.html', crops=crops, districts=districts,
                             result=result, table=table_html, query_type=query_type)

    return render_template('best.html', crops=crops, districts=districts)

if __name__ == '__main__':
    app.run(debug=True)
