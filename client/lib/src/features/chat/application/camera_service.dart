import 'package:camera/camera.dart';

class CameraService {
  static Future<CameraController> initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    return controller;
  }

  static Future<XFile?> captureImage(CameraController controller) async {
    try {
      if (controller.value.isInitialized) {
        return await controller.takePicture();
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
    return null;
  }
}
