import 'dart:convert';
import 'package:husky_hunt/providers/weather_provider.dart';
import 'package:http/http.dart' as http;
import 'package:husky_hunt/weather_condition.dart';

//ignore_for_file: avoid_print
class WeatherChecker {
  final WeatherProvider weatherProvider;
  double _latitude = 0;
  double _longitude = 0;
  http.Client? client;

  WeatherChecker(this.weatherProvider, {this.client});

  Future<void> fetchAndUpdateCurrentWeather() async {
    // Don't fetch weather if we don't have a valid location
    if (_latitude == 0 && _longitude == 0) {
      return;
    }

    try {
      final http.Client client = this.client ?? http.Client();
      final gridResponse = await client.get(
          Uri.parse('https://api.weather.gov/points/$_latitude,$_longitude'));
      
      if (gridResponse.statusCode != 200) {
        weatherProvider.setError();
        return;
      }

      final gridParsed = (jsonDecode(gridResponse.body));
      final String? forecastURL = gridParsed['properties']?['forecast'];

      if (forecastURL == null) {
        weatherProvider.setError();
      } else {
        final weatherResponse = await client.get(Uri.parse(forecastURL));
        
        if (weatherResponse.statusCode != 200) {
          weatherProvider.setError();
          return;
        }

        final weatherParsed = jsonDecode(weatherResponse.body);
        final currentPeriod = weatherParsed['properties']?['periods']?[0];
        if (currentPeriod != null) {
          final temperature = currentPeriod['temperature'];
          final shortForecast = currentPeriod['shortForecast'];
          
          if (temperature != null && shortForecast != null) {
            final condition = _shortForecastToCondition(shortForecast);
            weatherProvider.updateWeather(temperature, condition);
          }
        }
      }
    } catch (e) {
      weatherProvider.setError();
    } finally {
      client?.close();
      client = null;
    }
  }

  void updateLocation({required double latitude, required double longitude}) {
    _latitude = latitude;
    _longitude = longitude;
  }

  WeatherCondition _shortForecastToCondition(String shortForecast) {
    final lowercased = shortForecast.toLowerCase();
    if (lowercased.contains('rain') || lowercased.contains('shower') || lowercased.contains('drizzle')) {
      return WeatherCondition.rainy;
    }
    if (lowercased.contains('sun') || lowercased.contains('sunny') || lowercased.contains('clear') || lowercased.contains('fair')) {
      return WeatherCondition.sunny;
    }
    return WeatherCondition.gloomy;
  }
}