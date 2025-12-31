import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../../models/district_data.dart';

// Ensure you have these dependencies in pubspec.yaml:
// syncfusion_flutter_maps: ^latest_version
// syncfusion_flutter_core: ^latest_version

// ============== Interactive Bangladesh Map (Selectable Version) ==============
class InteractiveBangladeshMap extends StatefulWidget {
  final String selectedCrop;
  final Map<String, Map<String, DistrictData>> districtDataMap;

  const InteractiveBangladeshMap({
    super.key,
    required this.selectedCrop,
    required this.districtDataMap,
  });

  @override
  State<InteractiveBangladeshMap> createState() =>
      _InteractiveBangladeshMapState();
}

class _InteractiveBangladeshMapState extends State<InteractiveBangladeshMap> {
  List<DistrictData> _dataList = [];
  MapShapeSource? _shapeSource;
  late MapZoomPanBehavior _zoomPanBehavior;

  // Track the currently selected district index
  int _selectedIndex = -1;
  
  // Min and max production values for UV map normalization
  double _minProduction = 0.0;
  double _maxProduction = 0.0;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = MapZoomPanBehavior(
      enableDoubleTapZooming: true,
      enablePanning: true,
      enablePinching: true,
      zoomLevel: 1.0,
      minZoomLevel: 1.0,
      maxZoomLevel: 10.0,
    );
    _updateMapSource();
  }

  @override
  void didUpdateWidget(covariant InteractiveBangladeshMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCrop != widget.selectedCrop ||
        oldWidget.districtDataMap != widget.districtDataMap) {
      _updateMapSource();
    }
  }

  void _updateMapSource() {
    final cropData = widget.districtDataMap[widget.selectedCrop] ?? {};
    _dataList = cropData.values.toList();
<<<<<<< HEAD
    
    // Calculate min and max production for UV map normalization
    if (_dataList.isNotEmpty) {
      _minProduction = _dataList.map((d) => d.production).reduce((a, b) => a < b ? a : b);
      _maxProduction = _dataList.map((d) => d.production).reduce((a, b) => a > b ? a : b);
      // Handle edge case where all values are the same
      if (_maxProduction == _minProduction) {
        _maxProduction = _minProduction + 1.0;
      }
    }
    
=======

>>>>>>> 373ec917e154a3d53ab357e30d607728e6c04117
    // Reset selection when crop changes
    _selectedIndex = -1;
    _rebuildShapeSource();
  }

  void _rebuildShapeSource() {
    // Only create shape source if we have data
    if (_dataList.isEmpty) {
      return;
    }

    _shapeSource = MapShapeSource.asset(
      'assets/json/bd.geojson',

      // --- FIX IS HERE ---
      // Your JSON uses "adm2_name" for the district name (e.g. "Barguna")
      shapeDataField: 'adm2_name',

      // -------------------
      dataCount: _dataList.length,
      primaryValueMapper: (index) => _dataList[index].name,
<<<<<<< HEAD
      
      // UV Map Color Logic - White to Green gradient based on normalized values
=======

      // Color Logic
>>>>>>> 373ec917e154a3d53ab357e30d607728e6c04117
      shapeColorValueMapper: (index) {
        if (index == _selectedIndex) {
          return const Color(0xFFFFD600); // Yellow when selected
        }

        final production = _dataList[index].production;
        
        // Normalize production value to 0-1 range
        final normalized = (production - _minProduction) / (_maxProduction - _minProduction);
        // Clamp to ensure it's between 0 and 1
        final clamped = normalized.clamp(0.0, 1.0);
        
        // Interpolate from white (0.0) to dark green (1.0)
        // White: Color(0xFFFFFFFF) -> Light Green -> Dark Green: Color(0xFF1B5E20)
        return Color.lerp(
          Colors.grey[300], // White
          const Color(0xFF1B5E20),  // Dark Green
          clamped,
        ) ?? const Color(0xFFA5D6A7); // Fallback to light green
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading/empty state if no data
    if (_dataList.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 400,
          color: Colors.blue[50],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading district data...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 400,
            color: Colors.blue[50],
            child: _shapeSource == null
                ? const Center(child: CircularProgressIndicator())
                : SfMaps(
                    layers: [
                      MapShapeLayer(
                        source: _shapeSource!,
                        zoomPanBehavior: _zoomPanBehavior,

                        strokeColor: Colors.white,
                        strokeWidth: 0.6,
                        color: Colors
                            .grey[300], // Fallback color for unmatched districts
                        // --- SELECTION HANDLING ---
                        selectedIndex: _selectedIndex,
                        onSelectionChanged: (int index) {
                          setState(() {
                            // Toggle selection
                            if (_selectedIndex == index) {
                              _selectedIndex = -1; // Deselect if tapped again
                            } else {
                              _selectedIndex = index;
                            }
                            // Rebuild the source to apply the new "Yellow" color
                            _rebuildShapeSource();
                          });
                        },

<<<<<<< HEAD
                  // --- TOOLTIP ---
                  showDataLabels: false,
                  shapeTooltipBuilder: (BuildContext context, int index) {
                    final data = _dataList[index];
                    return IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const Divider(color: Colors.white24, height: 12),
                            Text('Production: ${(data.production / 1000).toStringAsFixed(0)}k MT', style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text('Yield: ${data.yieldValue.toStringAsFixed(2)} MT/Ha', style: const TextStyle(color: Colors.white70)),
                            if (data.percentage != null) ...[
                              const SizedBox(height: 4),
                              Text('Contribution: ${data.percentage!.toStringAsFixed(2)}%', style: const TextStyle(color: Colors.white70)),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
=======
                        // --- TOOLTIP ---
                        showDataLabels: false,
                        shapeTooltipBuilder: (BuildContext context, int index) {
                          final data = _dataList[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(
                                  color: Colors.white24,
                                  height: 12,
                                ),
                                Text(
                                  'Production: ${(data.production / 1000).toStringAsFixed(0)}k MT',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Yield: ${data.yieldValue.toStringAsFixed(2)} MT/Ha',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                if (data.percentage != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Contribution: ${data.percentage!.toStringAsFixed(2)}%',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
>>>>>>> 373ec917e154a3d53ab357e30d607728e6c04117
          ),

          // --- SELECTED DISTRICT INFO PANEL (Appears below map when selected) ---
          if (_selectedIndex != -1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dataList[_selectedIndex].name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        "Production",
                        "${(_dataList[_selectedIndex].production / 1000).toStringAsFixed(1)}k MT",
                      ),
                      _buildInfoItem(
                        "Yield",
                        "${_dataList[_selectedIndex].yieldValue} T/Ha",
                      ),
                      _buildInfoItem(
                        "Coordinates",
                        "${_dataList[_selectedIndex].lat.toStringAsFixed(2)}, ${_dataList[_selectedIndex].long.toStringAsFixed(2)}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
