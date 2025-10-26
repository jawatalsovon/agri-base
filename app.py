# agribase/app.py

# ...existing code...
import sqlite3
import os
import re
import pandas as pd
from flask import Flask, render_template, request, redirect, url_for, g, flash, jsonify
import difflib
import math
# Note: You must install the google-genai library: pip install google-genai pandas

# --- CONFIGURATION ---
app = Flask(__name__)
app.secret_key = 'ee01b05594e9ea2b8a9d2448fef1222951abbd044751bea9'

# Database paths
HISTORICAL_DB = 'agri-base.db'
PREDICTIONS_DB = 'predictions.db'
ATTEMPT_DB = 'attempt.db'                   # <-- new DB the user requested

# Use environment variable for API Key (Best Practice)
API_KEY = os.environ.get("GEMINI_API_KEY", "AIzaSyDYEx1xSi9QwRPIGL-qbAdtklFmMjj3JvQ")

# Initialize AI components globally (cached)
qa_chain = None
DB_SCHEMA_CACHE = None
RAG_DOCS_CACHE = None    # list of dicts: {'id','db','table','schema','sample_text','text'}
# ...existing code...

def get_db():
    """Get a database connection for the main HISTORICAL_DB from the application context."""
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(HISTORICAL_DB)
        db.text_factory = lambda b: b.decode('latin-1')
        db.row_factory = sqlite3.Row
    return db

# ...existing code...
@app.teardown_appcontext
def close_connection(exception):
    """Close the database connection at the end of the request."""
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

def query_db(query, args=(), one=False):
    """Execute a query against the main HISTORICAL_DB and return the results."""
    try:
        cur = get_db().execute(query, args)
        rv = cur.fetchall()
        cur.close()
        # Ensure we always return a list for multiple results or None/first element for one=True
        return (rv if rv else None) if one else rv
    except sqlite3.OperationalError as e:
        flash(f"Database Error: {e}. Check table names or database existence.", 'danger')
        return []

# Helper functions for crop lists and basic results cleaning
def clean_results(results):
    return results

def get_district_names():
    """Fetches a sorted list of unique district names from the database."""
    # Assuming 'aman_total_by_district' is a reliable source for districts
    districts = query_db("SELECT DISTINCT District_Division FROM aman_total_by_district ORDER BY District_Division")
    return [d['District_Division'] for d in districts]

def get_pie_chart_tables():
    """Finds all tables in the database with names starting with 'pie_'."""
    tables = query_db("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'pie_%'")
    return [table['name'] for table in tables]

# --- CROP LISTS ---
CROP_HIERARCHY = {
    "Major Cereals": ["Aus Rice", "Aman Rice", "Boro Rice", "Wheat"],
    "Minor Cereals": ["Maize", "Jower (Millet)", "Barley/Jab", "Cheena & Kaon", "Binnidana"],
    "Pulses": ["Lentil (Masur)", "Kheshari", "Mashkalai", "Mung", "Gram", "Motor", "Fallon", "Other Pulses"],
    "Oilseeds": ["Rape and Mustard", "Til", "Groundnut", "Soyabean", "Linseed", "Coconut", "Sunflower"],
    "Spices": ["Onion", "Garlic", "Chillies", "Turmeric", "Ginger", "Coriander", "Other Spices"],
    "Sugar Crops": ["Sugarcane", "Date Palm", "Palmyra Palm"],
    "Fibers": ["Jute", "Cotton", "Sunhemp"],
    "Narcotics": ["Tea", "Betelnut", "Betel Leaves", "Tobacco"],
}
AVAILABLE_MAJOR_CROPS = ["Aus Rice", "Aman Rice", "Boro Rice", "Wheat"]


# --- RAG CHATBOT DATABASE & AI FUNCTIONS ---

