import 'dart:async';

import 'package:audiobookshelf/domain/library_select/library_select_notifier.dart';
import 'package:audiobookshelf/models/user.dart';
import 'package:audiobookshelf/providers.dart';
import 'package:audiobookshelf/repositories/authentication/abs_auth_repository.dart';
import 'package:audiobookshelf/domain/auth/auth_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loggy/loggy.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthStateInitial()) {
    checkAuthState();
  }

  Future<bool> logout() async {
    final repo = _ref.read(absAuthRepoProvider);
    final prefsNotifier = _ref.read(preferencesProvider.notifier);
    final prefs = _ref.read(preferencesProvider);
    try {
      state = const AuthStateLoading();
      await repo.logout();
      await prefsNotifier.save(prefs.copyWith(
        baseUrl: '',
        userToken: '',
        userId: '',
        serverId: '',
        libraryId: '',
      ));
      state = const AuthStateInitial();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(
    String baseUrl,
    String username,
    String password,
  ) async {
    state = const AuthStateLoading();
    final prefsNotifier = _ref.read(preferencesProvider.notifier);
    final prefs = _ref.read(preferencesProvider);
    await prefsNotifier.save(
      prefs.copyWith(
        baseUrl: baseUrl,
      ),
    );
    try {
      User u = await _ref.read(absAuthRepoProvider).login(username, password);
      final prefsNotifier = _ref.read(preferencesProvider.notifier);
      final prefs = _ref.read(preferencesProvider);
      await prefsNotifier.save(
        prefs.copyWith(
          userId: u.id ?? '',
          username: u.name ?? '',
          userToken: u.token ?? '',
        ),
      );
      await checkAuthState();
      return u.token != null;
    } catch (e, stack) {
      logError(e, stack);
      state = const AuthStateInitial();
      return false;
    }
  }

  Future checkAuthState() async {
    try {
      state = const AuthStateLoading();
      final prefsNotifier = _ref.read(preferencesProvider.notifier);
      final prefs = _ref.read(preferencesProvider);

      if (prefs.baseUrl.isEmpty) {
        state = const AuthStateInitial();
        return;
      }

      if (prefs.userToken.isEmpty) {
        state = const AuthStateInitial();
        return;
      }

      logDebug('Checking token: ${prefs.userToken}');

      User? user;
      final userRepo = _ref.read(absAuthRepoProvider);
      user = await userRepo.getUser();

      if (user == null) {
        await prefsNotifier.save(
          prefs.copyWith(
            userToken: '',
          ),
        );
        state = const AuthStateInitial();
        return;
      }

      if (prefs.libraryId.isEmpty) {
        final libraryNotifier = _ref.read(libraryStateProvider.notifier);
        await libraryNotifier.getLibraries();
      }

      state = AuthStateLoaded(user: user);
    } catch (e, stack) {
      // if (e.toString().startsWith('Failed host lookup')) {
      //   state = const AuthStateOffline();
      // } else {
      logError(e, stack);
      state = AuthStateErrorDetails(e.toString());
      // }
    }
  }
}
