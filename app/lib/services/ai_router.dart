import 'dart:convert';

import 'package:flutter/material.dart';

import 'db_service.dart';
import 'gemini_client.dart';

/// Types of questions the assistant can handle.
enum AiQueryType { dbQuery, webKnowledge, mixed }

/// Result of an assistant interaction.
class AiResponse {
  AiResponse({required this.answer, this.sqlUsed, this.queryType});

  final String answer;
  final String? sqlUsed;
  final AiQueryType? queryType;
}

/// High‑level orchestrator that decides when to use the DB vs Gemini only,
/// and wires together SQL generation, execution, and final answer.
class AiRouter {
  AiRouter._();

  static final AiRouter instance = AiRouter._();

  final GeminiClient _gemini = GeminiClient.instance;
  final DbService _db = DbService.instance;

  // Short, hand‑written schema summary that roughly mirrors what the Flask app
  // exposes to Gemini. This can be refined over time.
  static const String _schemaSummary = '''
IMPORTANT RULES:
1. Do NOT use database prefixes like "crops.crop_data" or "attempt.area_summary".
   SQLite does not support that syntax. Use table names directly: "crop_data", "area_summary", etc.
2. Use SINGLE QUOTES for string literals, NOT double quotes.
   Correct: WHERE year = '2023-24'
   Wrong: WHERE year = "2023-24" (SQLite treats double quotes as identifiers/column names)

Available tables in crops.db (use table names directly, no database prefix):

1. crop_data table:
   - Columns: crop_name (TEXT), district (TEXT), year (TEXT), hectares (REAL), production_mt (REAL)
   - Year format: stored as strings like '2016-17', '2017-18', '2023-24' (with dashes)
   - Example query: SELECT crop_name, SUM(production_mt) as total FROM crop_data WHERE year = '2023-24' GROUP BY crop_name ORDER BY total DESC

2. crop_predictions table:
   - Columns: crop_name (TEXT), district (TEXT), area_hectares_pred (REAL), production_mt_pred (REAL)
   - No year column (predictions are for next year, typically 2025)
   - Example query: SELECT crop_name, SUM(production_mt_pred) as total FROM crop_predictions GROUP BY crop_name ORDER BY total DESC

3. yield_summary table:
   - Columns: crop (TEXT), plus year-specific columns like:
     * 2021-22_Area, 2021-22_Per_Acre_Yield_Kg, 2021-22_Production_MT
     * 2022-23_Area, 2022-23_Per_Acre_Yield_Kg, 2022-23_Production_MT
     * 2023-24_Area, 2023-24_Per_Acre_Yield_Kg, 2023-24_Production_MT
   - Best table for "which crop did best in 2023-24" queries
   - Example query: SELECT crop, "2023-24_Production_MT" FROM yield_summary WHERE "2023-24_Production_MT" IS NOT NULL ORDER BY "2023-24_Production_MT" DESC LIMIT 10
   - Note: Column names with dashes must be in double quotes, but VALUES use single quotes

4. area_summary table:
   - Columns: crop (TEXT), plus year-specific columns like:
     * Area_2019-20, Area_2020-21, Area_2021-22, Area_2022-23, Area_2023-24
     * Production_2019-20, Production_2020-21, Production_2021-22, Production_2022-23, Production_2023-24
   - Example query: SELECT crop, "Production_2023-24" FROM area_summary WHERE "Production_2023-24" IS NOT NULL ORDER BY "Production_2023-24" DESC

Year format notes:
- In crop_data: year values are strings like '2023-24' (use single quotes: WHERE year = '2023-24')
- In yield_summary and area_summary: year is in column names like "2023-24_Production_MT" (use double quotes for column names)
- For "which crop did best in 2023-24", prefer yield_summary table with column "2023-24_Production_MT"
''';

  /// Entry point used by the UI.
  Future<AiResponse> handleUserMessage(String message, {Locale? locale}) async {
    if (message.trim().isEmpty) {
      return AiResponse(answer: 'Please type a question to ask AgriBase AI.');
    }

    final languageCode = locale?.languageCode;
    final type = _classify(message);

    switch (type) {
      case AiQueryType.webKnowledge:
        final ans = await _gemini.askGeneral(message, languageCode: languageCode);
        return AiResponse(answer: ans, queryType: type);
      case AiQueryType.dbQuery:
      case AiQueryType.mixed:
        final sql = await _gemini.generateSql(
          userMessage: message,
          schemaSummary: _schemaSummary,
          languageCode: languageCode,
        );
        if (sql == null) {
          // Fall back to general explanation if SQL generation fails.
          final fallback = await _gemini.askGeneral(
            '$message (Note: database lookup failed, give a general explanation instead.)',
            languageCode: languageCode,
          );
          return AiResponse(answer: fallback, sqlUsed: null, queryType: type);
        }

        final safeSql = _makeSafeSelect(sql);
        final rows = await _db.smartQuery(safeSql);

        if (rows.isEmpty) {
          final noDataAnswer = await _gemini.answerWithContext(
            userMessage: message,
            sql: safeSql,
            dbResultSummary: 'No data rows were returned for this query.',
            languageCode: languageCode,
          );
          return AiResponse(
            answer: noDataAnswer,
            sqlUsed: safeSql,
            queryType: type,
          );
        }

        final trimmedSummary = _summarizeRows(rows);

        final finalAnswer = await _gemini.answerWithContext(
          userMessage: message,
          sql: safeSql,
          dbResultSummary: trimmedSummary,
          languageCode: languageCode,
        );

        return AiResponse(
          answer: finalAnswer,
          sqlUsed: safeSql,
          queryType: type,
        );
    }
  }