def get_db_schema():
    """Connects to all databases (historical, predictions, attempt) and returns schema + cached sample rows.
       Also populates RAG_DOCS_CACHE used for lightweight retrieval."""
    global DB_SCHEMA_CACHE, RAG_DOCS_CACHE
    if DB_SCHEMA_CACHE and RAG_DOCS_CACHE:
        return DB_SCHEMA_CACHE

    schema_parts = []
    docs = []
    dbs = {
        "HISTORICAL_DATA": HISTORICAL_DB,
        "PREDICTION_DATA": PREDICTIONS_DB,
        "ATTEMPT_DATA": ATTEMPT_DB
    }

    for name, db_path in dbs.items():
        if not os.path.exists(db_path):
            schema_parts.append(f"WARNING: Database file not found at {db_path}")
            continue
        try:
            conn = sqlite3.connect(db_path)
            cursor = conn.cursor()
            cursor.execute("SELECT name, sql FROM sqlite_master WHERE type='table'")
            schema_parts.append(f"--- SCHEMA FOR DATABASE: {name} ({db_path}) ---")
            for table_name, sql in cursor.fetchall():
                if not sql:
                    continue
                cleaned_sql = re.sub(r'[\r\n\t]+', ' ', sql).strip()
                schema_parts.append(cleaned_sql)

                # Try to sample up to 5 rows for retrieval context
                try:
                    c2 = conn.cursor()
                    c2.execute(f'SELECT * FROM "{table_name}" LIMIT 5')
                    rows = c2.fetchall()
                    colnames = [d[0] for d in c2.description] if c2.description else []
                    sample_lines = []
                    for r in rows:
                        # r may be a tuple
                        vals = [str(r[i]) if r[i] is not None else '' for i in range(len(colnames))]
                        sample_lines.append(", ".join(f"{col}:{vals[i]}" for i, col in enumerate(colnames)))
                    sample_text = " | ".join(sample_lines) if sample_lines else ""
                    doc_text = f"TABLE: {table_name}\nSCHEMA: {cleaned_sql}\nSAMPLE: {sample_text}"
                    docs.append({
                        'id': f"{name}:{table_name}",
                        'db': name,
                        'path': db_path,
                        'table': table_name,
                        'schema': cleaned_sql,
                        'sample_text': sample_text,
                        'text': doc_text
                    })
                except Exception:
                    # skip sampling on error, but continue
                    pass

            conn.close()
        except Exception as e:
            schema_parts.append(f"Error reading schema from {db_path}: {str(e)}")

    DB_SCHEMA_CACHE = "\n".join(schema_parts)
    RAG_DOCS_CACHE = docs
    return DB_SCHEMA_CACHE

def _token_overlap_score(query, text):
    """Simple token overlap scoring for lightweight retrieval."""
    q_tokens = set(re.findall(r'\w+', query.lower()))
    t_tokens = set(re.findall(r'\w+', text.lower()))
    if not q_tokens or not t_tokens:
        return 0.0
    overlap = len(q_tokens & t_tokens)
    # normalize by log sizes to favor dense matches
    return overlap / (math.log(len(q_tokens) + 1) + math.log(len(t_tokens) + 1))

def retrieve_relevant_docs(query, top_k=3):
    """Return top-k most relevant doc dicts from RAG_DOCS_CACHE using token overlap.
       Attempt to use embeddings from genai if available (optional fallback)."""
    global RAG_DOCS_CACHE
    if RAG_DOCS_CACHE is None:
        get_db_schema()  # builds cache

    docs = RAG_DOCS_CACHE or []
    if not docs:
        return []

    # Try embeddings-based retrieval if genai supports embeddings and API key present
    try:
        import google.generativeai as genai
        genai.configure(api_key=API_KEY) if API_KEY else None
        if hasattr(genai, "Embeddings") or hasattr(genai, "embeddings"):  # tentative check
            # This is a best-effort; the exact API may differ by release. If it fails, fallback.
            try:
                # create embeddings for query and docs (best-effort)
                model_name = "embed_text_1" if hasattr(genai, "Embeddings") else "textembedding-gecko"
                # This block may raise if API/SDK differs; we ignore and fallback.
                q_emb = genai.embeddings.create(model=model_name, input=query).embeddings[0].embedding
                scores = []
                for d in docs:
                    d_emb = genai.embeddings.create(model=model_name, input=d['text']).embeddings[0].embedding
                    # cosine similarity
                    dot = sum(a * b for a, b in zip(q_emb, d_emb))
                    norm_q = math.sqrt(sum(a * a for a in q_emb))
                    norm_d = math.sqrt(sum(b * b for b in d_emb))
                    sim = dot / (norm_q * norm_d + 1e-12)
                    scores.append((sim, d))
                scores.sort(key=lambda x: x[0], reverse=True)
                return [d for _, d in scores[:top_k]]
            except Exception:
                pass
    except Exception:
        pass

    # Fallback: token overlap
    scored = []
    for d in docs:
        s = _token_overlap_score(query, d['text'])
        scored.append((s, d))
    scored.sort(key=lambda x: x[0], reverse=True)
    return [d for s, d in scored[:top_k] if s > 0] or [d for _, d in scored[:top_k]]

