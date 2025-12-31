class DistrictData {
  final String name;
  final String bnName;
  final double lat;
  final double long;
  final double production; // in metric tons
  final double yieldValue; // in kg/hectare (renamed from 'yield' as it's a reserved keyword)
  final double? percentage; // percentage contribution to total

  DistrictData({
    required this.name,
    required this.bnName,
    required this.lat,
    required this.long,
    required this.production,
    required this.yieldValue,
    this.percentage,
  });
}
