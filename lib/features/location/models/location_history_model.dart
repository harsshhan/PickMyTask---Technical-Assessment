import 'location_model.dart';

class LocationHistoryModel{
  final double lat;
  final double long;
  AddressModel address;
  DateTime timestamp;

  LocationHistoryModel({
    required this.lat,
    required this.long,
    required this.address,
    required this.timestamp,
  });
}