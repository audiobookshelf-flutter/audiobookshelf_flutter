import 'dart:async';

import 'package:audiobookshelf/models/preferences.dart';
import 'package:audiobookshelf/repositories/media/abs_repository.dart';
import 'package:audiobookshelf/services/database/database_service.dart';
import 'package:audiobookshelf/repositories/media/media_repository.dart';
import 'package:audiobookshelf/services/download/download_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  String libraryId = ref.watch(
    preferencesProvider.select((prefs) => prefs.libraryId)
  );
  final absApi = ref.watch(absApiProvider);
  return AbsRepository(absApi, libraryId);
});

final Provider<DownloadService?> downloadServiceProvider =
    Provider<DownloadService?>((ref) {
  final mediaRepo = ref.watch(mediaRepositoryProvider);
  final db = ref.watch(databaseServiceProvider);
  return DownloadService(mediaRepo, db);
});

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, Preferences>((ref) => PreferencesNotifier());

class PreferencesNotifier extends StateNotifier<Preferences> {
  final DatabaseService _db = GetIt.I<DatabaseService>();

  PreferencesNotifier() : super(GetIt.I<DatabaseService>().getPreferences());

  Future save(Preferences value) async {
    await _db.insertPreferences(value);
    state = value;
  }
}
