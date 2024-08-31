import 'package:db/db.dart';
import 'package:orm/orm.dart'; // Ensure you have the ORM package imported

class UserService {
  final PrismaClient prisma;

  UserService(this.prisma);

  Future<User?> createUser({
    required String email,
    required String name,
    bool useUncheckedInput = false, // Flag to choose between input types
  }) async {
    // Validate inputs
    if (email.isEmpty || name.isEmpty) {
      throw ArgumentError('Email and name must not be empty');
    }

    // Use regex or a library to validate email format in a real-world scenario
    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }

    // Create the appropriate input object based on the flag
    final userData = useUncheckedInput
        ? PrismaUnion<UserCreateInput, UserUncheckedCreateInput>.$2(
            UserUncheckedCreateInput(
              name: PrismaUnion.$1(name),
              email: email,
            ),
          )
        : PrismaUnion<UserCreateInput, UserUncheckedCreateInput>.$1(
            UserCreateInput(
              name: PrismaUnion.$1(name),
              email: email,
            ),
          );

    try {
      // Create a new User and await the result directly
      final newUser = await prisma.user.create(
        data: userData,
      );

      // Log the successful creation
      _log('User created: ${newUser.name}, ${newUser.email}');
      return newUser;
    } catch (e, stacktrace) {
      // Log the error with stack trace
      _logError('Error creating user', e, stacktrace);
      // Rethrow to allow the caller to handle it as well
      rethrow;
    } finally {
      // Ensure the Prisma client is disconnected to avoid resource leaks
      await prisma.$disconnect();
    }
  }

  bool _isValidEmail(String email) {
    // Simple email regex for demonstration purposes
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _log(String message) {
    // Placeholder for logging, replace with a proper logging framework
    print('[INFO] $message');
  }

  void _logError(String message, Object error, StackTrace stacktrace) {
    // Placeholder for error logging, replace with a proper logging framework
    print('[ERROR] $message: $error');
    print(stacktrace);
  }
}
