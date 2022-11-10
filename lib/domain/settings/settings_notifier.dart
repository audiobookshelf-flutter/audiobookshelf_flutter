import 'package:audiobookshelf/constants/app_constants.dart';
import 'package:audiobookshelf/models/user.dart';
import 'package:audiobookshelf/repositories/media/media_repository.dart';
import 'package:audiobookshelf/domain/settings/settings_state.dart';
import 'package:audiobookshelf/providers.dart';
import 'package:audiobookshelf/services/database/database_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final settingsStateProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(mediaRepositoryProvider));
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final MediaRepository? _repository;
  User? currentUser;

  SettingsNotifier(this._repository) : super(const SettingsState.initial()) {
    getUser();
  }

  Future<void> getUser() async {
    try {
      DatabaseService db = GetIt.I();
      state = const SettingsState.loading();
      final prefs = db.getPreferencesSync();
      currentUser = User(userName: prefs.username, name: prefs.username);
      state = SettingsState.loaded(user: currentUser);
    } on Exception {
      state = const SettingsState.error(
          "Couldn't fetch user. Is the device online?");
    }
  }
}
