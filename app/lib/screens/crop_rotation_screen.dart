import 'package:flutter/material.dart';
import '../services/crop_rotation_service.dart';

class CropRotationScreen extends StatefulWidget {
  const CropRotationScreen({super.key});

  @override
  State<CropRotationScreen> createState() => _CropRotationScreenState();
}

class _CropRotationScreenState extends State<CropRotationScreen> {
  String selectedCrop = 'rice';
  int rotationYears = 3;
  List<RotationPlan>? rotationPlan;
  bool isLoading = false;
  SoilHealthImpact? soilHealthImpact;

  final List<String> crops = [
    'rice',
    'wheat',
    'potato',
    'maize',
    'lentil',
    'chickpea',
    'tomato',
    'brinjal',
    'mung_bean',
    'peas',
    'beans',
  ];

  void _generateRotation() {
    setState(() => isLoading = true);
    try {
      final plan = CropRotationService.generateRotationPlan(
        selectedCrop,
        rotationYears,
      );

      // Calculate soil health impact for the first rotation transition
      SoilHealthImpact? impact;
      if (plan.length >= 2) {
        impact = CropRotationService.getSoilHealthImpact(
          plan[0].crop,
          plan[1].crop,
        );
      }

      setState(() {
        rotationPlan = plan;
        soilHealthImpact = impact;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _generateRotation();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: const Text('Crop Rotation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Your Crop Rotation',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Crop Selection
                    Text(
                      'Select Starting Crop:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedCrop,
                      isExpanded: true,
                      items: crops.map((crop) {
                        return DropdownMenuItem(
                          value: crop,
                          child: Text(crop.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedCrop = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Years Selection
                    Text(
                      'Rotation Period (years): $rotationYears',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Slider(
                      value: rotationYears.toDouble(),
                      min: 1,
                      max: 6,
                      divisions: 5,
                      onChanged: (value) {
                        setState(() => rotationYears = value.toInt());
                      },
                    ),
                    const SizedBox(height: 16),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _generateRotation,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(
                          isLoading ? 'Generating...' : 'Generate Plan',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Rotation Plan Display
            if (rotationPlan != null) ...[
              Text(
                'Recommended Rotation Plan',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Year by Year Timeline
              ...rotationPlan!.asMap().entries.map((entry) {
                final index = entry.key;
                final plan = entry.value;
                return Column(
                  children: [
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Y${plan.year}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.crop.toUpperCase(),
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        plan.reason,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey[600]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index < rotationPlan!.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Icon(
                          Icons.arrow_downward,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              // Soil Health Impact
              if (soilHealthImpact != null) ...[
                Card(
                  elevation: 2,
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soil Health Impact',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Health Score
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Overall Score:'),
                            Text(
                              '${soilHealthImpact!.soilHealthScore}/100',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: soilHealthImpact!.soilHealthScore / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(
                              Colors.green[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nitrogen Impact
                        Text(
                          'Nitrogen Impact: ${soilHealthImpact!.soilNitrogenImpact > 0 ? '+' : ''}${soilHealthImpact!.soilNitrogenImpact.toStringAsFixed(1)} units',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),

                        // Recommendation
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            soilHealthImpact!.recommendation,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ] else if (!isLoading) ...[
              Center(
                child: Text(
                  'No plan generated yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
