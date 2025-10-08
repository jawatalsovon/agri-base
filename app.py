from flask import Flask, render_template, request, jsonify
import pandas as pd
import sqlite3

app = Flask(__name__)

# Connect to the database
def get_db_connection():
    conn = sqlite3.connect('database.db')
    return conn

# Route for the main page
@app.route('/')
def index():
    conn = get_db_connection()
    # Extract unique district names from all district tables across all varieties
    district_tables = [
        'aman_broadcast_by_district', 'aman_local_trans_by_district', 'aman_hyv_by_district',
        'aman_hybrid_by_district', 'aman_total_by_district',
        'aus_hybrid_by_district', 'aus_hyv_by_district', 'aus_local_by_district',
        'aus_total_by_district', 'boro_hybrid_by_district', 'boro_hyv_by_district',
        'boro_local_by_district', 'boro_total_by_district',
        'wheat_estimates_district'
    ]
    all_districts = set()
    for table in district_tables:
        df = pd.read_sql_query(f"SELECT District_Division FROM {table}", conn)
        all_districts.update(df['District_Division'].dropna().unique())
    districts = sorted(list(all_districts))
    conn.close()
    return render_template('index.html', districts=districts)

# Route to handle district search (autocomplete)
@app.route('/search_districts', methods=['GET'])
def search_districts():
    conn = get_db_connection()
    district_tables = [
        'aman_broadcast_by_district', 'aman_local_trans_by_district', 'aman_hyv_by_district',
        'aman_hybrid_by_district', 'aman_total_by_district',
        'aus_hybrid_by_district', 'aus_hyv_by_district', 'aus_local_by_district',
        'aus_total_by_district', 'boro_hybrid_by_district', 'boro_hyv_by_district',
        'boro_local_by_district', 'boro_total_by_district',
        'wheat_estimates_district'
    ]
    all_districts = set()
    for table in district_tables:
        df = pd.read_sql_query(f"SELECT District_Division FROM {table}", conn)
        all_districts.update(df['District_Division'].dropna().unique())
    districts = sorted(list(all_districts))
    conn.close()

    query = request.args.get('q', '').lower()
    if query:
        filtered_districts = [d for d in districts if query in d.lower()]
    else:
        filtered_districts = districts
    return jsonify(filtered_districts[:10])  # Limit to top 10 suggestions

if __name__ == '__main__':
    app.run(debug=True)
