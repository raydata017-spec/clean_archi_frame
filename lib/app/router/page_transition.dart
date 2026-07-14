import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget _transitionList(
  int index,
  Animation<double> animation,
  Widget child,
) {
  switch (index) {
    case 0:
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        ),
        child: child,
      );
    case 1:
      return FadeTransition(opacity: animation, child: child);
    case 2:
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        ),
        child: child,
      );
    case 3:
      return ScaleTransition(scale: animation, child: child);
    default:
      return child;
  }
}

// Custom transition for pages
extension CustomTransitionPageX on Widget {
  Page customTransition(
    GoRouterState state, {
    int transitionTypeIndex = 0,
    bool disableSwipeBack = false,
  }) {
    // For iOS, use MaterialPage which integrates with Cupertino transitions/gestures
    // configured in light/dark theme and allows disabling swipe back via fullscreenDialog.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (transitionTypeIndex == 0 ||
          transitionTypeIndex == 2 ||
          disableSwipeBack) {
        return MaterialPage(
          key: state.pageKey,
          child: this,
          fullscreenDialog: disableSwipeBack || transitionTypeIndex == 2,
        );
      }
    }

    return CustomTransitionPage(
      key: state.pageKey,
      child: this,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _transitionList(transitionTypeIndex, animation, child);
      },
    );
  }
}