def initialize_qa_chain():
    """Initialize Gemini chatbot and pre-fetch the database schema."""
    global qa_chain
    if qa_chain is not None:
        return True

    if not API_KEY:
        print("[WARN] GEMINI_API_KEY is not set. AI features will fail without a valid key.")
        return False

    try:
        import google.generativeai as genai
        genai.configure(api_key=API_KEY)
        qa_chain = genai.GenerativeModel('gemini-2.5-flash')
        # prime the schema and doc cache
        get_db_schema()
        print("[OK] AI Chatbot initialized with gemini-2.5-flash and schema loaded.")
        return True
    except ImportError:
        print("[ERROR] 'google-generativeai' library not found. Please run: pip install google-genai")
        return False
    except Exception as e:
        print(f"[ERROR] Error initializing AI chatbot: {str(e)}")
        return False

def is_casual_conversation(text):
    """Detect if the input is casual conversation vs. a data query."""
    casual_patterns = [
        r'\b(hi|hello|hey|hola|greetings|bye|goodbye|thanks|thank you)\b',
        r'\b(how are you|nice to meet|good morning|good evening|good night)\b',
        r'\b(what\'s up|sup|yo|amigo|friend)\b'
    ]
    text = text.lower()
    return any(re.search(pattern, text) for pattern in casual_patterns)

def analyze_and_index_databases():
    """Create indices on commonly queried columns in all databases."""
    dbs = [HISTORICAL_DB, PREDICTIONS_DB, ATTEMPT_DB]
    for db_path in dbs:
        if not os.path.exists(db_path):
            continue
        try:
            conn = sqlite3.connect(db_path)
            cursor = conn.cursor()

            # Get all tables
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
            tables = cursor.fetchall()

            for (table_name,) in tables:
                # Get columns for each table
                cursor.execute(f'PRAGMA table_info("{table_name}")')
                columns = cursor.fetchall()

                # Create indices on likely query columns
                for col in columns:
                    col_name = col[1]
                    if any(key in col_name.lower() for key in [
                        'district', 'division', 'crop', 'year', 'production',
                        'area', 'yield', 'season', 'variety'
                    ]):
                        index_name = f"idx_{table_name}_{col_name}".replace(' ', '_')
                        try:
                            cursor.execute(f'CREATE INDEX IF NOT EXISTS "{index_name}" ON "{table_name}"("{col_name}")')
                        except sqlite3.OperationalError:
                            continue  # Skip if column can't be indexed

            conn.commit()
            conn.close()
        except Exception as e:
            print(f"Error indexing {db_path}: {str(e)}")

