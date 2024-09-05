import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/speach_to_text/speach_to_text_notifier.dart';

class SpeechToTextScreen extends ConsumerWidget {
  const SpeechToTextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the speech state using Riverpod
    final speechState = ref.watch(speechToTextNotifierProvider);
    final speechNotifier = ref.read(speechToTextNotifierProvider.notifier);
    
    // Get screen height to calculate 35% of the screen height
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxHeight = screenHeight * 0.35; // 35% of the screen height

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text with Food Detection'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          // Buttons for start/stop listening will take full space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.mic, size: 24, color: Colors.white),
                        label: const Text(
                          'Start Listening',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 20.0,
                          ),
                        ),
                        onPressed: !speechState.isListening
                            ? () {
                                speechNotifier.startListening(
                                    localeId: speechState.systemLocale);
                              }
                            : null,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.stop, size: 24, color: Colors.white),
                        label: const Text(
                          'Stop Listening',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 20.0,
                          ),
                        ),
                        onPressed: speechState.isListening
                            ? () {
                                speechNotifier.stopListening();
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Speech display starts small and grows up to 35% of the screen
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Recognized Speech:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 50, // Minimum height for roughly two lines
                    maxHeight: maxHeight, // Maximum 35% of the screen height
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        speechState.recognizedWords.isNotEmpty
                            ? speechState.recognizedWords
                            : 'No speech detected yet...',
                        style: const TextStyle(fontSize: 18, color: Colors.black87),
                        scrollPhysics: const BouncingScrollPhysics(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Detected food items
                if (speechState.detectedFoods.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Food Items Detected:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        speechState.detectedFoods.join(', '),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}