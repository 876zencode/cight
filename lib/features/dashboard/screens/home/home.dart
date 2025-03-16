import 'dart:io';

import 'package:awesome_ripple_animation/awesome_ripple_animation.dart';
import 'package:camera/camera.dart';
import 'package:cight/data/services/image_upload.dart';
import 'package:cight/data/services/text_to_speech.dart';
import 'package:cight/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  final ImageUploadService _imageService = ImageUploadService();

  final TextToSpeechService _ttsService = TextToSpeechService();

  Future<void> _captureImage() async {
    HapticFeedback.vibrate();
    if (_isProcessing) return; // Prevent multiple taps

    setState(() => _isProcessing = true);

    try {
      // Initialize the camera
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _controller = CameraController(firstCamera, ResolutionPreset.medium);
      await _controller!.initialize();

      // Capture the image
      final image = await _controller!.takePicture();

      // Convert to PNG
      final textForSpeech = await _convertToPng(image.path);
      _ttsService.speak(textForSpeech);

      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text('Image saved: $pngPath')));
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      // Dispose of the camera after use
      await _controller?.dispose();
      setState(() => _isProcessing = false);
    }
  }

  Future<String> _convertToPng(String imagePath) async {
    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();

    // Decode JPEG and re-encode as PNG
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) throw Exception("Failed to decode image");
    final pngBytes = img.encodePng(image);

    // Save PNG file
    final directory = await getApplicationDocumentsDirectory();
    final pngPath = '${directory.path}/captured_image.png';
    final pngFile = File(pngPath);

    // Ensure the PNG file is fully written before uploading
    await pngFile.writeAsBytes(pngBytes);

    print("PNG saved at: $pngPath");

    // Debug: Check if the file exists
    if (!await pngFile.exists()) {
      throw Exception("PNG file not saved properly");
    }

    // Upload image and get response
    String response = await _imageService.uploadImage(pngFile);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isProcessing == false
              ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: const Text(
                      'Tap to trigger cight.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RippleAnimation(
                        repeat: true,
                        color: Colors.lightGreen,
                        minRadius: 100,
                        ripplesCount: 6,
                        size: Size.square(300),
                        child: Material(
                          color: Colors.black26,
                          elevation: 8,
                          shape: CircleBorder(),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: InkWell(
                            splashColor: Colors.black26,
                            onTap: _captureImage,
                            child: Ink.image(
                              image: AssetImage(TImages.defaultAppLogo),
                              height: 300,
                              width: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
              : Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: Colors.green,
                  size: 150,
                ),
              ),
      bottomNavigationBar: Image.asset(TImages.bottomImage),
    );
  }
}
