import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show debugPrint;

class Document {
  final String id;
  final String content;
  final String source;
  final Map<String, dynamic>? metadata;
  final List<double>? embedding;

  Document({
    required this.id,
    required this.content,
    required this.source,
    this.metadata,
    this.embedding,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'source': source,
    'metadata': metadata,
    'embedding': embedding,
  };

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json['id'],
    content: json['content'],
    source: json['source'],
    metadata: json['metadata'],
    embedding: (json['embedding'] as List?)?.cast<double>(),
  );
}

class RAGContext {
  final List<Document> relevantDocs;
  final double totalRelevanceScore;
  final String formattedContext;

  RAGContext({
    required this.relevantDocs,
    required this.totalRelevanceScore,
    required this.formattedContext,
  });
}

class RAGService {
  // Simple in-memory vector database (replace with FAISS or Pinecone in production)
  final List<Document> _documents = [];
  final Map<String, List<double>> _embeddings = {};

  static const int maxContextLength = 4096;
  static const double similarityThreshold = 0.3;
  static const int maxResults = 5;

  /// Initialize RAG service with documents
  Future<void> initialize(List<Document> documents) async {
    _documents.clear();
    _embeddings.clear();

    for (var doc in documents) {
      _documents.add(doc);
      if (doc.embedding != null) {
        _embeddings[doc.id] = doc.embedding!;
      }
    }
  }

  /// Add documents to knowledge base
  Future<void> addDocuments(List<Document> documents) async {
    for (var doc in documents) {
      _documents.add(doc);
      if (doc.embedding != null) {
        _embeddings[doc.id] = doc.embedding!;
      }
    }
  }

  /// Generate embedding for text using a simple approach
  /// In production, use: OpenAI, Hugging Face, or local embedding model
  List<double> generateEmbedding(String text) {
    // Simple hash-based embedding (replace with real embeddings!)
    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final embedding = List<double>.filled(384, 0.0); // 384-dim embedding

    for (var word in words) {
      final hash = _simpleHash(word);
      for (int i = 0; i < embedding.length; i++) {
        embedding[i] += (hash ^ i) % 256 / 256.0;
      }
    }

    // Normalize
    final magnitude = math.sqrt(
      embedding.fold<double>(0.0, (sum, val) => sum + val * val),
    );
    if (magnitude > 0) {
      for (int i = 0; i < embedding.length; i++) {
        embedding[i] /= magnitude;
      }
    }

    return embedding;
  }

  int _simpleHash(String str) {
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = ((hash << 5) - hash) + str.codeUnitAt(i);
      hash = hash & hash; // Convert to 32-bit integer
    }
    return hash.abs();
  }

  /// Calculate cosine similarity between two vectors
  double _cosineSimilarity(List<double> vec1, List<double> vec2) {
    if (vec1.length != vec2.length) return 0.0;

    double dotProduct = 0.0;
    double mag1 = 0.0;
    double mag2 = 0.0;

    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      mag1 += vec1[i] * vec1[i];
      mag2 += vec2[i] * vec2[i];
    }

    mag1 = math.sqrt(mag1);
    mag2 = math.sqrt(mag2);

    if (mag1 == 0 || mag2 == 0) return 0.0;
    return dotProduct / (mag1 * mag2);
  }

  /// Retrieve relevant documents for a query
  Future<RAGContext> retrieveContext(String query) async {
    try {
      // Generate query embedding
      final queryEmbedding = generateEmbedding(query);

      // Find most relevant documents
      final relevances = <String, double>{};

      for (var doc in _documents) {
        if (doc.embedding == null) continue;

        final similarity = _cosineSimilarity(queryEmbedding, doc.embedding!);

        if (similarity > similarityThreshold) {
          relevances[doc.id] = similarity;
        }
      }

      // Sort by relevance and take top results
      final topDocs = relevances.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final selectedDocs = topDocs
          .take(maxResults)
          .map((entry) => _documents.firstWhere((doc) => doc.id == entry.key))
          .toList();

      // Format context
      final context = _formatContext(selectedDocs);
      final totalScore = topDocs.isEmpty ? 0.0 : topDocs.first.value;

      return RAGContext(
        relevantDocs: selectedDocs,
        totalRelevanceScore: totalScore,
        formattedContext: context,
      );
    } catch (e) {
      debugPrint('Error retrieving context: $e');
      return RAGContext(
        relevantDocs: [],
        totalRelevanceScore: 0.0,
        formattedContext: '',
      );
    }
  }

  /// Format context for LLM prompt
  String _formatContext(List<Document> docs) {
    if (docs.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('# Agricultural Knowledge Base');
    buffer.writeln('');

    for (var (index, doc) in docs.indexed) {
      buffer.writeln('## Source ${index + 1}: ${doc.source}');
      buffer.writeln(doc.content);
      buffer.writeln('');
    }

    // Truncate if too long
    final context = buffer.toString();
    if (context.length > maxContextLength) {
      return '${context.substring(0, maxContextLength)}\n...';
    }

    return context;
  }

  /// Build RAG-enhanced prompt for LLM
  Future<String> buildRAGPrompt(String userQuestion) async {
    final ragContext = await retrieveContext(userQuestion);

    final prompt = StringBuffer();
    prompt.writeln('You are an agricultural expert chatbot for Bangladesh.');
    prompt.writeln(
      'Use the following agricultural knowledge to answer the user\'s question.',
    );
    prompt.writeln('');
    prompt.writeln('# Context from Agricultural Database:');
    prompt.writeln(ragContext.formattedContext);
    prompt.writeln('');
    prompt.writeln('# User Question:');
    prompt.writeln(userQuestion);
    prompt.writeln('');
    prompt.writeln('# Instructions:');
    prompt.writeln(
      '- Provide accurate agricultural advice based on the context',
    );
    prompt.writeln('- If information is not in the context, say so clearly');
    prompt.writeln('- Include specific details (crop names, rates, timing)');
    prompt.writeln('- Cite sources when possible');
    prompt.writeln('- Write in a friendly, helpful tone for farmers');

    return prompt.toString();
  }

  /// Load documents from JSON file
  Future<void> loadFromJson(String jsonContent) async {
    try {
      final data = jsonDecode(jsonContent) as List;
      final docs = data
          .map((item) => Document.fromJson(item as Map<String, dynamic>))
          .toList();
      await initialize(docs);
    } catch (e) {
      debugPrint('Error loading documents from JSON: $e');
    }
  }

  /// Export documents to JSON
  Future<String> exportToJson() async {
    final json = _documents.map((doc) => doc.toJson()).toList();
    return jsonEncode(json);
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    return {
      'total_documents': _documents.length,
      'documents_with_embeddings': _embeddings.length,
      'total_content_size': _documents.fold<int>(
        0,
        (sum, doc) => sum + doc.content.length,
      ),
    };
  }
}

