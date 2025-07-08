import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:husky_hunt/models/landmark.dart';
import 'package:husky_hunt/models/player.dart';
import 'package:husky_hunt/views/finish_screen.dart';
import 'package:provider/provider.dart';
import 'package:husky_hunt/providers/position_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// A StatefulWidget that displays a camera preview and handles photo capture
// based on the user's proximity to different locations at UW.
class CameraView extends StatefulWidget {
  // objective to take picture of
  final Landmark objective;
  // current player
  final Player? currentPlayer; 

  // Constructor
  // initializes fields
  const CameraView({super.key, required this.objective, required this.currentPlayer});

  // initializes _CameraViewState
  @override
  State<CameraView> createState() => _CameraViewState();
}

// The state for the CameraView widget that manages camera functionality
// and location-based photo capture permissions.
class _CameraViewState extends State<CameraView> {
  // Camera controller for managing camera operations
  CameraController? _controller;
  // Future for handling camera initialization
  Future<void>? _initializeControllerFuture;
  // Flags for tracking camera and photo states
  bool _isCameraReady = false;
  bool _photoTaken = false;

  // Target coordinates for Red Square
  late final double targetLat;
  late final double targetLong;

  @override
  void initState() {
    super.initState();
    targetLat = widget.objective.latitude;
    targetLong = widget.objective.longitude;
    _initializeCamera();
  }

  // Intializes the camera by fetching available cameras and setting up the controller
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    // Initialize the controller and set the state when done
    _initializeControllerFuture = _controller?.initialize().then((_) {
      if (mounted) {
        setState(() => _isCameraReady = true);
      }
    });
  }

  // Checking if user is close enough to the target
  bool _checkIfInRange(double? currentLat, double? currentLong) {
    if (currentLat == null || currentLong == null) return false;

    double distanceInMeters = Geolocator.distanceBetween(
      currentLat,
      currentLong,
      targetLat,
      targetLong,
    );

    return distanceInMeters <= 100; // 0.1km = 100 meters
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Builds the camera view with a preview and buttons to take a photo or proceed
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Camera screen for taking photo of ${widget.objective.name}',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 75, 0, 130),
          title: Semantics(
            label: 'Camera screen title',
            child: Text(
              AppLocalizations.of(context)!.takePhoto,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Semantics(
                label: 'Loading camera view',
                child: const Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Loading camera',
                  ),
                ),
              );
            }

            return Consumer<PositionProvider>(
              builder: (context, positionProvider, child) {
                bool isInRange = _checkIfInRange(
                  positionProvider.latitude,
                  positionProvider.longitude,
                );

                if (!_isCameraReady || _controller == null) {
                  return Semantics(
                    label: 'Camera initialization in progress',
                    child: const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Initializing camera',
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Semantics(
                      label: 'Camera preview window',
                      value: isInRange ? 'Ready to take photo' : 'Too far from target location',
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          if (!isInRange)
                            Semantics(
                              label: 'Distance warning',
                              value: AppLocalizations.of(context)!.getCloser,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  AppLocalizations.of(context)!.getCloser,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          Semantics(
                            label: 'Action buttons section',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (!_photoTaken)
                                  Semantics(
                                    label: isInRange ? 'Take photo button' : 'Take photo button disabled',
                                    value: isInRange ? 'Tap to take photo' : 'Too far from location to take photo',
                                    button: true,
                                    enabled: isInRange,
                                    onTapHint: 'Takes a photo of the location',
                                    child: ElevatedButton(
                                      onPressed:
                                          isInRange
                                              ? () async {
                                                // Store context in local variable
                                                final scaffoldMessenger =
                                                    ScaffoldMessenger.of(context);
                                                try {
                                                  await _controller!.takePicture();
                                                  if (mounted) {
                                                    // Check if widget is still mounted
                                                    setState(
                                                      () => _photoTaken = true,
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (mounted) {
                                                    // Check if widget is still mounted
                                                    scaffoldMessenger.showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.error(e.toString()),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                              : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          75,
                                          0,
                                          130,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 15,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        isInRange
                                            ? AppLocalizations.of(
                                              context,
                                            )!.takePhoto
                                            : AppLocalizations.of(
                                              context,
                                            )!.tooFarAway,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                if (_photoTaken)
                                  Semantics(
                                    label: 'Next button',
                                    value: 'Proceed to next step',
                                    button: true,
                                    onTapHint: 'Moves to the finish screen',
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FinishScreen(currentPlayer: widget.currentPlayer),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          75,
                                          0,
                                          130,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 15,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.next,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