def get_data_for_rag(sql_query, prefer_db=None):
    """
    Executes an SQL query against the appropriate database (historical, predictions, or attempt).
    Returns the result as a string (DataFrame representation) or an error.
    """
    # Basic safety: only allow SELECT queries
    if not re.match(r'^\s*SELECT\b', sql_query, re.IGNORECASE):
        return "Error: Only SELECT queries are allowed in this interface."

    # Heuristic selection: if a table name from RAG_DOCS_CACHE matches, use its db path
    target_db = None
    if prefer_db:
        target_db = prefer_db
    else:
        # search for any table mentioned in query
        if RAG_DOCS_CACHE is None:
            get_db_schema()
        for d in (RAG_DOCS_CACHE or []):
            if re.search(rf'\b{re.escape(d["table"])}\b', sql_query, re.IGNORECASE):
                target_db = d['path']
                break

    # fallback: use predictions if query mentions predict/forecast/forecasted, else historical
    if not target_db:
        if re.search(r'predict|forecast|prediction|forecasted|expected', sql_query, re.IGNORECASE):
            target_db = PREDICTIONS_DB if os.path.exists(PREDICTIONS_DB) else HISTORICAL_DB
        else:
            # default to historical
            target_db = HISTORICAL_DB

    try:
        if not os.path.exists(target_db):
            return f"Error: Database file not found at {target_db}"

        conn = sqlite3.connect(target_db)
        df = pd.read_sql_query(sql_query, conn)
        conn.close()

        if df.empty:
            return "No data was returned for this specific query."

        if len(df) > 100:
            df = df.head(100)

        # return concise string and also JSON-ready representation if needed
        return df.to_string(index=False)
    except pd.io.sql.DatabaseError as e:
        return f"SQL Execution Error: The query failed. Check table and column names: {str(e)}"
    except Exception as e:
        return f"An unexpected error occurred during database access: {str(e)}"

# ...existing routes and functions remain mostly unchanged until api_chat...
# Replace the /api/chat route implementation with the improved RAG flow:

# --- FLASK ROUTES ---

@app.before_request
def startup():
    """Initialize AI chain once"""
    global qa_chain
    if qa_chain is None:
        initialize_qa_chain()


@app.route('/')
def index():
    """Home page."""
    return render_template('index.html')


@app.route('/area_summary')
def area_summary():
    """Interactive Area Summary Report."""
    summary_data = query_db("SELECT * FROM area_summary")
    summary_data = clean_results(summary_data)

    table_headers = []
    # FIX: Get keys from the first row object if the list is not empty
    if summary_data:
        table_headers = summary_data[0].keys()
        labels = [row['Crop'] for row in summary_data]
        chart_data = [float(row['Production_2023-24'] or 0) for row in summary_data]
    else:
        labels = []
        chart_data = []

    return render_template('area_summary.html',
                            summary_data=summary_data,
                            table_headers=table_headers,
                            labels=labels,
                            chart_data=chart_data)


# /home/ubuntu/agri-base/app_54.py

# ... (lines 173-220: previous routes) ...

@app.route('/yield_summary')
def yield_summary():
    """Interactive Yield Summary Report."""
    # Assuming 'yield_summery' table exists
    summary_data = query_db("SELECT * FROM yield_summery")
    summary_data = clean_results(summary_data)

    table_headers = []
    labels = []
    chart_data = []

    if summary_data:
        # FIX 1: Get keys from the first row object. Check the list is not empty.
        table_headers = summary_data[0].keys()

        # Iterate over summary_data, accessing elements via row['Key']
        labels = [row['Crop'] for row in summary_data if 'Crop' in row.keys()]

        # FIX 2: Replace .get() with safer direct access and conversion logic.
        chart_data = []
        for row in summary_data:
            production_str = row['2023-24_Production_000_MT'] if '2023-24_Production_000_MT' in row.keys() and row['2023-24_Production_000_MT'] is not None else '0'
            try:
                # Clean up commas and convert to float
                chart_data.append(float(production_str.replace(',', '')))
            except ValueError:
                # Handle cases where data is truly non-numeric
                chart_data.append(0.0)


    return render_template('yield_summary.html',
                            summary_data=summary_data,
                            table_headers=table_headers,
                            labels=labels,
                            chart_data=chart_data)

# ... (Rest of the app remains the same, assuming prior fixes are still in place) ...
@app.route('/crop_analysis', methods=['GET', 'POST'])
def crop_analysis():
    """Crop analysis page to search data by crop and district."""
    districts = get_district_names()
    results = None
    table_headers = []

    if request.method == 'POST':
        selected_crop = request.form.get('crop')
        selected_district = request.form.get('district')

        if selected_crop not in AVAILABLE_MAJOR_CROPS:
            flash(f"Analysis for '{selected_crop}' is not available yet.", 'warning')
            return redirect(url_for('crop_analysis'))

        table_prefix_map = {
            "Aus Rice": "aus",
            "Aman Rice": "aman",
            "Boro Rice": "boro",
            "Wheat": "wheat"
        }
        table_prefix = table_prefix_map.get(selected_crop)
        table_name = "wheat_estimates_district" if table_prefix == "wheat" else f"{table_prefix}_total_by_district"

        query = f"SELECT * FROM {table_name} WHERE District_Division = ?"
        results = query_db(query, [selected_district])

        if results:
            results = clean_results(results)
            # FIX: Get keys from the first row object if the list is not empty
            table_headers = results[0].keys()
        else:
            table_headers = []

    return render_template('crop_analysis.html',
                            crop_hierarchy=CROP_HIERARCHY,
                            districts=districts,
                            results=results,
                            table_headers=table_headers)


