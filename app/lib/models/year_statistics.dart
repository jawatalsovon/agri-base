class YearStatistics {
  final int year;
  final double production;
  final double yieldValue; // Renamed from 'yield' as it's a reserved keyword
  final double areaUnder;

  YearStatistics({
    required this.year,
    required this.production,
    required this.yieldValue,
    required this.areaUnder,
  });
}
