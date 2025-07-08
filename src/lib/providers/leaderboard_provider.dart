import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:husky_hunt/models/leaderboard.dart';
import 'package:husky_hunt/models/player.dart';

// This LeaderboardProvider builds the internal leaderboard from the list of players, and sorts according to high score, both all time and monthly
// Parameters:
//  1. _leaderboardData: the list of players
// Returns: Working leaderboard with sorted players

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardData _leaderboardData;
  
  // Toggle between monthly and all-time scores
  bool _showMonthly = false;
  // Empty list to display players
  List<Player> _displayedPlayers = [];

  // Constructor that calls isar to load Leaderboard list
  LeaderboardProvider(Isar isar) : _leaderboardData = LeaderboardData(isar) {
    refreshDataFromDb();
  }

  // Getters for displayed players, and month toggle
  List<Player> get players => _displayedPlayers;
  bool get showMonthly => _showMonthly;

  // Sorts players in list by score, depending on all-time high or monthly
  void _prepareDisplayedPlayers() {
    // Get players
    List<Player> currentList = List.from(_leaderboardData.players);
    
    // Reset any monthly scores that need resetting before sorting
    for (var player in currentList) {
      if (player.shouldResetMonthlyScore()) {
        player.monthlyScore = 0;
        player.monthlyScoreResetDate = DateTime.now().add(Duration(days: 30));
        _leaderboardData.updatePlayerScore(player);
      }
    }
    
    // Sort by monthly high scores
    if (_showMonthly) {
      currentList.sort((a, b) => b.monthlyScore.compareTo(a.monthlyScore));
    } else {
       // Sort by all-time high scores
      currentList.sort((a, b) => b.highScore.compareTo(a.highScore));
    }
    // Display players
    _displayedPlayers = currentList;
  }
  
  // Toggle between monthly and all-time high
  void toggleView(bool isMonthly) {
    _showMonthly = isMonthly;
    _prepareDisplayedPlayers();
    notifyListeners();
  }

  // Update current player's score
  void updatePlayerScoreInProvider(Player player) {
    _leaderboardData.updatePlayerScore(player);
    _prepareDisplayedPlayers();
    notifyListeners();
  }

  // Refresh data when player score changes
  Future<void> refreshDataFromDb() async {
    _leaderboardData.refreshPlayersFromDb();
    _prepareDisplayedPlayers();
    notifyListeners();
  }
}