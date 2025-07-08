import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

// This PlayerProvider builds the current player and allows for score and icon changes, as well as username upon login
// Parameters:
//  1. isar: Isar for data persistence
//  2. _currentPlayer: the current user (you!)
// Returns: Current player object

class PlayerProvider extends ChangeNotifier {
  final Isar isar;
  Player? _currentPlayer;

  // Getter for current player
  Player? get currentPlayer => _currentPlayer;

  // Constructor that loads current player from Isar
  PlayerProvider(this.isar) {
    _loadCurrentPlayer();
  }

  // Loads current player and updates monthly score if needed
  Future<void> _loadCurrentPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt('currentPlayerId');

    if (savedId != null) {
      final player = await isar.players.get(savedId);
      if (player != null) {
        _currentPlayer = player;
        // Check for monthly reset when loading
        _checkAndResetMonthlyScore();
        notifyListeners();
      }
    }
  }

  // Current player setter
  Future<void> setCurrentPlayer(Player player) async {
    _currentPlayer = player;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPlayerId', player.id);
    // Check for monthly reset when setting player
    await _checkAndResetMonthlyScore();
    notifyListeners();
  }

  // If needed to reset score after 30 days is up, reset score
  Future<void> _checkAndResetMonthlyScore() async {
    if (_currentPlayer == null) return;

    if (_currentPlayer!.shouldResetMonthlyScore()) {
      _currentPlayer!.monthlyScore = 0;
      _currentPlayer!.monthlyScoreResetDate = DateTime.now().add(Duration(days: 30));
      
      // Save the reset to database
      await isar.writeTxn(() async {
        await isar.players.put(_currentPlayer!);
      });
    }
  }

  // Upon a game finishing, update both monthly and total score with set number of points
  Future<void> updateScore({required int points}) async {
    if (_currentPlayer == null) return;

    // Update both scores (with automatic monthly reset check)
    _currentPlayer!.updateScores(points);

    // Save changes to database
    await isar.writeTxn(() async {
      await isar.players.put(_currentPlayer!);
    });

    // Refresh from database to ensure consistency
    _currentPlayer = await isar.players.get(_currentPlayer!.id);
    notifyListeners();
  }

  // If user changes icon in Profile screen, update the icon accordingly
  Future<void> updateIcon(String newIcon) async {
    if (_currentPlayer == null) return;

    _currentPlayer!.icon = newIcon;
    await isar.writeTxn(() async {
      await isar.players.put(_currentPlayer!);
    });
    notifyListeners();
  }
}