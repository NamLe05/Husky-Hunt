import 'package:flutter/material.dart';
import 'package:husky_hunt/providers/landmark_provider.dart';
import 'package:husky_hunt/providers/leaderboard_provider.dart';
import 'package:husky_hunt/providers/player_provider.dart';
import 'package:husky_hunt/providers/position_provider.dart';
import 'package:husky_hunt/providers/weather_provider.dart';
import 'package:husky_hunt/views/login_screen.dart';
import 'views/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:husky_hunt/models/player.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Main class to build the Husky Hunt app. Initializes the Isar database, sets up all providers, and starts the app.
// Returns: Husky Hunt!
void main() async {
  // Initialize Isar 
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([PlayerSchema], directory: dir.path);

  // Initialize position provider
  final positionProvider = PositionProvider();
  await positionProvider.updatePosition();

  // Start app with all providers that we use
  runApp(
    MultiProvider(
      providers: [
        // Leaderboard
        ChangeNotifierProvider<LeaderboardProvider>(
          create: (context) => LeaderboardProvider(isar),
        ),
        // Position
        ChangeNotifierProvider<PositionProvider>(
          create: (_) => PositionProvider(),
        ),
        // Player
        ChangeNotifierProvider<PlayerProvider>(
          create: (context) => PlayerProvider(isar),
        ),
        // Landmark
        ChangeNotifierProvider<LandmarkProvider>(
          create: (context) => LandmarkProvider(),
        ),
        // Weather
        ChangeNotifierProvider<WeatherProvider>(
          create: (_) => WeatherProvider(),
        ),
      ],
      child: MainApp(),
    ),
  );
}

// MainAPp widget that builds the root that starts our view tree
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromARGB(255, 75, 0, 130);
    // Check on what current player is, to show login (returning user) or login (new user)
    final currentPlayer = context.watch<PlayerProvider>().currentPlayer;

    return MaterialApp(
      title: 'Husky Hunt',
      // Purple color scheme
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home:
          // If new player, show login screen, otherwise show home screen
          currentPlayer == null
              ? LoginScreen()
              : HomeScreen(currentPlayer: currentPlayer),
      // Internationalization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('es', '')],
    );
  }
}
