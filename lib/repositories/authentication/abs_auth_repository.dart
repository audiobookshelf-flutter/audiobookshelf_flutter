import 'package:audiobookshelf/models/user.dart';
import 'package:audiobookshelf/repositories/media/abs_repository.dart';
import 'package:audiobookshelf/repositories/authentication/authentication_repository.dart';
import 'package:audiobookshelf_api/audiobookshelf_api.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final absAuthRepoProvider = Provider<AbsAuthRepository>((ref) {
  final api = ref.watch(absApiProvider);
  return AbsAuthRepository(api);
});

class AbsAuthRepository extends AuthenticationRepository {
  final AudiobookshelfApi _api;

  AbsAuthRepository(this._api);

  @override
  Future<User?> getUser() async {
    final user = await _api.getUser();
    return User(
      name: user.username,
      userName: user.username,
      token: user.token,
    );
  }

  @override
  Future<bool> logout() async {
    return true;
  }

  Future<User> login(String username, String password) async {
    final res = await _api.login(username, password);
    return User(
      id: res.user.id,
      name: res.user.username,
      userName: res.user.username,
      token: res.user.token,
    );
  }
}
