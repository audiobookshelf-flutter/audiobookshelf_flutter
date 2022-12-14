import 'package:audiobookshelf/ios_ui/features/abs_login/abs_login.dart';
import 'package:audiobookshelf/services/navigation/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WelcomeView extends HookConsumerWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final auth = ref.watch(authNotifierProvider.notifier);
    final navigationService = ref.watch(navigationServiceProvider);

    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoButton(
                color: const Color.fromRGBO(161, 133, 67, 1),
                onPressed: () {
                  navigationService.push(CupertinoPageRoute(
                      builder: (context) => const AbsLogin()));
                },
                child: const Text('Login to Audiobookshelf'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
