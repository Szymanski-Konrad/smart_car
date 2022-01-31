import 'package:flutter/material.dart';
import 'package:smart_car/app/navigation/router.dart';
import 'package:smart_car/app/navigation/routes.dart';

import 'navigation.dart';

class PageNavigator extends StatelessWidget {
  const PageNavigator();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final key = Navigation.instance.key;
        final canPop = key.currentState?.canPop();
        if (canPop != null && canPop) {
          key.currentState?.maybePop();
          return false;
        }
        return true;
      },
      child: Navigator(
        key: Navigation.instance.key,
        initialRoute: SharedRoutes.home,
        onGenerateRoute: AppRouter.generate,
      ),
    );
  }
}
