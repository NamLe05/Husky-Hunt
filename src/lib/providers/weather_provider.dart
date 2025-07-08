import 'dart:async';
import 'package:flutter/material.dart';
import 'package:husky_hunt/helpers/weather_checker.dart';
import 'package:husky_hunt/weather_condition.dart';

// This WeatherProvider Class calls weather_checker to update the current weather, and provides it to our widget tree. This notifys all listeners so that
// weather is provided accurately.
// Parameters:
//  1. tempInFahrenheit: Store current temperature
//  2. condition: Current condition
//  3. error: error boolean
//  4. _check: WeatherChecker to check weather
//  5. _weatherCheckTimer: Timer to check periodically
//  6. _locationSet: boolean to see if we have location
// Returns: Weather at location

class WeatherProvider extends ChangeNotifier {
  int? tempInFahrenheit = 0;
  WeatherCondition condition = WeatherCondition.unknown;
  bool error = false;
  late WeatherChecker _check;
  String? errorMsg;
  Timer? _weatherCheckTimer;
  bool _locationSet = false;

  // Fetches weather in current location
  WeatherProvider() {
    _check = WeatherChecker(this);
    // Don't fetch weather immediately - wait for location update
  }

  // Notifies listeners and updates weather based on conditions
  void updateWeather(int newTempFahrenheit, WeatherCondition newCondition) {
    error = false;
    errorMsg = null;
    tempInFahrenheit = newTempFahrenheit;
    condition = newCondition;
    notifyListeners();
  }

  // Updates weather location
  void updateWeatherLocation({required double latitude, required double longitude}) {
    // Only update if location hasn't been set yet or coordinates changed significantly
    if (!_locationSet) {
      _check.updateLocation(latitude: latitude, longitude: longitude);
      _check.fetchAndUpdateCurrentWeather();
      _locationSet = true;
      
      // Start the periodic timer only after we have a valid location
      // Keeps pulling current weather forecast every minute using the Timer.periodic symbols
      _weatherCheckTimer?.cancel();
      _weatherCheckTimer = Timer.periodic(
        const Duration(seconds: 60),
        (timer) {
          _check.fetchAndUpdateCurrentWeather();
        },
      );
    }
  }

  // If weather cannot be found, send error message
  void setError() {
    error = true;
    errorMsg = 'Failed to fetch weather data';
    notifyListeners();
  }

  // Cancel timer
  @override
  void dispose() {
    _weatherCheckTimer?.cancel();
    super.dispose();
  }
}