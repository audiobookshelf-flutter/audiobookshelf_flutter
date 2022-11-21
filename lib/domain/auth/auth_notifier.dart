import 'dart:async';

import 'package:audiobookshelf/domain/library_select/library_select_notifier.dart';
import 'package:audiobookshelf/models/preferences.dart';
import 'package:audiobookshelf/models/user.dart';
import 'package:audiobookshelf/repositories/authentication/abs_auth_repository.dart';
import 'package:audiobookshelf/services/navigation/navigation_service.dart';
import 'package:audiobookshelf/domain/auth/auth_state.dart';
import 'package:audiobookshelf/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loggy/loggy.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthStateInitial()) {
    checkToken();
  }

  Future<bool> logout() async {
    try {
      state = const AuthStateLoading();
      final prefsNotifier = _ref.read(preferencesProvider.notifier);
      Preferences prefs = prefsNotifier.state;
      prefs.userToken = '';
      prefs.baseUrl = '';
      prefs.serverId = '';
      prefs.userId = '';
      prefs.libraryId = '';
      prefsNotifier.savePreferences(prefs);
      state = const AuthStateInitial();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> absLogin(
    String baseUrl,
    String username,
    String password,
  ) async {
    User u =
        await _ref.read(absAuthRepoProvider).login(baseUrl, username, password);
    return u.token != null;
  }

  Future checkToken() async {
    try {
      state = const AuthStateLoading();
      final prefsNotifier = _ref.read(preferencesProvider.notifier);
      Preferences prefs = prefsNotifier.state;
      final navigationService = _ref.read(navigationServiceProvider);
      logDebug('Checking token: ${prefs.userToken}');

      User? user;
      if (prefs.userToken.isNotEmpty) {
        final userRepo = _ref.read(absAuthRepoProvider);
        user = await userRepo.getUser(prefs.userToken);
        logDebug(user);
        if (prefs.libraryId.isEmpty) {
          final libraryNotifier = _ref.read(libraryStateProvider.notifier);
          await libraryNotifier.getLibraries();
        }
      }

      if (user != null) {
        state = AuthStateLoaded(user: user);
      } else {
        prefs.userToken = '';
        prefsNotifier.savePreferences(prefs);
        state = const AuthStateInitial();
      }
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
