import 'package:dart_frog/dart_frog.dart';
import 'package:db/db.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final userService = UserService(PrismaClient());

  if (id.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'User ID is required'},
    );
  }

  if (context.request.method == HttpMethod.get) {
    try {
      final user = await userService.getUserById(id);

      if (user == null) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'User not found'},
        );
      }

      return Response.json(body: user.toJson());
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Failed to retrieve user: $e'},
      );
    } finally {
      await userService.prisma
          .$disconnect(); // Ensure the Prisma client is disconnected
    }
  } else if (context.request.method == HttpMethod.put ||
      context.request.method == HttpMethod.patch) {
    final body = await context.request.json();
    final email = body['email'] as String?;
    final name = body['name'] as String?;

    try {
      final updatedUser =
          await userService.updateUser(id, email: email, name: name);
      return Response.json(body: updatedUser?.toJson());
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Failed to update user: $e'},
      );
    } finally {
      await userService.prisma
          .$disconnect(); // Ensure the Prisma client is disconnected
    }
  } else if (context.request.method == HttpMethod.delete) {
    try {
      await userService.deleteUser(id);
      return Response.json(
        body: {'message': 'User deleted successfully'},
      );
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Failed to delete user: $e'},
      );
    } finally {
      await userService.prisma
          .$disconnect(); // Ensure the Prisma client is disconnected
    }
  } else {
    return Response(statusCode: 405); // Method Not Allowed
  }
}
