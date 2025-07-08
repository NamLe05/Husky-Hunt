import 'package:flutter/material.dart';
import 'package:husky_hunt/models/landmark.dart';
import 'package:husky_hunt/models/player.dart';
import 'package:husky_hunt/providers/landmark_provider.dart';
import 'package:husky_hunt/providers/leaderboard_provider.dart';
import 'package:husky_hunt/providers/player_provider.dart';
import 'package:husky_hunt/views/home_screen.dart';
import 'package:husky_hunt/views/leaderboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// This is FinishScreen, where once a player finishes the game, this screen will congradulate the player,
// give a fun fact about the location that they found, as well as award the player 500 points for winning the game.
class FinishScreen extends StatelessWidget {
  final Player? currentPlayer;

  // Constructor to initialize parameters
  // Parameters:
  //  currentPlayer: the user that is playing the game
  const FinishScreen({super.key, required this.currentPlayer});

  // Builder to make the finish screen
  @override
  Widget build(BuildContext context) {
    // Call Player, Landmark, and Leaderboard providers to provider landmark information,
    // update player score, and send score to leaderboard.
    final playerProvider = context.watch<PlayerProvider>();
    final landmarkProvider = context.watch<LandmarkProvider>();
    final leaderboardProvider = context.watch<LeaderboardProvider>();
    final Landmark? objective = landmarkProvider.currObjective;
    const Color primaryColor = Color.fromARGB(255, 75, 0, 130);
    // Number of points they get for winning!
    final int winPoints = 500;

    // Helper method to update score and refresh database
    // ignore: no_leading_underscores_for_local_identifiers
    Future<void> _updateScoreAndNavigate(Widget destination) async {
      await playerProvider.updateScore(points: winPoints);
      await leaderboardProvider.refreshDataFromDb();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => destination),
        (route) => false,
      );
    }

    // Builds screen body, with win text, a fun fact, as well as ways to go to home or leaderboard
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        // Accessibility text to congradulate player
        title: Semantics(
          label: AppLocalizations.of(context)!.youWin,
          excludeSemantics: true,
          child: Text(AppLocalizations.of(context)!.youWin),
        ),
        // Title bar
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        // Display player's icon in corner
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Semantics(
              label: 'Current player icon: ${currentPlayer!.icon}',
              excludeSemantics: true,
              child: Text(
                currentPlayer!.icon,
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      // Body to hold Congradulations, fun fact, and buttons
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Accessibility text
            Semantics(
              label: AppLocalizations.of(
                context,
              )!.congratulationsFound(objective?.name ?? ''),
              excludeSemantics: true,
              child: Text(
                AppLocalizations.of(
                  context,
                )!.congratulationsFound(objective?.name ?? ''),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            // Accessibility text
            Semantics(
              label: AppLocalizations.of(
                context,
              )!.funFact(objective?.funFact ?? ''),
              excludeSemantics: true,
              // Display a fun fact about the location that was found
              child: Text(
                AppLocalizations.of(context)!.funFact(objective?.funFact ?? ''),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
            // Display how many points player has won, along with accessibility text
            const SizedBox(height: 30),
            Semantics(
              label: AppLocalizations.of(
                context,
              )!.pointsReceived(winPoints.toString()),
              excludeSemantics: true,
              child: Text(
                AppLocalizations.of(
                  context,
                )!.pointsReceived(winPoints.toString()),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
            // Home screen button
            const SizedBox(height: 40),
            Semantics(
              button: true,
              label: AppLocalizations.of(context)!.home,
              excludeSemantics: true,
              child: ElevatedButton(
                onPressed: () async {
                  // Go back to home screen
                  await _updateScoreAndNavigate(
                    HomeScreen(currentPlayer: playerProvider.currentPlayer),
                  );
                },
                // Button style, purple and round
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.home,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            // Leaderboard screen button
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: AppLocalizations.of(context)!.leaderboard,
              excludeSemantics: true,
              child: ElevatedButton(
                onPressed: () {
                  // Go to leaderboard
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaderboardScreen(),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.leaderboard,
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