/// Knowledge base documents for agricultural topics
class AgriculturalKnowledgeBase {
  static List<Document> getInitialDocuments() {
    return [
      Document(
        id: 'rice_cultivation_1',
        content: '''
Rice Cultivation Guide for Bangladesh

Soil Preparation:
- Plow field 3-4 times for fine tilth
- Add 2-3 inches of water before puddling
- Optimal pH: 6.5-7.5

Seed Selection:
- Use certified seeds, treated with fungicide
- Seed rate: 40 kg/hectare for broadcast
- Soak seeds for 24-36 hours before planting

Fertilizer Management:
- Nitrogen: 110-140 kg/ha (split application)
- Phosphorus: 25-30 kg/ha
- Potassium: 30-40 kg/ha
- Apply 1/3 N at land prep, 1/3 at tillering, 1/3 at panicle initiation

Pest & Disease Management:
- Rice Blast: Use Tricyclazole @ 1.5 g/liter
- Brown Spot: Apply Carbendazim @ 1 g/liter
- Stem Borer: Use Cypermethrin spray

Harvesting:
- Harvest when 80% grains are golden brown
- Cut at 25-30 cm height to preserve stubble
- Dry to 12-15% moisture before storage
        ''',
        source: 'BARC Rice Cultivation Handbook',
        metadata: {'crop': 'rice', 'region': 'Bangladesh', 'year': 2024},
      ),
      Document(
        id: 'wheat_cultivation_1',
        content: '''
Wheat Cultivation Guide for Bangladesh

Best Time to Sow:
- Rabi season: November to December
- Optimal soil temperature: 20-25°C

Field Preparation:
- Well-drained loamy soil
- 2-3 plowings for good tilth
- Add compost/manure 5 tons/hectare

Seed Rate & Sowing:
- Seed rate: 100-125 kg/hectare
- Line sowing preferred over broadcast
- Spacing: 20-25 cm between rows

Fertilizer Management:
- Nitrogen: 120 kg/ha
- Phosphorus: 60 kg/ha
- Potassium: 40 kg/ha
- Split N: 50% at sowing, 50% at tillering

Water Management:
- 4-5 irrigations total
- First irrigation at 21-25 DAS (Danger of Stem Elongation)
- Critical stages: Tillering, Flowering, Grain filling

Weed Management:
- Remove weeds at 30-35 DAS
- 2-3 manual weeding required
- Herbicides can be used for better control

Diseases & Pests:
- Powdery Mildew: Sulfur powder @ 5-6 kg/ha
- Loose Smut: Treat seeds with Carbendazim
- Armyworm: Use Cypermethrin spray
        ''',
        source: 'BARC Wheat Cultivation Handbook',
        metadata: {'crop': 'wheat', 'region': 'Bangladesh', 'season': 'Rabi'},
      ),
      Document(
        id: 'potato_cultivation_1',
        content: '''
Potato Cultivation Guide for Bangladesh

Soil Requirements:
- Well-drained, loose soil
- pH: 5.5-7.0 (slightly acidic)
- Sandy loam or loam soil preferred

Seed & Planting:
- Use certified seed potatoes (25-30 g weight)
- Seed rate: 2.5-3 tons/hectare
- Plant spacing: 20 cm between plants, 60 cm between rows
- Planting depth: 5-7 cm

Fertilizer Management:
- Very heavy nutrient feeder
- Nitrogen: 150 kg/ha
- Phosphorus: 100 kg/ha
- Potassium: 120 kg/ha (crucial for tuber quality)
- Add 15-20 tons compost/hectare
- Apply all P & K at planting, N in split doses

Irrigation:
- 8-10 irrigations needed
- Critical stages: Plant emergence, tuber initiation, tuber bulking
- Avoid waterlogging - causes diseases

Disease Management:
- Late Blight: Mancozeb 75% @ 2.5 g/liter or Metalaxyl + Mancozeb
- Early Blight: Chlorothalonil or Mancozeb
- Bacterial Wilt: Use disease-free seed, crop rotation
- Virus: Use resistant varieties, control aphids

Harvesting:
- 80-120 days after planting (depending on variety)
- Harvest when plants dry down
- Handle tubers carefully to avoid bruising
- Store at 4°C for long-term storage
        ''',
        source: 'BARC Potato Cultivation Handbook',
        metadata: {'crop': 'potato', 'region': 'Bangladesh', 'season': 'Rabi'},
      ),
      Document(
        id: 'soil_management_1',
        content: '''
Soil Management for Sustainable Agriculture

Soil Testing:
- Test soil every 2-3 years
- Check pH, N, P, K, organic matter, micronutrients
- Adjust fertilizer based on soil test results
- Send samples to nearest SRDI office

Organic Matter Management:
- Maintain 2-3% organic matter in soil
- Add compost, farm yard manure, crop residues
- Helps improve soil structure and water retention
- Reduces fertilizer requirements by 20-30%

Crop Rotation:
- Never grow same crop repeatedly
- Alternate cereals with legumes
- Legumes (lentil, chickpea) add nitrogen
- Rotation reduces pest & disease pressure
- Example: Rice → Lentil → Wheat cycle

Soil Conservation:
- Prevent soil erosion on slopes
- Use mulching to conserve moisture
- Avoid excessive tillage
- Maintain crop residues for soil cover

Micronutrient Management:
- Zinc: Apply 10-15 kg/ha for rice
- Boron: 2-3 kg/ha for mustard
- Iron: Chelated form for alkaline soils
- Apply through soil or foliar spray
        ''',
        source: 'Soil Science & Agricultural Extension',
        metadata: {'topic': 'soil_management', 'year': 2024},
      ),
      Document(
        id: 'crop_rotation_1',
        content: '''
Crop Rotation Systems for Bangladesh

Benefits:
- Improves soil fertility (especially with legumes)
- Breaks pest and disease cycles
- Reduces herbicide requirements
- Improves soil structure and water retention
- Increases farm profitability

Common Rotation Patterns:

1. Rice-Legume-Wheat (3-year):
   - Rice (Kharif/Aman) → Lentil/Chickpea (Rabi) → Wheat (Rabi)
   - High productivity, N-efficient

2. Rice-Maize-Pulse (3-year):
   - Rice → Maize → Lentil/Chickpea
   - Good for higher rainfall areas

3. Potato-Based System:
   - Potato (Rabi) → Summer Vegetables → Rice
   - High value crops, needs careful planning

4. Vegetable Rotation (for intensive farming):
   - Tomato → Leafy vegetables → Cucurbits
   - Alternate with pulses for soil recovery

Planning Rotation:
- Draw field map noting soil type & history
- Select crops suitable for your soil & climate
- Ensure crop diversity for food security
- Plan 3-5 year rotation plan
- Keep records of crop history

Crop Compatibility:
- Previous crop → Recommended next crop
- Heavy feeders (rice, wheat, potato) → Follow with legumes
- Legumes → Follow with cereals
- Avoid same crop family consecutively
        ''',
        source: 'BARC Crop Rotation Guide',
        metadata: {'topic': 'crop_rotation', 'region': 'Bangladesh'},
      ),
    ];
  }
}
