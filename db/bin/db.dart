import 'package:db/db.dart';
import 'package:db/src/db_base.dart';

final prisma = PrismaClient();

Future<void> main() async {
  final prisma = PrismaClient();
  final userService = UserService(prisma);

  try {
    final user = await userService.createUser(
      email: 'john.doe@example.com2',
      name: 'John Doe2',
    );
    print('User created successfully: ${user?.name}');
  } catch (e) {
    print('Failed to create user: $e');
  }
}
