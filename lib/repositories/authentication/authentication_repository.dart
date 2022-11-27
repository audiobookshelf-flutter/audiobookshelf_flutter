import 'package:audiobookshelf/models/user.dart';

abstract class AuthenticationRepository {
  Future<User?> getUser();
  Future logout();
}
