import 'package:isar/isar.dart';
import 'package:husky_hunt/models/player.dart';

// This leaderboard class uses isar to create a database for all users.
// Parameters:
//  1. _isar: Isar data persistence
//  2. _players: List of players
// Returns: Working leaderboard with data persistence, with the ability to update player score.

class LeaderboardData {
  final Isar _isar;
  final String name;
  List<Player> _players;

  // Constructor initializes leaderboard with isar
  LeaderboardData(this._isar, {this.name = '', List<Player>? initialPlayers})
    : _players = _isar.players.where().findAllSync();

  // Getter to get all players in List
  List<Player> get players {
    _players = _isar.players.where().findAllSync();
    return List.from(_players);
  }

  // Update and put score in leaderboard when called
  void updatePlayerScore(Player updatedPlayer) {
    _isar.writeTxnSync(() {
      _isar.players.putSync(updatedPlayer);
    });
    // Refresh Leaderboard
    _players = _isar.players.where().findAllSync();
  }

  // Refresh Leaderboard just in case
  void refreshPlayersFromDb() {
    _players = _isar.players.where().findAllSync();
  }
}