  /// Very lightweight intent detection to decide if we should hit the DB.
  AiQueryType _classify(String message) {
    final m = message.toLowerCase();
    final dbHints = [
      'which crop',
      'production',
      'yield',
      'area',
      'hectare',
      'ton',
      'mt',
      'statistics',
      'data',
      'from 2017',
      'from 2018',
      'from 2019',
      'from 2020',
      'from 2021',
      'from 2022',
      'from 2023',
      'from 2024',
      '2024',
      '2017',
      '2018',
      '2019',
      '2020',
      '2021',
      '2022',
      '2023',
      'attempt.db',
      'prediction',
      'forecast',
    ];

    final webHints = [
      'how to',
      'irrigate',
      'fertilizer',
      'sow',
      'planting',
      'disease',
      'pest',
      'control',
      'weather',
      'climate',
      'best practice',
    ];

    final hitsDb = dbHints.any(m.contains);
    final hitsWeb = webHints.any(m.contains);

    if (hitsDb && hitsWeb) return AiQueryType.mixed;
    if (hitsDb) return AiQueryType.dbQuery;
    if (hitsWeb) return AiQueryType.webKnowledge;

    // Default to DB for numeric/year questions, else web.
    final hasYear = RegExp(r'20(1[7-9]|2[0-9])').hasMatch(m);
    if (hasYear) return AiQueryType.dbQuery;
    return AiQueryType.webKnowledge;
  }

  /// Ensure the SQL is SELECT‑only and add a LIMIT if missing.
  /// Also removes any database prefixes and fixes string literal quotes.
  String _makeSafeSelect(String sql) {
    var s = sql.trim();
    // Keep only the first statement.
    if (s.contains(';')) {
      s = s.split(';').first.trim();
    }

    // Remove database prefixes like "crops.crop_data" -> "crop_data"
    // Match patterns like: database_name.table_name or "database_name"."table_name"
    // Handle both quoted and unquoted cases
    s = s.replaceAllMapped(RegExp(r'(\w+)\.(\w+)', caseSensitive: false), (
      match,
    ) {
      // Keep only the table name (second group)
      return match.group(2) ?? match.group(0)!;
    });
    // Also handle quoted cases like "crops"."crop_data"
    s = s.replaceAllMapped(RegExp(r'"(\w+)"\."(\w+)"', caseSensitive: false), (
      match,
    ) {
      // Keep only the table name (second group) with quotes
      return '"${match.group(2) ?? match.group(0)!}"';
    });

    // Fix string literals: convert double-quoted string VALUES to single quotes
    // SQLite uses single quotes for string literals, double quotes for identifiers
    // Pattern: WHERE column = "value" or LIKE "value%" or IN ("val1", "val2")
    // But preserve double quotes for column names (they appear in SELECT, WHERE column comparisons)

    // Strategy: Convert double-quoted strings that appear after operators or look like year values
    // Convert double-quoted values after operators (=, LIKE, !=, <>, IS, IS NOT)
    s = s.replaceAllMapped(
      RegExp(
        r'(\s*(?:=|LIKE|!=|<>|IS|IS NOT)\s+)"([^"]+)"',
        caseSensitive: false,
      ),
      (match) {
        // Convert double-quoted value to single-quoted
        return '${match.group(1)}\'${match.group(2)}\'';
      },
    );

    // Convert double-quoted year values (e.g., "2023-24", "2017-18") anywhere in WHERE clause
    s = s.replaceAllMapped(
      RegExp(r'(\s+)"([0-9]{4}-[0-9]{2})"', caseSensitive: false),
      (match) {
        return '${match.group(1)}\'${match.group(2)}\'';
      },
    );

    // Convert double-quoted values in IN clauses: IN ("val1", "val2")
    // Match the entire IN clause and replace quotes inside
    s = s.replaceAllMapped(
      RegExp(r'(IN\s*\()([^)]+)(\))', caseSensitive: false),
      (match) {
        var inContent = match.group(2)!;
        // Replace double quotes with single quotes in the IN clause content
        var fixedContent = inContent.replaceAll('"', '\'');
        return '${match.group(1)}$fixedContent${match.group(3)}';
      },
    );

    final upper = s.toUpperCase();
    if (!upper.startsWith('SELECT')) {
      throw ArgumentError('Only SELECT statements are allowed.');
    }
    // Block obvious modification / pragma commands.
    final forbidden = [
      'INSERT ',
      'UPDATE ',
      'DELETE ',
      'DROP ',
      'ALTER ',
      'PRAGMA ',
    ];
    for (final bad in forbidden) {
      if (upper.contains(bad)) {
        throw ArgumentError('Unsafe SQL detected.');
      }
    }

    if (!RegExp(r'\bLIMIT\b', caseSensitive: false).hasMatch(upper)) {
      s = '$s LIMIT 50';
    }

    return s;
  }

  /// Convert rows into a compact JSON‑like string, truncated to a safe size.
  String _summarizeRows(List<Map<String, Object?>> rows) {
    const maxRows = 50;
    final limited = rows.length > maxRows ? rows.sublist(0, maxRows) : rows;

    final jsonText = const JsonEncoder.withIndent('  ').convert(limited);
    if (jsonText.length <= 4000) {
      return jsonText;
    }

    // If still huge, truncate the string.
    return '${jsonText.substring(0, 4000)}\n... (truncated)';
  }
}
