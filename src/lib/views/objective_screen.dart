import 'package:flutter/material.dart';
import 'package:husky_hunt/models/landmark.dart';
import 'package:husky_hunt/models/player.dart';
import 'package:husky_hunt/providers/landmark_provider.dart';
import 'package:husky_hunt/views/map_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// This ObjectiveScreen displays the current objective landmark that the player needs to find and provides navigation to the map screen.
// Parameters:
//  1: currentPlayer: The current Player object containing player data and icon
// Returns: A screen showing the objective landmark name with continue and exit buttons.
class ObjectiveScreen extends StatelessWidget {
  final Player? currentPlayer;

  const ObjectiveScreen({super.key, required this.currentPlayer});

  @override
  Widget build(BuildContext context) {
    // Watch LandmarkProvider to get current objective landmark
    final landmarkProvider = context.watch<LandmarkProvider>();
    final Landmark? objective = landmarkProvider.currObjective;
    const Color primaryColor = Color.fromARGB(255, 75, 0, 130);

    return Scaffold(
      // App bar with purple theme and player icon display
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(AppLocalizations.of(context)!.objective),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          // Display current player's icon in app bar for accessibility
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Semantics(
              label: 'Current Player Icon: ${currentPlayer!.icon}',
              excludeSemantics: true,
              child: Text(
                currentPlayer!.icon,
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Display the objective landmark name that player needs to find
            Text(
              AppLocalizations.of(
                context,
              )!.findObjective(objective?.name ?? ''),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Continue button navigates to map screen with current player and objective
            Semantics(
              button: true,
              label: 'Continue to Map Screen',
              excludeSemantics: true,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to MapScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MapScreen(
                            currentPlayer: currentPlayer,
                            objective: objective!,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.continueText,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Exit button returns to previous screen
            Semantics(
              button: true,
              label: 'Press here to return to home screen',
              excludeSemantics: true,
              child: TextButton(
                onPressed: () {
                  // Return to previous screen in navigation stack
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.exit,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}