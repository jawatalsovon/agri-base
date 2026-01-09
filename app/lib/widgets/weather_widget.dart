import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final loc = Provider.of<LocationProvider>(context, listen: false);
      await loc.requestLocation();
      if (!mounted) return;
      final weatherProv = Provider.of<WeatherProvider>(context, listen: false);
      final lat = loc.latitude ?? LocationProvider.fallbackLat;
      final lon = loc.longitude ?? LocationProvider.fallbackLon;
      final locationLabel =
          loc.districtName ?? (loc.status == 'ok' ? 'Location' : 'Nāgarpur');
      weatherProv.fetchWeather(lat, lon, locationName: locationLabel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, WeatherProvider>(
      builder: (context, loc, weatherProv, child) {
        final theme = Theme.of(context);
        if (weatherProv.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (weatherProv.error != null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Weather error: ${weatherProv.error}'),
          );
        }

        final data = weatherProv.weatherData;
        if (data == null) {
          return const SizedBox.shrink();
        }

        // Swipeable carousel of daily forecasts
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🌤️ ${weatherProv.locationName ?? 'Location'}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => weatherProv.refreshWeather(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.8),
                  itemCount: data.dailyForecasts.length,
                  itemBuilder: (context, index) {
                    final f = data.dailyForecasts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outline),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Format date to include weekday name
                            Text(
                              DateFormat(
                                'EEEE, MMM d',
                              ).format(DateTime.parse(f.date)),
                              style: theme.textTheme.labelMedium,
                            ),
                            Text(
                              f.getWeatherIcon(),
                              style: const TextStyle(fontSize: 30),
                            ),
                            Text(
                              '${f.maxTemp.toStringAsFixed(0)}° / ${f.minTemp.toStringAsFixed(0)}°',
                              style: theme.textTheme.headlineSmall,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Icon(Icons.water_drop),
                                    Text('${f.precipitationProbability}%'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.air),
                                    Text('${f.windSpeed} m/s'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.thermostat),
                                    Text('${f.maxTemp.toStringAsFixed(0)}°'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
