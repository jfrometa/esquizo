import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/prompt/data/prompt_view_model.dart';

final promptNotifierProvider =
    StateNotifierProvider<PromptNotifier, PromptState>(
  (ref) {
    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-flash',
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
    return PromptNotifier(
      multiModalModel: model,
      textModel: model,
    );
  },
);
