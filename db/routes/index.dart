import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return Response.json(
    statusCode: 500,
    body: {'error': 'Failed to retrieve data \n'},
  );
}
