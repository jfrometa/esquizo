import 'package:dart_frog/dart_frog.dart';
import 'package:db/db.dart';

Future<Response> onRequest(RequestContext context) async {
  final userService = UserService(PrismaClient());

  if (context.request.method == HttpMethod.get) {
    try {
      final users = await userService.getAllUsers();
      return Response.json(body: users.map((user) => user.toJson()).toList());
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Failed to retrieve users: $e'},
      );
    } finally {
      await userService.prisma.$disconnect();
    }
  } else if (context.request.method == HttpMethod.post) {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final name = body['name'] as String?;

    if (email == null || name == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Email and name are required'},
      );
    }

    try {
      final newUser = await userService.createUser(email: email, name: name);
      return Response.json(body: newUser?.toJson(), statusCode: 201);
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Failed to create user: $e'},
      );
    } finally {
      await userService.prisma.$disconnect();
    }
  } else {
    return Response(statusCode: 405); // Method Not Allowed
  }
}
