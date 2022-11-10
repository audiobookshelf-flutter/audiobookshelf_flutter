import 'dart:async';
import 'dart:io';

import 'package:audiobookshelf/ios_ui/features/library_select/library_select_view.dart';
import 'package:audiobookshelf/models/preferences.dart';
import 'package:audiobookshelf/models/user.dart';
import 'package:audiobookshelf/repositories/authentication/abs_auth_repository.dart';
import 'package:audiobookshelf/services/navigation/navigation_service.dart';
import 'package:audiobookshelf/domain/auth/auth_state.dart';
import 'package:audiobookshelf/material_ui/features/library_select/library_select_view.dart';
import 'package:audiobookshelf/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      prefs.serverType = ServerType.unknown;
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
      print('Checking token: ${prefs.userToken}');

      User? user;
      if (prefs.serverType == ServerType.audiobookshelf) {
        final userRepo = _ref.read(absAuthRepoProvider);
        user = await userRepo.getUser(prefs.userToken);
        print(user);
        if (prefs.libraryId.isEmpty) {
          if (Platform.isIOS || Platform.isMacOS) {
            await navigationService.push(
              CupertinoPageRoute(builder: (context) {
                return const IosLibrarySelectView();
              }),
            );
          } else {
            await navigationService.push(
              MaterialPageRoute(builder: (context) {
                return const LibrarySelectView();
              }),
            );
          }
        }
      } else {}

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
      print(e);
      print(stack);
      state = AuthStateErrorDetails(e.toString());
      // }
    }
  }
}
