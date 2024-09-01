import 'package:db/db.dart';
import 'package:orm/orm.dart'; // Ensure you have the ORM package imported

class UserService {
  final PrismaClient prisma;

  UserService(this.prisma);

  // Create a new user
  Future<User?> createUser({
    required String email,
    required String name,
    bool useUncheckedInput = false, // Flag to choose between input types
  }) async {
    // Validate inputs
    if (email.isEmpty || name.isEmpty) {
      throw ArgumentError('Email and name must not be empty');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }

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
      final newUser = await prisma.user.create(
        data: userData,
      );

      _log('User created: ${newUser.name}, ${newUser.email}');
      return newUser;
    } catch (e, stacktrace) {
      _logError('Error creating user', e, stacktrace);
      rethrow;
    } finally {
      await prisma.$disconnect();
    }
  }

  // Retrieve a user by ID
  Future<User?> getUserById(String id) async {
    try {
      final user = await prisma.user.findUnique(
        where: UserWhereUniqueInput(id: int.parse(id)),
      );
      return user;
    } catch (e) {
      _logError('Error retrieving user', e, StackTrace.current);
      rethrow;
    }
  }

  // Update a user by ID
  Future<User?> updateUser(String id, {String? email, String? name}) async {
    try {
      final userData = UserUpdateInput(
        email: email != null ? PrismaUnion.$1(email) : null,
        name: name != null ? PrismaUnion.$1(name) : null,
      );

      final updatedUser = await prisma.user.update(
        where: UserWhereUniqueInput(id: int.parse(id)),
        data: PrismaUnion.$1(userData),
      );

      _log(
        'User updated: ${updatedUser?.name ?? 'no name'}, ${updatedUser?.email ?? 'no email'}',
      );
      return updatedUser;
    } catch (e, stacktrace) {
      _logError('Error updating user', e, stacktrace);
      rethrow;
    } finally {
      await prisma.$disconnect();
    }
  }

  // Delete a user by ID
  Future<void> deleteUser(String id) async {
    try {
      await prisma.user.delete(
        where: UserWhereUniqueInput(id: int.parse(id)),
      );

      _log('User deleted: $id');
    } catch (e, stacktrace) {
      _logError('Error deleting user', e, stacktrace);
      rethrow;
    } finally {
      await prisma.$disconnect();
    }
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final users = await prisma.user.findMany();
      return users.toList();
    } catch (e, stacktrace) {
      _logError('Error retrieving users', e, stacktrace);
      rethrow;
    } finally {
      await prisma.$disconnect();
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _log(String message) {
    print('[INFO] $message');
  }

  void _logError(String message, Object error, StackTrace stacktrace) {
    print('[ERROR] $message: $error');
    print(stacktrace);
  }
}
