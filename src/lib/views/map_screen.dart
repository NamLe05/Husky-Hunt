import 'package:flutter/material.dart';
import 'package:husky_hunt/models/landmark.dart';
import 'package:husky_hunt/models/player.dart';
import 'package:husky_hunt/views/camera_view.dart';
import 'package:provider/provider.dart';
import 'package:husky_hunt/providers/position_provider.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MapScreen
// Builds the map screen to display an image of the UW campus,
// the user's distance from the given objective using PositionProvider,
// and a camera button to navigate to CameraScreen
class MapScreen extends StatelessWidget {
  // Current player
  final Player? currentPlayer;
  // Objective to find
  final Landmark objective;

  // Constructor
  const MapScreen({
    super.key,
    required this.currentPlayer,
    required this.objective,
  });

  // Build
  // Uses PositionProvider to calculate the user's distance from
  // the objective. Builds MapScreen using a Scaffold with AppBar
  // and custom widgets _buildMapWithMarker, _buildDistanceCard,
  // and _buildCameraButton that is visible only when the user is
  // <= 0.1km
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromARGB(255, 75, 0, 130);
    final positionProvider = context.watch<PositionProvider>();
    double? distanceKm;
    if (positionProvider.positionKnown &&
        positionProvider.latitude != null &&
        positionProvider.longitude != null) {
      distanceKm = calculateDistance(
        positionProvider.latitude!,
        positionProvider.longitude!,
        objective.latitude,
        objective.longitude,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(AppLocalizations.of(context)!.map),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child:  Semantics(
              label: 'Player icon',
              child: Text(
                currentPlayer?.icon ?? '',
                style: const TextStyle(fontSize: 32, color: Colors.white),
              )
            )
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildMapWithMarker(context)),
          _buildDistanceCard(context, distanceKm),
          _buildCameraButton(context, primaryColor),
        ],
      ),
    );
  }

  // _buildCameraButton
  // builds the camera button using a Positioned ElevatedButton with camera icon
  // Parameters:
  // - context: BuildContext to navigate to CameraScreen
  // - primaryColor: Color of the button's background
  Widget _buildCameraButton(BuildContext context, Color primaryColor) {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Semantics(
        button: true,
        label: 'Take a picture',
        hint: 'Open the camera to take a photo and complete the objective',
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraView(objective: objective, currentPlayer: currentPlayer),
              ),
            );
          },
          icon: const Icon(Icons.camera_alt, size: 24, color: Colors.white),
          label: Text(AppLocalizations.of(context)!.takePicture),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            elevation: 6,
            shadowColor: Colors.black26,
          ),
        ),
      ),
    );
  }

  // _buildDistanceCard
  // builds a Container to represent a distance card
  // to display user's distance from objective using given
  // distance as a double
  Widget _buildDistanceCard(BuildContext context, double? distanceKm) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Semantics(
        label: 'Distance to objective',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: _buildDistanceRow(context, distanceKm),
        ),
      ),
    );
  }


  // _buildDistanceRow
  // Builds the content of the distance card
  // Uses given distance and returns a Text and Icon
  // nested inside a Row to display the user's distance from objective
  Widget _buildDistanceRow(BuildContext context, double? distanceKm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: Colors.deepPurple,
          size: 28,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            distanceKm != null
                ? AppLocalizations.of(context)!.distanceFromObjective(
                  distanceKm.toStringAsFixed(2),
                  objective.name,
                )
                : AppLocalizations.of(context)!.gettingLocation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // _buildMapWithMarker
  // Builds a zoomable and pannable UW campus map with a marker to point
  // at the objective using InteractiveViewer. Uses FractionallySizedBox,
  // AspectRatio, and LayoutBuilder to resize the image of UW campus
  // according the device dimensions without distortion.
  Widget _buildMapWithMarker(BuildContext context) {
    const double imageWidth = 750;
    const double imageHeight = 855;
    const double aspectRatio = imageWidth / imageHeight;

   return Center(
      child: Semantics(
        label: 'Zoomable and pannable map of UW campus',
        child: InteractiveViewer(
          maxScale: 5,
          minScale: 1,
          boundaryMargin: const EdgeInsets.only(left: 145, right: 145),
          child: FractionallySizedBox(
            widthFactor: 1.7,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Image.asset(
                        'lib/assets/uw_campus_map.png',
                        fit: BoxFit.contain,
                      ),
                      _buildMarker(constraints, imageWidth, imageHeight),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // _buildMarker
  // Uses given BoxConstraints, and dimensions of image to position a pin on the map
  // using objective's location on image as pixels
  Widget _buildMarker(
    BoxConstraints constraints,
    double imageWidth,
    double imageHeight,
  ) {
    return Positioned(
      left: (objective.pixelX / imageWidth) * constraints.maxWidth - 16,
      top:
          ((objective.pixelY / imageHeight) *
                  (constraints.maxWidth / (imageWidth / imageHeight))) *
              0.6 -
          48,
      child: const Icon(Icons.location_pin, color: Colors.red, size: 48),
    );
  }

  // calculateDistance
  // returns distance between two given points from their latitude and longitude
  // as a double using Haversine distance formula.
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  // _degreesToRadians
  // returns given degree to radian
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
