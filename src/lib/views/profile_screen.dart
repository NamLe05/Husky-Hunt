import 'package:flutter/material.dart';
import 'package:husky_hunt/models/player.dart';
import 'package:husky_hunt/providers/player_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ProfileScreen
// Stateful Widget class that builds the user's profile screen,
// displays user's current avatar icon, and allows user to
// change their icon.
class ProfileScreen extends StatefulWidget {
  // Current player
  final Player? player;
  // Constructor
  const ProfileScreen({super.key, required this.player});
  // createState
  // creates ProfileScreenState
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// _ProfileScreenState
// Builds the profile screen and manages the state of the
// user's currently selectedIcon
class _ProfileScreenState extends State<ProfileScreen> {
  // current selected icon
  late String selectedIcon;
  // list of all icon choices
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

  // initState
  // initializes selectedIcon
  @override
  void initState() {
    super.initState();
    selectedIcon = widget.player!.icon;
  }

  // _selectIcon
  // updates the state of selectedIcon
  // using given icon, and uses PlayerProvider
  // to update the stored player's icon
  void _selectIcon(String icon) {
    setState(() {
      selectedIcon = icon;
    });
    // Update provider
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.updateIcon(icon);
  }

  // Build
  // Returns loading screen if player is null
  // otherwise returns user's profile
  @override
  Widget build(BuildContext context) {
    if (widget.player == null) {
      return Scaffold(
        appBar: AppBar(
          title: Semantics(
            label: AppLocalizations.of(context)!.profileScreen,
            child: Text(AppLocalizations.of(context)!.profile),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profileTitle(widget.player!.username),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.yourCurrentIcon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(selectedIcon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.chooseNewIcon,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children:
                    availableIcons.map((icon) {
                      final isSelected = icon == selectedIcon;
                      return Semantics(
                        button: true,
                        selected: isSelected,
                        label:
                            isSelected
                                ? AppLocalizations.of(
                                  context,
                                )!.selectedIconProfile(icon)
                                : AppLocalizations.of(
                                  context,
                                )!.tapToSelectIconProfile,
                        child: GestureDetector(
                          onTap: () => _selectIcon(icon),
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
          ],
        ),
      ),
    );
  }
}
