import 'package:audiobookshelf/mac_ui/features/home/home.dart';
import 'package:audiobookshelf/material_ui/widgets/auth_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class MacApp extends StatelessWidget {
  const MacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'Audiobookshelf',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark().copyWith(
        iconTheme: MacosThemeData.dark().iconTheme.copyWith(
              color: Colors.deepPurple,
            ),
        primaryColor: Colors.deepPurple,
        pushButtonTheme: MacosThemeData.dark().pushButtonTheme.copyWith(
              color: Colors.deepPurple,
            ),
        // iconButtonTheme: MacosThemeData.dark().iconButtonTheme.copyWith(
        //       backgroundColor: Colors.deepPurple,
        //     ),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: AuthWidget(
        authorizedBuilder: (context) => const Home(),
        errorBuilder: (context, message) => Container(),
        loadingBuilder: (context) => const CupertinoActivityIndicator(
          radius: 30.0,
        ),
        unauthorizedBuilder: (context) => Container(),
      ),
    );
  }
}
