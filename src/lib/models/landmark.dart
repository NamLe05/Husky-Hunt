// This Landmark class converts the UW Campus buildings listed in our buildings.json file, and translates them into
// Landmark Objects that we can use in our game.
// Parameters:
//  1. name: Name of Landmark
//  2. funFact: Fun fact about Landmark
//  3. latitude: latitude coordinate
//  4. longitude: longitude coordintate
//  5. pixelX: Convert latitude to pixel
//  6. pixelY: Convert longitude to pixel
// Returns: Landmark Object

class Landmark {
  final String name;
  final String funFact;
  final double latitude;
  final double longitude;
  final double pixelX;
  final double pixelY;

  // Contstructor to initialize parameters
  Landmark({
    required this.name,
    required this.funFact,
    required this.latitude,
    required this.longitude,
    required this.pixelX,
    required this.pixelY
  });

  // Factory Constructor to read information from JSON, and convert to parameters
  factory Landmark.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    return Landmark(
      name: json['name'],
      funFact: json['fun_fact'],
      latitude: (location['latitude'] as num).toDouble(),
      longitude: (location['longitude'] as num).toDouble(),
      pixelX: (location['pixelX'] as num).toDouble(),
      pixelY: (location['pixelY'] as num).toDouble(),
    );
  }
}
