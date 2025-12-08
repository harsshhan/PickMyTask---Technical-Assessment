import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:http/http.dart' as http;
import 'package:pickmytask/features/location/models/location_model.dart';

class LocationRepository {
  final String apiKey = dotenv.env['GOOGLEMAPS_API_KEY'] ?? "";

  final Location location = Location();
  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return false;

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse || permission == LocationPermission.unableToDetermine ? true : false;
  }

  Future<bool> isLocationEnabled() async {
    bool locationenabled = await location.serviceEnabled();
    if (!locationenabled) {
      locationenabled = await location.requestService();
    }
    return locationenabled;
  }

  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<AddressModel> getAddressFromPositioin(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json"
      "?latlng=$latitude,$longitude"
      "&key=$apiKey",
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("Failed to fetch address");
    }
    final data = jsonDecode(res.body);
    
    final address = data["results"][0]["address_components"] as List;
    String city = "";
    String state = "";
    String pincode = "";

    for (var c in address) {
      final types = c["types"] as List;
      if (types.contains("administrative_area_level_3")) {
        city = c["long_name"];
      }
      if (types.contains("administrative_area_level_1")) {
        state = c["long_name"];
      }
      if (types.contains("postal_code")) {
        pincode = c["long_name"];
      }
    }
    return AddressModel(city: city, state: state, pincode: pincode);
  }
}
