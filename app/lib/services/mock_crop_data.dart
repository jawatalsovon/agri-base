import '../models/district_data.dart';
import '../models/year_statistics.dart';

class MockCropData {
  static final Map<String, Map<String, DistrictData>> cropDataByDistrict = {
    'Rice': {
      'Dinajpur': DistrictData(
        name: 'Dinajpur',
        bnName: 'দিনাজপুর',
        lat: 25.6217061,
        long: 88.6354504,
        production: 850000,
        yield: 4.2,
      ),
      'Mymensingh': DistrictData(
        name: 'Mymensingh',
        bnName: 'ময়মনসিংহ',
        lat: 24.7471,
        long: 90.4203,
        production: 920000,
        yield: 4.5,
      ),
      'Rangpur': DistrictData(
        name: 'Rangpur',
        bnName: 'রংপুর',
        lat: 25.7558096,
        long: 89.244462,
        production: 780000,
        yield: 3.9,
      ),
      'Dhaka': DistrictData(
        name: 'Dhaka',
        bnName: 'ঢাকা',
        lat: 23.7115253,
        long: 90.4111451,
        production: 650000,
        yield: 3.5,
      ),
    },
    'Wheat': {
      'Dinajpur': DistrictData(
        name: 'Dinajpur',
        bnName: 'দিনাজপুর',
        lat: 25.6217061,
        long: 88.6354504,
        production: 320000,
        yield: 2.8,
      ),
      'Rangpur': DistrictData(
        name: 'Rangpur',
        bnName: 'রংপুর',
        lat: 25.7558096,
        long: 89.244462,
        production: 280000,
        yield: 2.5,
      ),
      'Bogura': DistrictData(
        name: 'Bogura',
        bnName: 'বগুড়া',
        lat: 24.8465228,
        long: 89.377755,
        production: 250000,
        yield: 2.3,
      ),
    },
    'Jute': {
      'Dhaka': DistrictData(
        name: 'Dhaka',
        bnName: 'ঢাকা',
        lat: 23.7115253,
        long: 90.4111451,
        production: 180000,
        yield: 2.1,
      ),
      'Faridpur': DistrictData(
        name: 'Faridpur',
        bnName: 'ফরিদপুর',
        lat: 23.6070822,
        long: 89.8429406,
        production: 165000,
        yield: 1.9,
      ),
      'Manikganj': DistrictData(
        name: 'Manikganj',
        bnName: 'মানিকগঞ্জ',
        lat: 23.8644,
        long: 90.0047,
        production: 145000,
        yield: 1.7,
      ),
    },
  };

  static List<YearStatistics> getYearStatistics(String crop) {
    return [
      YearStatistics(year: 2020, production: 8500000, yield: 3.2, areaUnder: 2656000),
      YearStatistics(year: 2021, production: 8750000, yield: 3.4, areaUnder: 2570000),
      YearStatistics(year: 2022, production: 9100000, yield: 3.6, areaUnder: 2525000),
      YearStatistics(year: 2023, production: 9450000, yield: 3.8, areaUnder: 2480000),
    ];
  }

  static double getTotalProduction(String crop) {
    return 9450000;
  }

  static double getAverageYield(String crop) {
    return 3.8;
  }
}
