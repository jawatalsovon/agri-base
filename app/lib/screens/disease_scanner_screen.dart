import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/disease_service.dart';
import '../providers/disease_detection_provider.dart';

class DiseaseScannerScreen extends StatefulWidget {
  const DiseaseScannerScreen({super.key});

  @override
  State<DiseaseScannerScreen> createState() => _DiseaseScannerScreenState();
}

class _DiseaseScannerScreenState extends State<DiseaseScannerScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        if (mounted) {
          context.read<DiseaseDetectionProvider>().setImagePath(
            pickedFile.path,
          );
          _analyzeImage(pickedFile.path);
        }
      }
    } catch (e) {
      if (mounted) {
        context.read<DiseaseDetectionProvider>().setError(
          'Error picking image: $e',
        );
      }
    }
  }

  Future<void> _analyzeImage(String imagePath) async {
    try {
      final provider = context.read<DiseaseDetectionProvider>();
      provider.setLoading(true);

      // TODO: Integrate TFLite model for actual inference
      // For now, using mock identification
      await Future.delayed(const Duration(seconds: 2));

      // Mock result - replace with actual model inference
      final detectedKey = DiseaseIdentificationService.identifyDisease(
        imagePath,
        0.95,
      );

      if (mounted) {
        provider.setDetectionResult(detectedKey, 0.95);
        provider.setLoading(false);
      }
    } catch (e) {
      if (mounted) {
        context.read<DiseaseDetectionProvider>().setLoading(false);
        context.read<DiseaseDetectionProvider>().setError(
          'Error analyzing image: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: const Text('🔬 Disease Scanner'),
        elevation: 0,
      ),
      body: Consumer<DiseaseDetectionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to use:',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. Take a clear photo of the affected leaf\n'
                          '2. Ensure good lighting\n'
                          '3. Focus on the disease symptoms\n'
                          '4. Upload the image for analysis',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Image Picker Buttons
                  if (provider.selectedImagePath == null) ...[
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take a Photo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose from Gallery'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ] else ...[
                    // Selected Image Display
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(provider.selectedImagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Loading State
                    if (provider.isLoading) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(
                              'Analyzing image...',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ] else if (provider.errorMessage != null) ...[
                      // Error State
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          provider.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red[900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => provider.reset(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ] else if (provider.detectedDisease != null) ...[
                      // Result State
                      _buildDiseaseResult(
                        context,
                        provider.detectedDisease!,
                        provider.confidence,
                        theme,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => provider.reset(),
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Scan Another Image'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ] else ...[
                      // Initial state after image selection
                      ElevatedButton.icon(
                        onPressed: () =>
                            _analyzeImage(provider.selectedImagePath!),
                        icon: const Icon(Icons.search),
                        label: const Text('Analyze Image'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiseaseResult(
    BuildContext context,
    String diseaseKey,
    double confidence,
    ThemeData theme,
  ) {
    final disease = DiseaseDatabase.getDiseaseInfo(diseaseKey);

    if (disease == null) {
      return Center(
        child: Text(
          'Disease information not found',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Disease Result Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detected: ${disease.diseaseName}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      disease.severity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: confidence,
                backgroundColor: Colors.red[200],
                minHeight: 6,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Disease Details
        _buildDetailSection(
          '📋 Symptoms',
          disease.symptoms,
          Colors.orange,
          theme,
        ),
        const SizedBox(height: 12),

        _buildDetailSection(
          '💊 Treatment Options',
          disease.treatments,
          Colors.green,
          theme,
        ),
        const SizedBox(height: 12),

        _buildDetailSection(
          '🛡️ Prevention Methods',
          disease.prevention,
          Colors.blue,
          theme,
        ),
      ],
    );
  }

  Widget _buildDetailSection(
    String title,
    List<String> items,
    Color accentColor,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•', style: TextStyle(color: accentColor, fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: theme.textTheme.labelSmall),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
