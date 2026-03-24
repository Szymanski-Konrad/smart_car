import 'package:flutter/material.dart';
import 'package:smart_car/app/navigation/router.dart';
import 'package:smart_car/app/navigation/routes.dart';

import 'navigation.dart';

class PageNavigator extends StatelessWidget {
  const PageNavigator();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final key = Navigation.instance.key;
        final canPopNav = key.currentState?.canPop();
        if (canPopNav != null && canPopNav) {
          key.currentState?.maybePop();
        }
      },
      child: Navigator(
        key: Navigation.instance.key,
        initialRoute: SharedRoutes.home,
        onGenerateRoute: AppRouter.generate,
      ),
    );
  }
}
