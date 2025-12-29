extension StringExtensions on String {
  String toTitleCase() {
    return split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }
}

String cleanDistrict(String district) {
  return district.replaceAll(RegExp(r'/\d+'), '').replaceAll('+', '').trim();
}

List<String> sortDistricts(List<String> districts) {
  return districts.map(cleanDistrict).toList()..sort();
}
