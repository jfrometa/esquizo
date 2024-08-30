import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/application/camera_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/application/camera_service.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/application/get_all_messages_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:starter_architecture_flutter_firebase/src/widgets/button.dart';

class SendImageScreen extends ConsumerStatefulWidget {
  const SendImageScreen({super.key});

  @override
  ConsumerState<SendImageScreen> createState() => _SendImageScreenState();
}

class _SendImageScreenState extends ConsumerState<SendImageScreen> {
  XFile? image;
  late final TextEditingController _promptController;
  bool isLoading = false;
  final apiKey = 'AIzaSyCG1Vl2PQiF4NH4k-Y4tru_ShrvygYHzgo';
  CameraController? _cameraController;
  // final apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';

  @override
  void initState() {
    _promptController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final pickedImage = await pickImage();
    if (pickedImage == null) {
      return;
    }
    ref.read(imageProvider.notifier).state = pickedImage;
    // setState(() => image = pickedImage);
  }

  void _removeImage() async {
    ref.read(imageProvider.notifier).state = null;
    setState(() {
      image = null;
    });
  }

  Future<void> _initializeCamera() async {
    _cameraController = await CameraService.initializeCamera();
    ref.read(cameraControllerProvider.notifier).state = _cameraController;
    setState(() {});
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await _initializeCamera();
    }

    final image = await CameraService.captureImage(_cameraController!);
    if (image != null) {
      ref.read(imageProvider.notifier).state = image;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = ref.watch(imageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Image Prompt!'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Column(
              children: [
                SizedBox(
                  height: 300,
                  // color: Colors.grey[200],
                  child: image == null
                      ? const Center(
                          child: Text(
                            'No Image Selected',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : !kIsWeb
                          ? Image.file(
                              File(image.path),
                              fit: BoxFit.cover
                            )
                          :  CachedNetworkImage(
                              imageUrl: image.path,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red,),
                              ) ,
                ),
              ],
            ),
            // Pick and Remove image buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CupertinoButton.filled(
                      onPressed: _pickImage,
                      padding: EdgeInsets.zero,
                      child: const Text('Pick Image'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoButton.filled(
                      padding: EdgeInsets.zero,
                      onPressed: _removeImage,
                      child: const Text('Remove Image'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoButton.filled(
                      padding: EdgeInsets.zero,
                      onPressed: _captureImage,
                      child: const Text(
                        'Capture Image',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Text Field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _promptController,
                decoration: const InputDecoration(
                  hintText: 'Write something about the image...',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(height: 16),
            // Send Message Button
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 32),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                      ),
                    )
                  : Button.primary(
                      onPressed: () async {
                        if (image == null) return;
                        setState(() => isLoading = true);
                        await ref.read(chatProvider).sendMessage(
                              apiKey: apiKey,
                              image: image,
                              promptText: _promptController.text.trim(),
                            );
                        setState(() => isLoading = false);
                        ref.read(imageProvider.notifier).state = null;

                        if(mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      text: const Text('Send Message'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
