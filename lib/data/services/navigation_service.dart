import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> navigateTo(String routeName, {Object? arguments}) {
    final navigatorState = navigatorKey.currentState;
    if (navigatorState != null) {
      return navigatorState.pushNamed(routeName, arguments: arguments);
    } else {
      return Future.error('Navigator state is null');
    }
  }

  void goBack() {
    final navigatorState = navigatorKey.currentState;
    if (navigatorState?.canPop() ?? false) {
      navigatorState!.pop();
    }
  }
}
