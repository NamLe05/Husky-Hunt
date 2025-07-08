import 'package:flutter/material.dart';
import 'package:husky_hunt/models/player.dart';
import 'package:husky_hunt/providers/player_provider.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// LoginScreen
// StatefulWidget class that builds the user's login screen
// Allows user create and save their profile,
// to set their username and select an avatar Icon.
class LoginScreen extends StatefulWidget {
  // Constructor
  const LoginScreen({super.key});

  // createState
  // initializes _LoginScreenState
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// _LoginScreenState
// Builds the login screen and manages the state of the
// currently selectedIcon and username
class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController to manage the state of text
  // contents inside the username TextField
  final _usernameController = TextEditingController();
  // currently selected Icon with default value
  String selectedIcon = '😀';

  // all Icon choices
  final List<String> availableIcons = [
    '😀',
    '😎',
    '🤓',
    '😍',
    '😋',
    '😴',
    '😇',
    '🥶',
    '😱',
    '😭',
    '😤',
    '😡',
    '🥸',
    '🤠',
    '🤖',
    '👻',
  ];

  // debounce to indicate whether the player is currently
  // being saved to ISAR. Used to display loading
  // indicator and saving multiple times.
  bool _isSaving = false;

  // disposes controller when widget is disposed
  // or unmounted
  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // _createPlayer
  // uses user's entered usernamer and selectedIcon
  // to create a new player to store in ISAR.
  // if username is empty or already chosen by another user,
  // displays SnackBar error message
  Future<void> _createPlayer() async {
    final username = _usernameController.text.trim();
    // check if username is empty
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterUsername),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final playerProvider = context.read<PlayerProvider>();
    final isar = playerProvider.isar;

    // Check if username already exists
    final existingPlayer =
        await isar.players
            .filter()
            .usernameEqualTo(username, caseSensitive: false)
            .findFirst();

    if (existingPlayer != null) {
      setState(() {
        _isSaving = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.usernameNotAvailable),
        ),
      );
      return;
    }

    // Create new player
    final newPlayer = Player(
      username: username,
      icon: selectedIcon,
      highScore: 0,
    );

    await isar.writeTxn(() async {
      await isar.players.put(newPlayer);
    });

    await playerProvider.setCurrentPlayer(newPlayer);

    setState(() {
      _isSaving = false;
    });
  }

  // Build
  // Returns Scaffold containing AppBar, and a Column containing
  // a TextFieldForm to enter username, grid of selectable icons
  // and a create player button.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.createPlayer)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: AppLocalizations.of(context)!.enterUsername,
              excludeSemantics: true,
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.username,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.chooseIcon,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children:
                    availableIcons.map((icon) {
                      final isSelected = icon == selectedIcon;
                      return Semantics(
                        label:
                            isSelected
                                ? AppLocalizations.of(
                                  context,
                                )!.selectedIcon(icon)
                                : AppLocalizations.of(context)!.tapToSelectIcon,
                        excludeSemantics: true,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIcon = icon;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.purple[100]
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.purple
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _createPlayer,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child:
                  _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(AppLocalizations.of(context)!.createPlayer),
            ),
          ],
        ),
      ),
    );
  }
}
