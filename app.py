from flask import Flask, render_template, request, jsonify
import sqlite3
import pandas as pd

app = Flask(__name__)

def get_db_connection():
    conn = sqlite3.connect('database.db')
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/area_summary')
def area_summary():
    conn = get_db_connection()
    df = pd.read_sql_query("SELECT * FROM area_summary", conn)
    conn.close()
    # Assume df has columns like 'Crop', 'Area' for pie chart
    labels = df['Crop'].tolist() if 'Crop' in df.columns else df.columns.tolist()
    values = df['Area'].tolist() if 'Area' in df.columns else df.iloc[0].tolist()
    chart_data = {'labels': labels, 'values': values}
    table_html = df.to_html(classes='table table-striped', index=False)
    return render_template('area_summary.html', chart_data=chart_data, table=table_html)

@app.route('/yield_summary')
def yield_summary():
    conn = get_db_connection()
    df = pd.read_sql_query("SELECT * FROM yield_summery", conn)  # Note spelling from your file
    conn.close()
    # Assume df has columns like 'Crop', 'Yield' for pie chart
    labels = df['Crop'].tolist() if 'Crop' in df.columns else df.columns.tolist()
    values = df['Yield'].tolist() if 'Yield' in df.columns else df.iloc[0].tolist()
    chart_data = {'labels': labels, 'values': values}
    table_html = df.to_html(classes='table table-striped', index=False)
    return render_template('yield_summary.html', chart_data=chart_data, table=table_html)

@app.route('/crop_search', methods=['GET', 'POST'])
def crop_search():
    crops = ['aman', 'aus', 'boro', 'wheat']
    conn = get_db_connection()
    df_districts = pd.read_sql_query("SELECT DISTINCT District FROM aman_total_by_district", conn)
    districts = df_districts['District'].tolist()
    conn.close()

    if request.method == 'POST':
        crop = request.form['crop']
        district = request.form['district']
        conn = get_db_connection()
        results = {}
        # Fetch from all relevant by_district tables for the crop
        if crop == 'aman':
            tables = ['aman_broadcast_by_district', 'aman_hybrid_by_district', 'aman_hyv_by_district', 'aman_total_by_district']
        elif crop == 'aus':
            tables = ['aus_hybrid_by_district', 'aus_hyv_by_district', 'aus_local_by_district', 'aus_total_by_district']
        elif crop == 'boro':
            tables = ['boro_hybrid_by_district', 'boro_hyv_by_district', 'boro_local_by_district', 'boro_total_by_district']
        elif crop == 'wheat':
            tables = ['wheat_area', 'wheat_estimates_district', 'wheat_production', 'wheat_yield']
        else:
            tables = []

        for table in tables:
            try:
                query = f"SELECT * FROM {table} WHERE District = ?"
                df = pd.read_sql_query(query, conn, params=(district,))
                results[table] = df.to_html(classes='table table-striped', index=False)
            except:
                results[table] = "<p>No data found for this table.</p>"
        conn.close()
        return render_template('crop_search.html', crops=crops, districts=districts, results=results, selected_crop=crop, selected_district=district)

    return render_template('crop_search.html', crops=crops, districts=districts)

@app.route('/best', methods=['GET', 'POST'])
def best():
    crops = ['aman', 'aus', 'boro', 'wheat']
    conn = get_db_connection()
    df_districts = pd.read_sql_query("SELECT DISTINCT District FROM aman_total_by_district", conn)
    districts = df_districts['District'].tolist()
    conn.close()

    if request.method == 'POST':
        query_type = request.form['query_type']
        value = request.form['value']
        conn = get_db_connection()
        if query_type == 'best_crop':
            # Find best crop for district based on highest total area
            data = []
            crop_tables = {
                'aman': ('aman_total_by_district', 'Total_Area'),
                'aus': ('aus_total_by_district', 'Total_Area'),
                'boro': ('boro_total_by_district', 'Total_Area'),
                'wheat': ('wheat_area', 'Area')
            }
            for crop, (table, col) in crop_tables.items():
                try:
                    query = f"SELECT {col} FROM {table} WHERE District = ?"
                    total = pd.read_sql_query(query, conn, params=(value,))[col].iloc[0]
                    data.append({'crop': crop, 'total': total})
                except:
                    pass
            if data:
                df = pd.DataFrame(data)
                df = df.sort_values('total', ascending=False)
                table_html = df.to_html(classes='table table-striped', index=False)
            else:
                table_html = "<p>No data found.</p>"
            result = f"Best crop in {value}: {df.iloc[0]['crop']} (Total: {df.iloc[0]['total']})"
            return render_template('best.html', crops=crops, districts=districts, result=result, table=table_html)

        elif query_type == 'best_districts':
            # Find best districts for crop based on highest total area (top 5)
            crop = value
            if crop == 'aman':
                table = 'aman_total_by_district'
                col = 'Total_Area'
            elif crop == 'aus':
                table = 'aus_total_by_district'
                col = 'Total_Area'
            elif crop == 'boro':
                table = 'boro_total_by_district'
                col = 'Total_Area'
            elif crop == 'wheat':
                table = 'wheat_area'
                col = 'Area'
            else:
                table = None

            if table:
                query = f"SELECT District, {col} FROM {table} ORDER BY {col} DESC LIMIT 5"
                df = pd.read_sql_query(query, conn)
                table_html = df.to_html(classes='table table-striped', index=False)
                result = f"Top districts for {crop}"
            else:
                table_html = "<p>No data found.</p>"
                result = ""
            return render_template('best.html', crops=crops, districts=districts, result=result, table=table_html)

    return render_template('best.html', crops=crops, districts=districts)

if __name__ == '__main__':
    app.run(debug=True)