@app.route('/top_producers', methods=['GET', 'POST'])
def top_producers():
    """Page to find top producing districts for a crop, or top crops for a district."""
    districts = get_district_names()
    results = None
    result_type = None

    if request.method == 'POST':
        # ... (Top Producers logic - retained from original code) ...
        if 'submit_top_districts' in request.form:
            result_type = 'top_districts'
            crop = request.form.get('crop')
            variety = request.form.get('variety')

            table_prefix_map = {"Aus Rice": "aus", "Aman Rice": "aman", "Boro Rice": "boro"}
            table_prefix = table_prefix_map.get(crop)

            if table_prefix:
                # Note: The table name here might cause an OperationalError if it doesn't exist.
                # Consider using the cleaner naming convention from the last step's utility function
                table_name = f"{table_prefix}_{variety}_by_district"
            elif crop == "Wheat":
                table_name = "wheat_estimates_district"

            query = f"""
                SELECT District_Division, "2023-24_Production_MT"
                FROM {table_name}
                WHERE "2023-24_Production_MT" IS NOT NULL AND "2023-24_Production_MT" != ''
                AND District_Division != 'Bangladesh' AND District_Division NOT LIKE '%Division'
                ORDER BY CAST("2023-24_Production_MT" AS REAL) DESC
                LIMIT 10
            """
            results = query_db(query)
            results = clean_results(results)

        elif 'submit_top_crops' in request.form:
            result_type = 'top_crops'
            district = request.form.get('district')

            query = """
                SELECT 'Aus Rice' AS Crop, CAST("2023-24_Production_MT" AS REAL) AS Production
                FROM aus_total_by_district
                WHERE District_Division = :district
                UNION ALL
                SELECT 'Aman Rice' AS Crop, CAST("2023-24_Production_MT" AS REAL) AS Production
                FROM aman_total_by_district
                WHERE District_Division = :district
                UNION ALL
                SELECT 'Boro Rice' AS Crop, CAST("2023-24_Production_MT" AS REAL) AS Production
                FROM boro_total_by_district
                WHERE District_Division = :district
                UNION ALL
                SELECT 'Wheat' AS Crop, CAST("2023-24_Production_MT" AS REAL) AS Production
                FROM wheat_estimates_district
                WHERE District_Division = :district
                ORDER BY Production DESC
            """
            results = query_db(query, {'district': district})
            results = clean_results(results)

    return render_template('top_crop_district.html',
                            available_crops=AVAILABLE_MAJOR_CROPS,
                            districts=districts,
                            results=results,
                            result_type=result_type)


@app.route('/pie_charts')
def pie_charts():
    """Generates and displays pie charts for all 'pie_' tables."""
    pie_tables = get_pie_chart_tables()
    all_chart_data = []

    for table in pie_tables:
        data = query_db(f"SELECT Category, Percentage FROM {table}")
        data = clean_results(data)
        if data:
            chart_title = table.replace('pie_', '').replace('_', ' ').title() + ' Distribution'
            labels = [row['Category'] for row in data]
            percentages = [float(row['Percentage'] or 0) for row in data]
            all_chart_data.append({
                'title': chart_title,
                'labels': labels,
                'data': percentages,
                'chart_id': f'chart_{table}'
            })

    return render_template('pie_charts.html', all_chart_data=all_chart_data)


# --- AI CHATBOT ROUTES ---

@app.route('/ai_chatbot')
def ai_chatbot():
    """AI Chatbot page"""
    return render_template('ai_chatbot.html')


