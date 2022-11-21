import 'dart:async';
import 'package:audiobookshelf/ui/material_app.dart';
import 'package:audiobookshelf/singletons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loggy/loggy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy();

  await registerSingletons();
  runApp(
    const ProviderScope(
      child: AudiobookshelfApp(),
    ),
  );
}

class AudiobookshelfApp extends HookConsumerWidget {
  const AudiobookshelfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AbMaterialApp();
  }
}
