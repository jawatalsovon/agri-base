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
    labels = df['Crop'].tolist() if 'Crop' in df.columns else df.columns.tolist()
    values = df['Area'].tolist() if 'Area' in df.columns else df.iloc[0].tolist()
    chart_data = {'labels': labels, 'values': values}
    table_html = df.to_html(classes='table table-striped', index=False)
    return render_template('area_summary.html', chart_data=chart_data, table=table_html)

@app.route('/yield_summary')
def yield_summary():
    conn = get_db_connection()
    df = pd.read_sql_query("SELECT * FROM yield_summery", conn)
    conn.close()
    labels = df['Crop'].tolist() if 'Crop' in df.columns else df.columns.tolist()
    values = df['Yield'].tolist() if 'Yield' in df.columns else df.iloc[0].tolist()
    chart_data = {'labels': labels, 'values': values}
    table_html = df.to_html(classes='table table-striped', index=False)
    return render_template('yield_summary.html', chart_data=chart_data, table=table_html)

@app.route('/crop_search', methods=['GET', 'POST'])
def crop_search():
    crops = ['aman', 'aus', 'boro', 'wheat']
    conn = get_db_connection()

    all_districts = pd.read_sql_query(f"SELECT District_Division FROM aman_total_by_district", conn)
    districts = sorted(list(all_districts))
    conn.close()

    if request.method == 'POST':
        crop = request.form['crop']
        district = request.form['district']
        conn = get_db_connection()
        results = {}
        # Map crops to their relevant tables
        crop_tables = {
            'aman': ['aman_broadcast_by_district', 'aman_hybrid_by_district', 'aman_hyv_by_district', 'aman_total_by_district'],
            'aus': ['aus_hybrid_by_district', 'aus_hyv_by_district', 'aus_local_by_district', 'aus_total_by_district'],
            'boro': ['boro_hybrid_by_district', 'boro_hyv_by_district', 'boro_local_by_district', 'boro_total_by_district'],
            'wheat': ['wheat_area', 'wheat_estimates_district', 'wheat_production', 'wheat_yield']
        }
        tables = crop_tables.get(crop, [])

        for table in tables:
            try:
                query = f"SELECT * FROM {table} WHERE District FROM districts"
                df = pd.read_sql_query(query, conn, params=(district,))
                results[table] = df.to_html(classes='table table-striped', index=False) if not df.empty else "<p>No data found for this table.</p>"
            except Exception as e:
                results[table] = f"<p>Error fetching data: {str(e)}</p>"
        conn.close()
        return render_template('crop_search.html', crops=crops, districts=districts, results=results, selected_crop=crop, selected_district=district)

    return render_template('crop_search.html', crops=crops, districts=districts)


@app.route('/best', methods=['GET', 'POST'])
def best():
    crops = ['aman', 'aus', 'boro', 'wheat']
    conn = get_db_connection()

    all_districts = pd.read_sql_query(f"SELECT District_Division FROM aman_total_by_district", conn)
    districts = sorted(list(all_districts))
    conn.close()


    if request.method == 'POST':
        query_type = request.form['query_type']
        value = request.form['value']
        conn = get_db_connection()
        if query_type == 'best_crop':
            data = []
            crop_tables = {
                'aman': ('aman_total_by_district', 'Total_Area'),
                'aus': ('aus_total_by_district', 'Total_Area'),
                'boro': ('boro_total_by_district', 'Total_Area'),
                'wheat': ('wheat_area', 'Area')
            }
            for crop, (table, col) in crop_tables.items():
                try:
                    query = f"SELECT {col} FROM {table} WHERE District FROM districts"
                    df = pd.read_sql_query(query, conn, params=(value,))
                    if not df.empty:
                        total = df[col].iloc[0]
                        data.append({'crop': crop, 'total': total})
                except Exception as e:
                    continue
            if data:
                df = pd.DataFrame(data)
                df = df.sort_values('total', ascending=False)
                table_html = df.to_html(classes='table table-striped', index=False)
                result = f"Best crop in {value}: {df.iloc[0]['crop']} (Total: {df.iloc[0]['total']})"
            else:
                table_html = "<p>No data found.</p>"
                result = "No data available to determine best crop."
            conn.close()
            return render_template('best.html', crops=crops, districts=districts, result=result, table=table_html)

        elif query_type == 'best_districts':
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
                try:
                    query = f"SELECT District, {col} FROM {table} ORDER BY {col} DESC LIMIT 5"
                    df = pd.read_sql_query(query, conn)
                    table_html = df.to_html(classes='table table-striped', index=False) if not df.empty else "<p>No data found.</p>"
                    result = f"Top districts for {crop}"
                except Exception as e:
                    table_html = f"<p>Error: {str(e)}</p>"
                    result = ""
            else:
                table_html = "<p>No data found.</p>"
                result = ""
            conn.close()
            return render_template('best.html', crops=crops, districts=districts, result=result, table=table_html)

    return render_template('best.html', crops=crops, districts=districts)

if __name__ == '__main__':
    app.run(debug=True)
