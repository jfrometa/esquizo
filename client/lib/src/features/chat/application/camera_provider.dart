import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cameraControllerProvider =
    StateProvider<CameraController?>((ref) => null);
final imageProvider = StateProvider<XFile?>((ref) => null);
