import 'package:audiobookshelf/material_ui/features/abs_login/abs_login.dart';
import 'package:audiobookshelf/domain/auth/auth_notifier.dart';
import 'package:audiobookshelf/services/navigation/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WelcomeView extends HookConsumerWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider.notifier);
    final navigationService = ref.watch(navigationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Audiobookshelf'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                navigationService.push(
                    MaterialPageRoute(builder: (context) => const AbsLogin()));
              },
              child: const Text('Login to Audiobookshelf'),
            ),
          ],
        ),
      ),
    );
  }
}