@app.route('/api/chat', methods=['POST'])
def api_chat():
    """API endpoint implementing an improved RAG logic with casual conversation support."""
    global qa_chain
    user_message = request.json.get('message', '').strip()

    if qa_chain is None:
        return jsonify({"success": False, "message": "AI bot not initialized. Check API key and database files."}), 503
    if not user_message:
        return jsonify({"error": "Empty message"}), 400

    # Handle casual conversation
    if is_casual_conversation(user_message):
        casual_prompt = f"""
        You are a friendly agricultural data assistant. Respond naturally to this casual message:
        User: {user_message}

        Keep it brief and friendly, but mention that you're here to help with agricultural data queries if needed.
        """
        try:
            response = qa_chain.generate_content(casual_prompt)
            return jsonify({
                "success": True,
                "message": response.text.strip(),
                "is_casual": True
            })
        except Exception as e:
            return jsonify({
                "success": False,
                "message": "I apologize, I'm having trouble responding right now. Please try again."
            }), 500

    # Data query processing
    try:
        # Extract crop names from query if present
        crop_pattern = r'\b(rice|wheat|maize|jute|potato|aus|aman|boro)\b'
        crops_mentioned = re.findall(crop_pattern, user_message.lower())

        # Retrieve relevant docs with priority to mentioned crops
        relevant_docs = retrieve_relevant_docs(user_message, top_k=3)
        if crops_mentioned:
            crop_docs = [d for d in relevant_docs if
                        any(crop in d['table'].lower() for crop in crops_mentioned)]
            if crop_docs:
                relevant_docs = crop_docs

        context_snippets = "\n\n".join(
            f"{d['table']} ({d['db']}): {d['sample_text'] or d['schema']}"
            for d in relevant_docs
        )

        sql_prompt = f"""
        You are an expert SQL analyst for agricultural databases. Generate a SELECT query based on:

        Question: {user_message}

        Available Contexts:
        {context_snippets}

        Rules:
        1. Use only SELECT statements
        2. Include LIMIT 20
        3. If searching for crops, use LIKE '%crop_name%' for flexible matching
        4. Use double quotes for identifiers
        5. Join relevant tables if needed
        6. Focus on most recent years (2023-24) when available
        7. Optimize query performance (use indexed columns where possible)

        Return only the SQL query, no explanations.
        """

        sql_response = qa_chain.generate_content(sql_prompt)
        sql_query = sql_response.text.strip()
        sql_query = re.split(r';|\n\n', sql_query)[0].strip()

        # Ensure it's a SELECT query
        if not re.match(r'^\s*SELECT\b', sql_query, re.IGNORECASE):
            return jsonify({
                "success": False,
                "message": "I cannot process that type of query. Please ask about specific agricultural data."
            }), 400

        # Add LIMIT if missing
        if not re.search(r'\bLIMIT\b', sql_query, re.IGNORECASE):
            sql_query = sql_query.rstrip(';') + " LIMIT 20"

        # Execute query against appropriate database(s)
        prefer_db = relevant_docs[0]['path'] if relevant_docs else None
        data_context = get_data_for_rag(sql_query, prefer_db=prefer_db)

        # Generate final response
        final_prompt = f"""
        You are an agricultural expert. Answer based on:

        Question: {user_message}
        Data: {data_context}

        Rules:
        1. Be concise (2-4 sentences)
        2. Cite specific numbers
        3. Mention if data is forecasted
        4. Note any data quality issues
        5. Suggest one relevant follow-up query

        If data is empty/error, suggest how to rephrase the question.
        """

        final_response = qa_chain.generate_content(final_prompt)
        return jsonify({
            "success": True,
            "message": final_response.text.strip(),
            "sql_used": sql_query,
            "context": context_snippets
        })

    except Exception as e:
        print(f"[ERROR] Chatbot processing failed: {str(e)}")
        return jsonify({
            "success": False,
            "message": "I apologize, I had trouble processing that. Please try rephrasing your question about specific agricultural data."
        }), 500


if __name__ == '__main__':
    analyze_and_index_databases()  # Create indices for faster queries
    initialize_qa_chain()
    app.run(debug=True)
