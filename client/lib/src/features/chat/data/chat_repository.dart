import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:image_picker/image_picker.dart';
import 'package:starter_architecture_flutter_firebase/src/extensions/extensions.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/data/storage_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/message.dart';
import 'package:starter_architecture_flutter_firebase/src/features/prompt/domain/prompt_model.dart';
import 'package:uuid/uuid.dart';

//   final model =
//       FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');
// // Provide a prompt that contains text
//   final prompt = [
//     Content.text(
//         'tell me where can i find the recepies app from google io 2024')
//   ];

// // To generate text output, call generateContent with the text input
//   final response = await model.generateContent(prompt);

@immutable
class ChatRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final model =
      FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');

  //! This method sends an image alongside the text
  Future sendMessage({
    required String? apiKey,
    required XFile? image,
    required String promptText,
  }) async {
    final userId = _auth.currentUser!.uid;
    final sentMessageId = const Uuid().v4();

    Message message = Message(
      id: sentMessageId,
      message: promptText,
      createdAt: DateTime.now(),
      isMine: true,
    );

    if (image != null) {
      // Save image to Firebase Storage and get download url
      final downloadUrl = await StorageRepository().saveImageToStorage(
        image: image,
        messageId: sentMessageId,
      );

      message = message.copyWith(
        imageUrl: downloadUrl,
      );
    }

    // Save Message to Firebase
    await _firestore
        .collection('conversations')
        .doc(userId)
        .collection('messages')
        .doc(sentMessageId)
        .set(message.toMap());

    // Create a response
    GenerateContentResponse response;

    try {
      if (image == null) {
        // Make a text only request to Gemini API
        // response = await model.generativeModel(model: model) //.generateContent([Content.text(promptText)]);
        var prompt = [Content.text(promptText)];

      // To generate text output, call generateContent with the text input
        response = await model.generateContent(prompt);
      } else {
        // convert it to Uint8List
        final imageBytes = await image.readAsBytes();

        // Define your parts
        final prompt = TextPart(promptText);
        final mimeType = image.getMimeTypeFromExtension();
        final imagePart = DataPart('image/jpeg', imageBytes);

        // Make a mutli-model request to Gemini API
        response = await model.generateContent([
          Content.multi([
            prompt,
            imagePart,
          ])
        ]);
      }

      final responseText = response.text;

      // Save the response in Firebase
      final receivedMessageId = const Uuid().v4();

      final responseMessage = Message(
        id: receivedMessageId,
        message: responseText!,
        createdAt: DateTime.now(),
        isMine: false,
      );

      // Save Message to Firebase
      await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .doc(receivedMessageId)
          .set(responseMessage.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //! Send Text Only Prompt
  Future sendTextMessage({
    required String textPrompt,
    required String apiKey,
  }) async {
    try {
      // Define your model
      // final textModel = model.generateContent(model: 'gemini-pro', apiKey: apiKey);

      final userId = _auth.currentUser!.uid;
      final sentMessageId = const Uuid().v4();

      Message message = Message(
        id: sentMessageId,
        message: textPrompt,
        createdAt: DateTime.now(),
        isMine: true,
      );

      // Save Message to Firebase
      await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .doc(sentMessageId)
          .set(message.toMap());

      // Make a text only request to Gemini API and save the response
      final response = await model.generateContent([Content.text(textPrompt)]);

      final responseText = response.text;

      // Save the response in Firebase
      final receivedMessageId = const Uuid().v4();

      final responseMessage = Message(
        id: receivedMessageId,
        message: responseText!,
        createdAt: DateTime.now(),
        isMine: false,
      );

      // Save Message to Firebase
      await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .doc(receivedMessageId)
          .set(responseMessage.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

class GeminiService {
  static Future<GenerateContentResponse> generateContent(
      GenerativeModel model, PromptData prompt) async {
    if (prompt.images.isEmpty) {
      return await GeminiService.generateContentFromText(model, prompt);
    } else {
      return await GeminiService.generateContentFromMultiModal(model, prompt);
    }
  }

  static Future<GenerateContentResponse> generateContentFromMultiModal(
      GenerativeModel model, PromptData prompt) async {
    final mainText = TextPart(prompt.textInput);
    final additionalTextParts =
        prompt.additionalTextInputs.map((t) => TextPart(t));
    final imagesParts = <DataPart>[];

    for (var f in prompt.images) {
      final bytes = await (f.readAsBytes());
      imagesParts.add(DataPart('image/jpeg', bytes));
    }

    final input = [
      Content.multi([...imagesParts, mainText, ...additionalTextParts])
    ];

    return await model.generateContent(
      input,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],
    );
  }

  static Future<GenerateContentResponse> generateContentFromText(
      GenerativeModel model, PromptData prompt) async {
    final mainText = TextPart(prompt.textInput);
    final additionalTextParts =
        prompt.additionalTextInputs.map((t) => TextPart(t)).join("\n");

    return await model.generateContent([
      Content.text(
        '${mainText.text} \n $additionalTextParts',
      )
    ]);
  }
}
