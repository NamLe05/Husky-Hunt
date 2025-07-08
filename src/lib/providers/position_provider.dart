import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

// This PositionProvider extends the ChangeNotifier to make a provider that provides the precise location of the current device.
// Parameters:
//  1: _latitude: Current Latitude
//  2: _longitude: Current Longitude
// Returns: Current Latitude and Longitude data to provide and notifies listeners.
class PositionProvider extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  bool _positionKnown = false;
  Timer? _timer;

  // Getter methods for latitude, longitude, and boolean if position is known
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get positionKnown => _positionKnown;

   // Timer to call and find location after a second
  PositionProvider() {
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      updatePosition();
    });
    updatePosition();
  }

  // Updates position based on whether determinePosition method from flutter docs succeeds 
  Future<void> updatePosition() async {
    try {
      final Position position = await _determinePosition();
      _latitude = position.latitude;
      _longitude = position.longitude;
      _positionKnown = true;
    } catch (error) {
      // If error, state that position known is false.
      _latitude = null;
      _longitude = null;
      _positionKnown = false;
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}