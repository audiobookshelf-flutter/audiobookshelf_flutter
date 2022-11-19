import 'dart:async';

import 'package:audiobookshelf/models/preferences.dart';
import 'package:audiobookshelf/repositories/media/abs_repository.dart';
import 'package:audiobookshelf/services/database/database_service.dart';
import 'package:audiobookshelf/repositories/media/media_repository.dart';
import 'package:audiobookshelf/services/download/download_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final mediaRepositoryProvider = Provider<MediaRepository?>((ref) {
  ServerType serverType = ref.watch(
    preferencesProvider.select((prefs) => prefs.serverType),
  );
  Preferences prefs = ref.read(preferencesProvider);
  if (serverType == ServerType.audiobookshelf) {
    final absApi = ref.watch(absApiProvider);
    return AbsRepository(absApi, prefs.libraryId);
  } else {
    return null;
  }
});

final Provider<DownloadService?> downloadServiceProvider =
    Provider<DownloadService?>((ref) {
  final mediaRepo = ref.watch(mediaRepositoryProvider);
  final db = ref.watch(databaseServiceProvider);
  if (mediaRepo != null) {
    return DownloadService(mediaRepo, db);
  } else {
    return null;
  }
});

class PreferencesNotifier extends StateNotifier<Preferences> {
  late StreamSubscription sub;
  late DatabaseService _db;

  PreferencesNotifier()
      : super(GetIt.I<DatabaseService>().getPreferencesSync()) {
    _db = GetIt.I<DatabaseService>();
    sub = _db.watchPreferences().listen((prefs) {
      print('Got preferences $prefs');
      if (prefs != null) state = prefs;
    });
  }

  Future savePreferences(Preferences prefs) async {
    await _db.insertPreferences(prefs);
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, Preferences>(
        (ref) => PreferencesNotifier());
