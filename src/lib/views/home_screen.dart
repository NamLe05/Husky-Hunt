import 'package:flutter/material.dart';
import 'package:husky_hunt/models/player.dart';
import 'package:husky_hunt/providers/landmark_provider.dart';
import 'package:husky_hunt/views/leaderboard_screen.dart';
import 'package:husky_hunt/views/profile_screen.dart';
import 'package:husky_hunt/views/objective_screen.dart';
import 'package:husky_hunt/weather_condition.dart';
import 'package:provider/provider.dart';
import 'package:husky_hunt/providers/position_provider.dart';
import 'package:husky_hunt/providers/weather_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// This is the Home screen that a returning player would log into.
// Parameters:
//  1. currentPlayer: The user playing the game
// Returns: Home Screen view

class HomeScreen extends StatelessWidget {
  final Player? currentPlayer;

  // Constructor to get current player
  const HomeScreen({super.key, required this.currentPlayer});

  // Builds home screen
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromARGB(255, 75, 0, 130);

    // Title bar with Title name and player icon with accessibility text.
    return Scaffold(
      appBar: AppBar(
        // Title bar
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: primaryColor,
        actions: [
          Padding(
            // Accessibility text to navigate to profile selection screen
            padding: const EdgeInsets.only(right: 16.0),
            child: Semantics(
              label:
                  'Navigate to profile selection screen. Current player icon: ${currentPlayer!.icon}',
              excludeSemantics: true,
              child: TextButton(
                child: Text(
                  currentPlayer!.icon,
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
                // When pressed, navigate to profile screen
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProfileScreen(player: currentPlayer),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        // Set title and icon theme data
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // Body that is a Consumer, using Weather and Position providers to update state
      body: Consumer2<WeatherProvider, PositionProvider>(
        builder: (context, weatherProvider, positionProvider, child) {
          // Gets current position and updates location accordingly
          if (positionProvider.positionKnown &&
              positionProvider.latitude != null &&
              positionProvider.longitude != null) {
            weatherProvider.updateWeatherLocation(
              latitude: positionProvider.latitude!,
              longitude: positionProvider.longitude!,
            );
          }
          // Builds center text display
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Welcome Text
                  Text(
                    AppLocalizations.of(context)!.welcome,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(221, 0, 0, 0),
                    ),
                  ),
                  // Helper text to prompt user to play the game
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.pressPlay,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(137, 0, 0, 0),
                    ),
                  ),
                  // Aligns Play and Leaderboard buttons below text in a row
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Build leaderboard button
                      _buildNavButton(
                        context: context,
                        label: AppLocalizations.of(context)!.leaderboard,
                        color: primaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            // Go to leaderboard screen when pressed
                            MaterialPageRoute(
                              builder: (context) => LeaderboardScreen(),
                            ),
                          );
                        },
                      ),
                      // Play button to start game
                      _buildNavButton(
                        context: context,
                        label: AppLocalizations.of(context)!.play,
                        color: primaryColor,
                        onPressed: () {
                          // When pressed, load list of landmarks to play the game
                          final landmarkProvider =
                              context.read<LandmarkProvider>();
                          // If finished loading, select random object and allow game to start
                          if (landmarkProvider.canSelectObjective) {
                            landmarkProvider.randomObjective();
                            Navigator.push(
                              context,
                              // Navigate to objective screen
                              MaterialPageRoute(
                                builder:
                                    (context) => ObjectiveScreen(
                                      currentPlayer: currentPlayer,
                                    ),
                              ),
                            );
                            // Popup to tell user that objectives have not loaded yet
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.objectivesLoading,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  // Weather display to show weather (Should I play today?)
                  const SizedBox(height: 30),
                  _buildWeatherDisplay(weatherProvider, positionProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to create buttons, with button label, color, and onPressed parameters to manage accordingly
  Widget _buildNavButton({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    // Accessibility text
    return Semantics(
      label: '{$label} button',
      excludeSemantics: true,
      child: ElevatedButton(
        onPressed: onPressed,
        // Build button display
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          // Build button text
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: const TextStyle(
            fontSize: 18,
            // a bit more bold
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }

  // Builds the weather display and places it at the bottom of the screen
  Widget _buildWeatherDisplay(
    WeatherProvider weatherProvider,
    PositionProvider positionProvider,
  ) {
    String weatherInfo = 'Getting weather...';
    IconData weatherIcon = Icons.replay_outlined;

    // Prints out weather conditions for each case, including unknown and loading
    if (weatherProvider.error) {
      weatherInfo = weatherProvider.errorMsg ?? 'Weather unavailable';
      weatherIcon = Icons.error_outline;
    } else if (weatherProvider.tempInFahrenheit != null) {
      weatherInfo =
          '${weatherProvider.tempInFahrenheit}°F, ${weatherProvider.condition.name}';
      switch (weatherProvider.condition) {
        // Sunny
        case WeatherCondition.sunny:
          weatherIcon = Icons.wb_sunny_outlined;
          break;
        // Gloomy
        case WeatherCondition.gloomy:
          weatherIcon = Icons.cloud_outlined;
          break;
        // Rainy
        case WeatherCondition.rainy:
          weatherIcon = Icons.umbrella_outlined;
          break;
        // Unknown
        case WeatherCondition.unknown:
          weatherIcon = Icons.help_outline;
          break;
      }
      // Edge case: location was turned off
    } else if (!positionProvider.positionKnown) {
      weatherInfo = 'Enable location for weather';
      weatherIcon = Icons.location_off_outlined;
    }

    // Builds box where weather will be housed, placing at the top of the screen
    return Semantics(
      // Accessibility readout
      label: 'Current weather is: $weatherInfo',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        margin: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 5),
        // White box at bottom with shadows
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        // Prints out weather icon for current conditions
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Icon(weatherIcon, color: Colors.black, size: 22),
              ),
            ),
            // Text for current weather conditions
            Text(
              weatherInfo,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
