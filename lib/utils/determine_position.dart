import 'dart:async';

import 'package:geolocator/geolocator.dart';

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
String errorMessage = "";

Future<Position> getCurrentPosition() async {
  final hasPermission = await _handlePermission();

  if (!hasPermission) {
    throw errorMessage;
  }

  return await Geolocator.getCurrentPosition();
}

Future<bool> _handlePermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
  if (!serviceEnabled) {
    errorMessage =
        "Location services are disabled. Please enable the device location to continue.";
    return false;
  }

  permission = await _geolocatorPlatform.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await _geolocatorPlatform.requestPermission();
    if (permission == LocationPermission.denied) {
      errorMessage =
          "Permission denied. In order to use this functionality, you must grant location permission for this app.";
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    errorMessage =
        "Permission denied forever. In order to use this functionality, you must grant location permission for this app.";
    return false;
  }

  return true;
}
