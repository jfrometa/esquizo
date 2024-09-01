import 'package:dart_frog/dart_frog.dart';
import 'package:db/db.dart';

final prisma = PrismaClient();
final userService = UserService(prisma);

Handler middleware(Handler handler) {
  return handler.use(provider<UserService>((context) => userService));
}
