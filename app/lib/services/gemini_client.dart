import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

/// Centralized Gemini client used by the AI assistant.
///
class GeminiClient {
  GeminiClient._()
    : _apiKey = "AIzaSyANgbRULiznrCqKcKqHLo7pqneL1UujG0k",
      _model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: "AIzaSyANgbRULiznrCqKcKqHLo7pqneL1UujG0k",
      );

  static final GeminiClient instance = GeminiClient._();

  final String _apiKey;
  final GenerativeModel _model;

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Ask a general knowledge / web-style question (no DB context).
  Future<String> askGeneral(String userMessage) async {
    if (!isConfigured) {
      return 'AI is not configured.';
    }

    try {
      final response = await _model.generateContent([
        Content.text('''
You are AgriBase AI, an agricultural assistant focused on Bangladesh context.
Give practical, concise guidance (3–6 sentences). 
Explain clearly and avoid overly technical language unless needed.
User question: $userMessage
'''),
      ]);

      return response.text?.trim().isNotEmpty == true
          ? response.text!.trim()
          : 'I could not generate an answer. Please try rephrasing your question.';
    } catch (e) {
      return 'There was a problem contacting the AI service: $e';
    }
  }

  /// Ask Gemini to generate a single safe SQLite SELECT query based on the user question
  /// and a compressed schema description.
  Future<String?> generateSql({
    required String userMessage,
    required String schemaSummary,
  }) async {
    if (!isConfigured) {
      return null;
    }

    final prompt =
        '''
You are an expert SQLite analyst for an agricultural database.
Based on the user's question and the database schema, produce ONE runnable
SQLite SELECT statement only. No comments, no explanations, no text around it.

SCHEMA (short):
$schemaSummary

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

User question: $userMessage

SQL (table name only, no database prefix, single quotes for string values):
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final raw = response.text ?? '';
      final sql = raw.split(';').first.trim();
      if (!sql.toUpperCase().startsWith('SELECT')) {
        return null;
      }
      return sql;
    } catch (_) {
      return null;
    }
  }

  /// Turn a user question + SQL + DB result into a final, user-facing answer.
  Future<String> answerWithContext({
    required String userMessage,
    required String sql,
    required String dbResultSummary,
  }) async {
    if (!isConfigured) {
      return 'AI is not configured.';
    }

    final prompt =
        '''
You are AgriBase AI, an agricultural consultant.
Use the RETRIEVED DATA to answer the question. Keep it brief (3–6 sentences),
cite concrete numbers where possible, and mention if they are forecasts or
historical values. If the data looks partial or noisy, say so.

QUESTION:
$userMessage

SQL USED:
$sql

RETRIEVED DATA (tabular text or JSON-like):
$dbResultSummary

Answer:
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim().isNotEmpty == true
          ? response.text!.trim()
          : 'I could not interpret the retrieved data clearly enough to answer. Please try rephrasing.';
    } catch (e) {
      return 'There was a problem generating the answer from data: $e';
    }
  }
}
