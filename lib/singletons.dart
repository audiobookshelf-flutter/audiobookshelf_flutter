import 'dart:io';

import 'package:audiobookshelf/services/audio/playback_controller.dart';
import 'package:audiobookshelf/services/audio/sleep_service.dart';
import 'package:audiobookshelf/services/database/database_service.dart';
import 'package:audiobookshelf/services/database/isar_database_service.dart';
import 'package:audiobookshelf/services/device_info/device_info_service.dart';
import 'package:audiobookshelf/services/download/desktop_downloader.dart';
import 'package:audiobookshelf/services/download/downloader.dart';
import 'package:audiobookshelf/services/download/mobile_background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.I;

bool registered = false;
Future<void> registerSingletons() async {
  if (registered) return;
  registered = true;

  final isar = await initIsar();
  getIt.registerLazySingleton<DatabaseService>(
    () => IsarDatabaseService(
      db: isar,
    ),
  );
  // clear db
  // await isar.writeTxn(() => isar.clear());

  PlaybackController controller;
  Downloader downloader;
  if (kIsWeb) {
    downloader = DesktopDownloader(getIt());
    final handler = await initAudioHandler();
    controller = AudioHandlerPlaybackController(handler);
  } else if ((!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)) {
    downloader = MobileBackgroundDownloader(getIt());
    final handler = await initAudioHandler();
    controller = AudioHandlerPlaybackController(handler);
  } else if (Platform.isMacOS) {
    downloader = DesktopDownloader(getIt());
    final handler = await initAudioHandler();
    controller = AudioHandlerPlaybackController(handler);
  } else {
    downloader = DesktopDownloader(getIt());
    final handler = await initAudioHandler();
    controller = AudioHandlerPlaybackController(handler);
  }

  getIt.registerSingleton(downloader);
  getIt.registerSingleton(controller);
  getIt.registerSingleton(SleepService(controller));

  final info = await getDeviceInfo();
  getIt.registerSingleton(DeviceInfoService(info));
}
