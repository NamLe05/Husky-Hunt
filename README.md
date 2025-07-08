# Husky Hunt

## About This App

Husky Hunt is a mobile scavenger hunt game built with Flutter. 
The app is designed to be played on the University of Washington Seattle campus. 
Players are assigned a random landmark on campus to then look for. 
Using their phone's GPS, they are shown the location, as well as how far away they are. 
Once they are close enough, they will be prompted use the in-app camera to take a picture of the UW landmark to win the game. 
For each win, players earn 500 points and can then look to see how they rank against others on an all-time and monthly leaderboard. 
The app also features a helpful weather bar on the home screen to help players decide if it's a good day to play or not.

---

## Build Instructions

To build and run this application, you will need to have the Flutter SDK installed.

1.  **Clone the repository:**
    ```
    git clone https://gitlab.cs.washington.edu/cse340-25sp-students/as-finalproject-group-9
    ```
    Or alternatively, click the blue **Code** button in Gitlab, and click **Visual Studio Code (SSH)** under **Open in your IDE**.

2.  **Install dependencies:**
    Run the following command in the project's root directory to fetch all the necessary packages.
    ```
    flutter pub get
    ```
3. **Install Internationalization Package:**
    Run this command to install multiple language support.
    ```
    flutter gen-l10n
    ```

4.  **Run the app:**
    Connect a device or start an emulator, then run the following command for release mode:
    ```
    flutter run --release
    ```

---

## Requirements

### Dependencies

The project relies on several key packages for its functionality:

* **provider**: For state management, allowing different parts of the app to update to changes in data (e.g., player score, location).
* **isar** & **isar_flutter_libs**: A fast, local database used for storing player profiles and leaderboard data.
* **path_provider**: To find the correct local path to store the Isar database.
* **geolocator**: To access the device's GPS location to track the player's proximity to objectives.
* **camera**: To take a picture using the device camera once players are at the landmark.
* **http**: To make network queries to the National Weather Service API for weather data.
* **shared_preferences**: To persist the current player's session.

### API Keys

* **Weather API**: The app uses the free `api.weather.gov` service, which **does not require an API key** for its current implementation.

### Permissions

The application requires the following device permissions to function correctly. The app is configured to request these from the user at runtime.

* **Location**: Essential for the core gameplay mechanic of finding landmarks. The user's location is used to calculate their distance from the target objective.
* **Camera**: Required for the user to take a picture of the landmark once they are within range, which is how objectives are completed.

---

## Project Layout

This section outlines the structure of the project's `lib` and `assets` directories to help navigate the codebase.

### `lib/`

This is the main directory containing all the Dart source code for the application.

* **`main.dart`**: The entry point for the application. It initializes the Isar database, sets up all the `ChangeNotifierProvider`s for state management, and determines whether to show the `LoginScreen` or `HomeScreen` based on whether a player is already logged in.

* **`assets/`**: This directory contains the static assets used by the app.
    * `buildings.json`: A JSON file containing the list of all landmark objectives. Each entry includes the landmark's name, a fun fact, its geographical coordinates (latitude/longitude), and its pixel coordinates on the map image.
    * `uw_campus_map.png`: The image of the UW campus map displayed on the `MapScreen`.

* **`models/`**: Defines the core data structures of the app.
    * `player.dart`: Defines the `Player` object, which includes username, icon, high score, and a monthly score that resets every 30 days. This is an Isar collection.
    * `landmark.dart`: Defines the `Landmark` object, structured to hold the data from `buildings.json`.
    * `leaderboard.dart`: Manages the collection of players for the leaderboard, interacting directly with the Isar database.

* **`providers/`**: Manages the application's state using the `provider` package.
    * `player_provider.dart`: Manages the state of the `currentPlayer`, including score updates and icon changes.
    * `landmark_provider.dart`: Loads the landmarks from `buildings.json` and manages the selection of a random `currObjective`.
    * `position_provider.dart`: Manages the device's location using the `geolocator` package.
    * `weather_provider.dart`: Fetches and holds the current weather state.
    * `leaderboard_provider.dart`: Prepares and sorts the player list for display on the `LeaderboardScreen`, with logic to toggle between all-time and monthly scores.

* **`views/`**: Contains all the UI screens (widgets) for the application.
    * `login_screen.dart`: The screen for creating a new player profile.
    * `home_screen.dart`: The main dashboard for a logged-in player, from where they can start a game or view the leaderboard.
    * `objective_screen.dart`: Displays the current landmark objective to the player.
    * `map_screen.dart`: Shows the player their location relative to the objective on the campus map.
    * `camera_view.dart`: The camera interface that allows players to take a picture of the landmark. It checks if the player is within the required range.
    * `finish_screen.dart`: The screen shown after a player successfully completes an objective, displaying points awarded and a fun fact.
    * `leaderboard_screen.dart`: Displays the sorted list of players and their scores.
    * `profile_screen.dart`: Allows the current player to change their avatar icon.

* **`helpers/`**: Contains helper classes that encapsulate specific logic.
    * `weather_checker.dart`: A class responsible for making the API call to `api.weather.gov` and grabbing the weather data.

* **`weather_condition.dart`**: An enum class that defines the possible weather conditions (`sunny`, `rainy`, `gloomy`, `unknown`).