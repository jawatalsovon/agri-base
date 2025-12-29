class DistrictData {
  final String name;
  final String bnName;
  final double lat;
  final double long;
  final double production; // in metric tons
  final double yield; // in kg/hectare

  DistrictData({
    required this.name,
    required this.bnName,
    required this.lat,
    required this.long,
    required this.production,
    required this.yield,
  });
}
