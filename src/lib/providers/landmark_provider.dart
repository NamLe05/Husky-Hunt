import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:husky_hunt/models/landmark.dart';

// This LandmarkProvider class loads the list of Landmark Objects and allows the game to pick a random object for Husky Hunt.
// Parameters:
//  1. landmarks[]: List of Landmarks
//  2. currObjective: Current Objective
//  3. _loading: checker to see if we are loading landmarks
//  4. _loaded: checker to see when loading is done
// Returns: Random Landmark
class LandmarkProvider extends ChangeNotifier {
  List<Landmark> _landmarks = [];
  Landmark? _currObjective;
  bool _loading = true;
  bool _loaded = false;

  // Constructor to load the list of landmarks
  LandmarkProvider() {
    _loadLandmarks();
  }

  // Getters to get landmarks, as well as current objective, and boolean checkers
  List<Landmark> get allLandmarks => _landmarks;
  Landmark? get currObjective => _currObjective;
  bool get loading => _loading;
  bool get loaded => _loaded;
  bool get canSelectObjective => !_loading && _landmarks.isNotEmpty;

  // Loads landmarks from JSON file and adds to list
  Future<void> _loadLandmarks() async {
    _loaded = true;
    notifyListeners();
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/assets/buildings.json',
      ); 

      final List<dynamic> data = json.decode(jsonString);
      _landmarks = data.map((e) => Landmark.fromJson(e)).toList();
    } catch (e) {
      // Make list empty if error
      _landmarks = [];
    }
    // Not loading anymore
    _loading = false; 
    notifyListeners();
  }

  // Creates a new random objective
  void randomObjective() {
    if (_landmarks.isEmpty) {
      _currObjective = null;
    } else {
      // Picks randomly from list
      final Random random = Random();
      final int randomIndex = random.nextInt(_landmarks.length);
      _currObjective = _landmarks[randomIndex]; 
    }
    notifyListeners();
  }
}
