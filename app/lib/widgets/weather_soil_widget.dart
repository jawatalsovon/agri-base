import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/soil_service.dart';

class WeatherSoilWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const WeatherSoilWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  @override
  State<WeatherSoilWidget> createState() => _WeatherSoilWidgetState();
}

class _WeatherSoilWidgetState extends State<WeatherSoilWidget> {
  late WeatherService weatherService;
  late SoilService soilService;
  WeatherData? weatherData;
  SoilData? soilData;
  bool isLoading = true;
  String errorMessage = '';
  bool showSoil = false;

  // Default: Dhaka coordinates
  late double latitude;
  late double longitude;
  late String locationName;

  @override
  void initState() {
    super.initState();
    weatherService = WeatherService();
    soilService = SoilService();

    latitude = widget.latitude ?? 23.8103;
    longitude = widget.longitude ?? 90.4125;
    locationName = widget.locationName ?? 'Dhaka';

    _loadWeatherAndSoilData();
  }

  Future<void> _loadWeatherAndSoilData() async {
    try {
      setState(() => isLoading = true);

      // Fetch both weather and soil data
      final weather = await weatherService.fetchWeatherForecast(
        latitude,
        longitude,
        location: locationName,
      );

      final soil = await soilService.fetchSoilData(latitude, longitude);

      setState(() {
        weatherData = weather;
        soilData = soil;
        isLoading = false;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🌤️ Weather & Soil',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadWeatherAndSoilData,
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (isLoading)
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Loading weather & soil data...',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else if (errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.orange.shade900),
              ),
            )
          else ...[
            // Toggle Button
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => showSoil = false),
                      icon: const Icon(Icons.cloud),
                      label: const Text('7-Day Forecast'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !showSoil
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        foregroundColor: !showSoil
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => showSoil = true),
                      icon: const Icon(Icons.landscape),
                      label: const Text('Soil Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showSoil
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        foregroundColor: showSoil ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Weather Data
            if (!showSoil && weatherData != null)
              _buildWeatherForecast(context, theme)
            else if (showSoil && soilData != null)
              _buildSoilData(context, theme)
            else
              Center(
                child: Text(
                  showSoil
                      ? 'Soil data unavailable'
                      : 'Weather data unavailable',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeatherForecast(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📍 $locationName - 7 Day Forecast',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weatherData!.dailyForecasts.length,
            itemBuilder: (context, index) {
              final forecast = weatherData!.dailyForecasts[index];
              final date = DateTime.parse(forecast.date);
              final dayName = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ][date.weekday % 7];
              final dayDate = '${date.day}/${date.month}';

              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(dayDate, style: theme.textTheme.labelSmall),
                    Text(
                      forecast.getWeatherIcon(),
                      style: const TextStyle(fontSize: 32),
                    ),
                    Text(
                      forecast.getWeatherDescription(),
                      style: theme.textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                    Column(
                      children: [
                        Text(
                          '${forecast.maxTemp.toStringAsFixed(0)}°C',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${forecast.minTemp.toStringAsFixed(0)}°C',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '💧 ${forecast.precipitationProbability}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
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
                '📊 Farming Tips:',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '• Check rainfall forecast before irrigation\n'
                '• Plan harvesting during dry days\n'
                '• Avoid pesticide spraying if rain expected',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoilData(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🌾 Soil Properties - $locationName',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSoilPropertyRow(
                'pH Level',
                soilData!.ph.toStringAsFixed(1),
                soilData!.getPhInterpretation(),
                theme,
              ),
              const Divider(),
              _buildSoilPropertyRow('Soil Type', soilData!.soilType, '', theme),
              const Divider(),
              _buildSoilPropertyRow(
                'Organic Carbon',
                '${soilData!.organicCarbon.toStringAsFixed(2)}%',
                soilData!.organicCarbon < 2.0
                    ? '⚠️ Low - Add compost'
                    : '✅ Good level',
                theme,
              ),
              const Divider(),
              _buildSoilPropertyRow(
                'Clay Content',
                '${soilData!.clayContent.toStringAsFixed(1)}%',
                '',
                theme,
              ),
              const Divider(),
              _buildSoilPropertyRow(
                'Sand Content',
                '${soilData!.sandContent.toStringAsFixed(1)}%',
                '',
                theme,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💡 Recommendations:',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[900],
                ),
              ),
              const SizedBox(height: 6),
              ...soilService
                  .getSoilRecommendations(soilData!)
                  .map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        rec,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.amber[800],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoilPropertyRow(
    String label,
    String value,
    String note,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            if (note.isNotEmpty)
              Text(
                note,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
