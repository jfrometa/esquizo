import 'package:dart_frog/dart_frog.dart';
import 'package:db/src/generated/prisma_client/client.dart';
import 'package:db/src/generated/prisma_client/prisma.dart';
import 'package:orm/orm.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Welcome to Dart Frog!');
}
