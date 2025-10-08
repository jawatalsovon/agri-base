# app.py
from flask import Flask, render_template, request, jsonify
import sqlite3
import pandas as pd

app = Flask(__name__)

def get_db():
    conn = sqlite3.connect('agriculture.db')
    return conn

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/yield_summary')
def yield_summary():
    return render_template('yield_summary.html')

@app.route('/get_yield_data')
def get_yield_data():
    conn = get_db()
    df = pd.read_sql('SELECT * FROM crop_summary', conn)
    data = df.to_dict(orient='records')
    conn.close()
    return jsonify(data)

@app.route('/area_summary')
def area_summary():
    return render_template('area_summary.html')

@app.route('/get_area_data')
def get_area_data():
    conn = get_db()
    df = pd.read_sql('SELECT * FROM crop_summary', conn)
    data = df.to_dict(orient='records')
    conn.close()
    return jsonify(data)

@app.route('/region_data')
def region_data():
    return render_template('region_data.html')

@app.route('/get_region_data', methods=['POST'])
def get_region_data():
    crop = request.form['crop']
    district = request.form['district']
    conn = get_db()
    if crop in ['Aus Rice', 'Aman Rice', 'Boro Rice']:
        query = f"SELECT * FROM rice_data WHERE crop = '{crop}' AND District_Division LIKE '%{district}%'"
    else:  # Wheat
        query = f"SELECT * FROM wheat_data WHERE District_Division LIKE '%{district}%'"
    df = pd.read_sql(query, conn)
    data = df.to_dict(orient='records')
    conn.close()
    return jsonify(data)

@app.route('/analysis')
def analysis():
    return render_template('analysis.html')

@app.route('/get_top_districts', methods=['POST'])
def get_top_districts():
    crop = request.form['crop']
    conn = get_db()
    if crop in ['Aus Rice', 'Aman Rice', 'Boro Rice']:
        query = f"""SELECT District_Division, SUM("2023-24_Production_MT") as production
                    FROM rice_data WHERE crop = '{crop}' AND variety = 'Total'
                    GROUP BY District_Division ORDER BY production DESC LIMIT 10"""
    else:  # Wheat
        query = f"""SELECT District_Division, "2023-24_Production_MT" as production
                    FROM wheat_data ORDER BY production DESC LIMIT 10"""
    df = pd.read_sql(query, conn)
    data = df.to_dict(orient='records')
    conn.close()
    return jsonify(data)

@app.route('/get_best_crops', methods=['POST'])
def get_best_crops():
    district = request.form['district']
    conn = get_db()
    query_rice = f"""SELECT crop || ' ' || variety as crop_var, "2023-24_Production_MT" as production
                     FROM rice_data WHERE District_Division LIKE '%{district}%' AND variety = 'Total'"""
    df_rice = pd.read_sql(query_rice, conn)
    query_wheat = f"""SELECT 'Wheat' as crop_var, "2023-24_Production_MT" as production
                      FROM wheat_data WHERE District_Division LIKE '%{district}%'"""
    df_wheat = pd.read_sql(query_wheat, conn)
    df = pd.concat([df_rice, df_wheat])
    df = df.sort_values('production', ascending=False).head(10)
    data = df.to_dict(orient='records')
    conn.close()
    return jsonify(data)

if __name__ == '__main__':
    app.run(debug=True)
