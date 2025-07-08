# Data Architecture

Here’s how the data side of the Husky Hunt app works.

## Data Design

The app uses a few data models to track game progress and other stuff. We’re using **Isar** as our local database because it’s super fast and works really well with Flutter.

### Main Data Models

You’ll find all the core models inside the `lib/models/` folder.

* **`Player`** (`lib/models/player.dart`)  
  This one’s important since it stores info about the player. It’s set up as an Isar `collection`, so data gets saved on the device automatically. Each `Player` has:
  * `Id id`: A unique ID that Isar handles for us
  * `String username`: The name the player picked (indexed so it loads faster)
  * `String icon`: The emoji avatar the player chose
  * `int highScore`: Their best score ever
  * `int monthlyScore`: Resets every 30 days for monthly challenges
  * `DateTime monthlyScoreResetDate`: Tells us when to reset the monthly score

* **`Landmark`** (`lib/models/landmark.dart`)  
  These are the places players have to find. These are loaded from a JSON file.
  * `String name`: The place’s name (like “Suzzallo Library”)
  * `String funFact`: A cool fact that shows up when it’s completed
  * `double latitude` & `double longitude`: Actual GPS coordinates
  * `double pixelX` & `double pixelY`: Location on our `uw_campus_map.png` image

* **`LeaderboardData`** (`lib/models/leaderboard.dart`)  
  Not really a data model but actually more of a helper class. It pulls player info from the database to build the leaderboard.

## Data Flow

We’re using **Provider** for state management, which basically means when the data changes the UI updates automatically.
### Provider Setup

In `lib/main.dart`, the whole app is wrapped in a `MultiProvider`. That way, all providers are available wherever we need them.

This is what each provider does:

* **`PlayerProvider`** (`lib/providers/player_provider.dart`)  
  * **What it does**: Tracks the player who’s currently using the app  
  * **How it works**: When something changes (like gaining points), it updates the player data in the database and calls `notifyListeners()`. That way, any part of the UI watching this provider will rebuild. It also handles loading the player at startup and changing avatars.

* **`LandmarkProvider`** (`lib/providers/landmark_provider.dart`)  
  * **What it does**: Keeps track of all the landmarks and the current objective  
  * **How it works**: Loads everything from `lib/assets/buildings.json`. When a new objective is needed, it uses `randomObjective()` to pick one and notify the UI.

* **`LeaderboardProvider`** (`lib/providers/leaderboard_provider.dart`)  
  * **What it does**: Handles sorting and showing the leaderboard  
  * **How it works**: Pulls player data from `LeaderboardData` and sorts it by high score or monthly score, depending on what the user selects. If the user toggles the view, it re-sorts and updates the screen.

* **`PositionProvider`** (`lib/providers/position_provider.dart`)  
  * **What it does**: Figures out where the player is using GPS  
  * **How it works**: Uses the `geolocator` package to get your current location. Once it knows where you are, it updates widgets like the map so they can show how close you are to your goal.

* **`WeatherProvider`** (`lib/providers/weather_provider.dart`)  
  * **What it does**: Gets weather info for your current location  
  * **How it works**: Waits for `PositionProvider` to get your location, then uses `WeatherChecker` to grab weather data. Updates the weather section on `HomeScreen`.

### How the UI Reacts

Widgets in `lib/views/` use provider data in two main ways:

1. **`context.watch<T>()`**  
   Use this when your widget should rebuild anytime the data changes. For example, `HomeScreen` watches `WeatherProvider` to keep the weather display up-to-date.

2. **`context.read<T>()`**  
   Use this when you just need to call a method or get a value once — no need to rebuild the widget. For example, `FinishScreen` calls `context.read<PlayerProvider>().updateScore()` when awarding points.

This setup makes the app a lot easier to manage as the UI stays clean and separate from the logic. Also makes debugging less of a pain.

