import 'package:flutter/material.dart';
import 'package:husky_hunt/providers/leaderboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// LeaderboardScreen builds the Leaderboard viewfinder, allowing for people to see their overall high score, as well as
// their monthly all-time high score, which resets every 30 days.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  // Builder
  @override
  Widget build(BuildContext context) {
    // Call LeaderBoardProvider
    final leaderboardProvider = context.read<LeaderboardProvider>();

    // Refresh list of players
    WidgetsBinding.instance.addPostFrameCallback((_) {
      leaderboardProvider.refreshDataFromDb();
    });

    // Consumer to get leaderboard data and changes
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          // Builds Title bar
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.leaderboard),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: const Color.fromARGB(255, 75, 0, 130),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Padding(
                // Accessibility label for toggling between all-time and monthly score
                padding: const EdgeInsets.only(right: 8.0),
                child: Semantics(
                  label: AppLocalizations.of(context)!.toggleScores,
                  excludeSemantics: true,
                  child: Switch(
                    value: provider.showMonthly,
                    onChanged: (value) {
                      // Toggle view
                      provider.toggleView(value);
                    },
                    activeColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          // Builds Leaderboard body
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Semantics(
                      label:
                          provider.showMonthly
                              ? AppLocalizations.of(context)!.showingMonthly
                              : AppLocalizations.of(context)!.showingAllTime,
                      excludeSemantics: true,
                      child: Text(
                        // Title shows between monthly and high scores
                        provider.showMonthly
                            ? AppLocalizations.of(context)!.monthlyScores
                            : AppLocalizations.of(context)!.allTimeHighScores,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // For monthly score, show days until this resets
                    if (provider.showMonthly && provider.players.isNotEmpty)
                      Text(
                        AppLocalizations.of(context)!.resetsIn(
                          provider.players.first.getDaysUntilReset().toString(),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              // Show players in leaderboard
              Expanded(
                child:
                    // If people, show empty leaderboard with message
                    provider.players.isEmpty
                        ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.noPlayersYet,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                        // Or else build the leaderboard list
                        : ListView.builder(
                          itemCount: provider.players.length,
                          itemBuilder: (context, index) {
                            final player = provider.players[index];
                            final score =
                                provider.showMonthly
                                    ? player.monthlyScore
                                    : player.highScore;
                            // Accessibility helper text to explain who each entry is, as well as their score
                            return Semantics(
                              label: AppLocalizations.of(
                                context,
                              )!.showingPlayer(
                                (index + 1).toString(),
                                player.username,
                                score.toString(),
                              ),
                              excludeSemantics: true,
                              child: Card(
                                // Show player with Icon, Name, and Score
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                elevation: 2,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      75,
                                      0,
                                      130,
                                    ),
                                    // Player Icon goes here
                                    child: Text(
                                      player.icon,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  // Player Name goes here
                                  title: Text(
                                    '${index + 1}. ${player.username}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 75, 0, 130),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    // Showcase player's score on right side in purple box
                                    child: Text(
                                      score.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
              // Back button to navigate back to home or finish screen, depending on how we entered the leaderbaord
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  // Button style goes at the bottom 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 75, 0, 130),
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  // Button text
                  child: Text(
                    AppLocalizations.of(context)!.back,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
