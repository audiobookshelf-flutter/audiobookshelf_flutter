import 'package:audiobookshelf/constants/app_constants.dart';
import 'package:audiobookshelf/domain/auth/auth_notifier.dart';
import 'package:audiobookshelf/material_ui/features/abs_login/abs_login.dart';
import 'package:audiobookshelf/material_ui/features/offline/offline_view.dart';
import 'package:audiobookshelf/services/database/database_service.dart';
import 'package:audiobookshelf/services/navigation/navigation_service.dart';
import 'package:audiobookshelf/material_ui/features/player/mini_player.dart';
import 'package:audiobookshelf/material_ui/widgets/adaptive_scaffold.dart';
import 'package:audiobookshelf/material_ui/widgets/auth_widget.dart';
import 'package:audiobookshelf/material_ui/widgets/router.dart' as r;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AbMaterialApp extends HookConsumerWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final routeMap = [
    Routes.home,
    Routes.library,
    Routes.series,
    Routes.collections,
    Routes.authors,
  ];

  AbMaterialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationService = ref.watch(navigationServiceProvider);
    final db = ref.watch(databaseServiceProvider);
    final currentIndex = useState(0);
    // timeDilation = 7.0;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audiobookshelf',
      navigatorKey: navigationService.navigatorKey,
      onGenerateRoute: r.Router.generateRoute,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.amber,
        appBarTheme: const AppBarTheme(),
        brightness: Brightness.light,
        indicatorColor: Colors.amber,
        secondaryHeaderColor: Colors.amber,
        sliderTheme: const SliderThemeData(
          overlayColor: Colors.amber,
          thumbColor: Colors.amber,
          activeTrackColor: Colors.amber,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.amber,
          accentColor: Colors.amber,
          brightness: Brightness.light,
        ).copyWith(secondary: Colors.amber),
        // canvasColor: Colors.grey[900],
      ),
      darkTheme: ThemeData(
        indicatorColor: Colors.amber,
        cardTheme: const CardTheme(
          clipBehavior: Clip.antiAlias,
          color: Colors.black,
        ),
        sliderTheme: const SliderThemeData(
          overlayColor: Colors.amber,
          thumbColor: Colors.amber,
          activeTrackColor: Colors.amber,
        ),
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.amber,
          accentColor: Colors.amber,
          brightness: Brightness.dark,
          backgroundColor: Colors.grey[900],
        ).copyWith(secondary: Colors.amber),
        // canvasColor: Colors.grey[900],
      ),
      home: AuthWidget(
        loadingBuilder: (context) => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        authorizedBuilder: (context) {
          return WillPopScope(
            onWillPop: () async {
              return !await _navigatorKey.currentState!.maybePop();
            },
            child: AdaptiveScaffold(
                title: const Text('Audiobookshelf'),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Navigator(
                        key: _navigatorKey,
                        onGenerateRoute: r.Router.generateRoute,
                        initialRoute: Routes.home,
                      ),
                    ),
                    const MiniPlayer(),
                  ],
                ),
                currentIndex: currentIndex.value,
                onNavigationIndexChange: (index) {
                  if (index != currentIndex.value) {
                    String oldRoute = routeMap[currentIndex.value];
                    String newRoute = routeMap[index];
                    currentIndex.value = index;
                    _navigatorKey.currentState!.pushNamedAndRemoveUntil(
                      newRoute,
                      ModalRoute.withName(oldRoute),
                    );
                  }
                },
                destinations: const [
                  Destination(
                    title: 'Home',
                    icon: Icons.home,
                  ),
                  Destination(
                    title: 'Library',
                    icon: Icons.book,
                  ),
                  Destination(
                    title: 'Series',
                    icon: Icons.window,
                  ),
                  Destination(
                    title: 'Collections',
                    icon: Icons.collections_bookmark,
                  ),
                  Destination(
                    title: 'Authors',
                    icon: Icons.people,
                  ),
                ]),
          );
        },
        unauthorizedBuilder: (context) => const AbsLogin(),
        errorBuilder: (context, error) => Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                        'Could not connect to server, is the device online?'),
                  ),
                  ElevatedButton(
                    child: const Text('Offline Mode'),
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).checkToken();
                      ref.read(navigationServiceProvider).push(
                          MaterialPageRoute(
                              builder: (context) => const Offline()));
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Retry?'),
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).checkToken();
                    },
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
