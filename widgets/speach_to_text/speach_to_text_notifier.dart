import 'package:speech_to_text/speech_to_text.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'speach_to_text_notifier.g.dart';

@riverpod
class SpeechToTextNotifier extends _$SpeechToTextNotifier {
  final SpeechToText _speech = SpeechToText();

  @override
  SpeechToTextState build() {
    // Initialize the state when the notifier is first created
    return SpeechToTextState();
  }

  Future<void> initSpeech() async {
    if (!state.isInitialized) {
      final available = await _speech.initialize();
      state = state.copyWith(
        isAvailable: available,
        systemLocale: 'es-ES',
        isInitialized: true, // Mark as initialized
      );
    }
  }

  void startListening({required String localeId}) async {
  // Ensure speech is initialized before starting to listen
  if (!state.isInitialized) {
    await initSpeech(); // Ensure initialization
  }

  if (state.isAvailable && !state.isListening) {
    _speech.listen(
      localeId: 'es-ES',
      listenOptions: SpeechListenOptions(partialResults: true),
      onResult: (result) {
        state = state.copyWith(
          recognizedWords: result.recognizedWords,
        );
        state = state.copyWith(isListening: true);
      },
    );
    
  }
}

  void stopListening() {
    _speech.stop();
    state = state.copyWith(isListening: false);
  }

  void cancelListening() {
    _speech.cancel();
    state = state.copyWith(isListening: false);
  }

  void extractFoodItems() {
    final List<String> foodList = ['apple', 'banana', 'pizza', 'burger', 'salad'];
    List<String> detectedFoods = [];

    for (var food in foodList) {
      if (state.recognizedWords.toLowerCase().contains(food)) {
        detectedFoods.add(food);
      }
    }

    state = state.copyWith(detectedFoods: detectedFoods);
  }
}

class SpeechToTextState {
  final bool isAvailable;
  final bool isListening;
  final bool isInitialized;
  final String systemLocale;
  final String recognizedWords;
  final List<String> detectedFoods;

  SpeechToTextState({
    this.isAvailable = false,
    this.isListening = false,
    this.isInitialized = false,
    this.systemLocale = '',
    this.recognizedWords = '',
    this.detectedFoods = const [],
  });

  SpeechToTextState copyWith({
    bool? isAvailable,
    bool? isListening,
    bool? isInitialized,
    String? systemLocale,
    String? recognizedWords,
    List<String>? detectedFoods,
  }) {
    return SpeechToTextState(
      isAvailable: isAvailable ?? this.isAvailable,
      isListening: isListening ?? this.isListening,
      isInitialized: isInitialized ?? this.isInitialized,
      systemLocale: systemLocale ?? this.systemLocale,
      recognizedWords: recognizedWords ?? this.recognizedWords,
      detectedFoods: detectedFoods ?? this.detectedFoods,
    );
  }
}