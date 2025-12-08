import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_history_model.dart';
import '../models/location_model.dart';
import '../repository/location_repository.dart';

class LocationViewmodel extends ChangeNotifier {
  final LocationRepository repo;

  LocationViewmodel(this.repo);

  Position? currentPosition;
  AddressModel? currentAddress;
  DateTime? lastUpdated;

  final List<LocationHistoryModel> history = [];

  bool isLoading = false;
  bool isTracking = false;
  String? error;

  StreamSubscription<Position>? _positionSub;
  final Map<String, AddressModel> _addressCache = {};
  final double geocodeDistanceThreshold = 1.0;

  Position? _lastGeocodedPosition;

  Future<void> initAndRequestPermission() async {
    isLoading = true;
    notifyListeners();

    try {
      final ok = await repo.checkLocationPermission();
      if (!ok) {
        throw Exception('Location permission not granted');
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOnce({bool addToHistory = true}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final pos = await repo.getCurrentLocation();
      currentPosition = pos;

      await _maybeGeocodeAndUpdate(pos, addToHistory: addToHistory);

      lastUpdated = DateTime.now();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> startTracking() async {
    if (isTracking) return;

    final ok = await repo.checkLocationPermission();
    if (!ok) {
      error = 'Permission not granted';
      notifyListeners();
      return;
    }

    isTracking = true;
    notifyListeners();

    _positionSub = repo.getPositionStream(distanceFilter: 20).listen((pos) async {
      currentPosition = pos;
      lastUpdated = DateTime.now();
      notifyListeners();

      await _maybeGeocodeAndUpdate(pos, addToHistory: true);
    });
  }

  Future<void> stopTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
    isTracking = false;
    notifyListeners();
  }

  Future<void> _maybeGeocodeAndUpdate(Position pos, {required bool addToHistory}) async {
    try {
      final shouldGeocode = _shouldGeocode(pos);

      if (shouldGeocode) {
        final cacheKey = _cacheKey(pos.latitude, pos.longitude);
        AddressModel? addr = _addressCache[cacheKey];

        if (addr == null) {
          addr = await repo.getAddressFromPositioin(pos.latitude, pos.longitude);
          _addressCache[cacheKey] = addr;
        }

        currentAddress = addr;
        _lastGeocodedPosition = pos;

        if (addToHistory) {
          history.add(LocationHistoryModel(
            lat: pos.latitude,
            long: pos.longitude,
            address: addr,
            timestamp: DateTime.now(),
          ));
        }

        notifyListeners();
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  bool _shouldGeocode(Position pos) {
    if (_lastGeocodedPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _lastGeocodedPosition!.latitude,
      _lastGeocodedPosition!.longitude,
      pos.latitude,
      pos.longitude,
    );

    return distance >= geocodeDistanceThreshold;
  }

  String _cacheKey(double lat, double lng) {
    final rLat = (lat * 10000).round() / 10000;
    final rLng = (lng * 10000).round() / 10000;
    return '$rLat,$rLng';
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}