import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/dialogflow/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/dialogflow/v3.dart' as df;
import 'package:http/http.dart' as http;

class AuthClient {
  static const _scopes = [df.DialogflowApi.cloudPlatformScope];

  /// Retrieves the `DialogflowApi` instance.
  ///
  /// This function loads the service account JSON file from the `assets/key.json`
  /// file and creates the necessary credentials. It then creates a client
  /// using the `clientViaServiceAccount` function and the loaded credentials.
  ///
  /// The function specifies the base URL for the correct region, which in this
  /// case is `https://us-central1-dialogflow.googleapis.com/`.
  ///
  /// Returns a `Future` that resolves to a `DialogflowApi` instance.
  static Future<df.DialogflowApi> getDialogflowApi() async {
    final serviceAccountJson = await rootBundle.loadString('assets/key.json');
    final credentials =
        ServiceAccountCredentials.fromJson(json.decode(serviceAccountJson));

    final client = await clientViaServiceAccount(credentials, _scopes);

    const endpoint = 'https://us-central1-dialogflow.googleapis.com/';

    return df.DialogflowApi(client, rootUrl: endpoint);
  }
}

class ChatbotClient {
  final String projectId;
  final String agentId;
  final String location;

  ChatbotClient(
      {required this.projectId, required this.agentId, required this.location});

  Future<String> sendMessage(String sessionId, String message) async {
    final dialogflow = await AuthClient.getDialogflowApi();
    final sessionPath =
        'projects/$projectId/locations/$location/agents/$agentId/sessions/$sessionId';
    final queryInput = df.GoogleCloudDialogflowCxV3QueryInput(
      languageCode: 'en',
      text: df.GoogleCloudDialogflowCxV3TextInput(text: message),
    );

    final response =
        await dialogflow.projects.locations.agents.sessions.detectIntent(
      df.GoogleCloudDialogflowCxV3DetectIntentRequest(queryInput: queryInput),
      sessionPath,
    );
    final queryResult = response.queryResult;
    if (queryResult != null &&
        queryResult.responseMessages != null &&
        queryResult.responseMessages!.isNotEmpty) {
      debugPrint(queryResult.responseMessages!.first.text!.text!.toString());
      return queryResult.responseMessages!.first.text!.text!.first;
    } else {
      return 'No response from chatbot';
    }
  }
}
