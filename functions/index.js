const functions = require('firebase-functions');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(functions.config().gemini.api_key);

exports.askGemini = functions.https.onCall(async (data, context) => {
  const userMessage = data.message;
  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash-lite' });

  const prompt = `
You are AgriBase AI, an agricultural assistant focused on Bangladesh context.
Give practical, concise guidance (3–6 sentences).
Explain clearly and avoid overly technical language unless needed.
User question: ${userMessage}
`;

  try {
    const result = await model.generateContent(prompt);
    const response = result.response.text();
    return { response: response.trim() || 'I could not generate an answer. Please try rephrasing your question.' };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'AI service error: ' + error.message);
  }
});

exports.generateSql = functions.https.onCall(async (data, context) => {
  const { userMessage, schemaSummary } = data;
  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash-lite' });

  const prompt = `
You are an expert SQLite analyst for an agricultural database.
Based on the user's question and the database schema, produce ONE runnable
SQLite SELECT statement only. No comments, no explanations, no text around it.

SCHEMA (short):
${schemaSummary}

CRITICAL RULES:
- Only SELECT; never modify data (no INSERT/UPDATE/DELETE/PRAGMA).
- NEVER use database prefixes like "crops.crop_data" or "attempt.area_summary"
- Use table names directly: "crop_data", "area_summary", etc. (no prefix before the dot)
- Use SINGLE QUOTES for string literals/values: WHERE year = '2023-24' (NOT double quotes)
- Use DOUBLE QUOTES only for column names with special characters: SELECT "2023-24_Production_MT"
- Prefer tables that clearly relate to the question's year and crop.
- For "which crop did best in 2023-24": use yield_summary table with column "2023-24_Production_MT"
- For year values in crop_data: use WHERE year = '2023-24' (single quotes for the value)
- If joining or aggregating is unclear, choose the simplest useful query.

User question: ${userMessage}

SQL (table name only, no database prefix, single quotes for string values):
`;

  try {
    const result = await model.generateContent(prompt);
    const raw = result.response.text();
    const sql = raw.split(';')[0].trim();
    if (!sql.toUpperCase().startsWith('SELECT')) {
      return { sql: null };
    }
    return { sql };
  } catch (error) {
    return { sql: null };
  }
});

exports.answerWithContext = functions.https.onCall(async (data, context) => {
  const { userMessage, sql, dbResultSummary } = data;
  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash-lite' });

  const prompt = `
You are AgriBase AI, an agricultural consultant.
Use the RETRIEVED DATA to answer the question. Keep it brief (3–6 sentences),
cite concrete numbers where possible, and mention if they are forecasts or
historical values. If the data looks partial or noisy, say so.

QUESTION:
${userMessage}

SQL USED:
${sql}

RETRIEVED DATA (tabular text or JSON-like):
${dbResultSummary}

Answer:
`;

  try {
    const result = await model.generateContent(prompt);
    const response = result.response.text();
    return { response: response.trim() || 'I could not interpret the retrieved data clearly enough to answer. Please try rephrasing.' };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'AI service error: ' + error.message);
  }
});
