import 'package:isar/isar.dart';

part 'player.g.dart';

// This Player class creates a player object for the Husky Hunt game.
// Parameters:
//  1. Id: isar ID
//  2. username: Username of player proflie
//  3. icon: Icon of player profile
//  4. highScore: All-time high score of player
//  5. monthlyScore: Monthly score that resets every 30 days
//  6. monthlyScoreResetDate: Day when monthly score is reset
// Returns: Player object
@collection
class Player {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String username;

  String icon;
  int highScore;
  
  // Simple monthly score fields
  int monthlyScore;
  DateTime monthlyScoreResetDate;

  // Constructor that initalizes all fields
  Player({
    required this.username,
    required this.icon,
    required this.highScore,
    this.monthlyScore = 0,
  }) : monthlyScoreResetDate = _getNextResetDate();

  // Named constructor for existing players with reset date
  Player.withResetDate({
    required this.username,
    required this.icon,
    required this.highScore,
    this.monthlyScore = 0,
    required this.monthlyScoreResetDate,
  });

  // Calculate next reset date (30 days from now)
  static DateTime _getNextResetDate() {
    return DateTime.now().add(Duration(days: 30));
  }

  // Check if monthly score should be reset
  bool shouldResetMonthlyScore() {
    return DateTime.now().isAfter(monthlyScoreResetDate);
  }

  // Update scores with automatic monthly reset check
  void updateScores(int points) {
    // Check if we need to reset monthly score
    if (shouldResetMonthlyScore()) {
      monthlyScore = 0;
      monthlyScoreResetDate = _getNextResetDate();
    }
    
    // Update both scores
    highScore += points;
    monthlyScore += points;
  }

  // Get days remaining until monthly reset
  int getDaysUntilReset() {
    final now = DateTime.now();
    if (now.isAfter(monthlyScoreResetDate)) {
      return 0;
    }
    return monthlyScoreResetDate.difference(now).inDays;
  }
}