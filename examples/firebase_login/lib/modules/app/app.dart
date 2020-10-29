import 'package:binder/binder.dart';
import 'package:firebase_login/data/entities/user.dart';
import 'package:firebase_login/modules/authentication/logic.dart';
import 'package:firebase_login/modules/home/view.dart';
import 'package:firebase_login/modules/sign_in/view.dart';
import 'package:firebase_login/modules/splash/view.dart';
import 'package:firebase_login/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class App extends StatefulWidget {
  const App({
    Key key,
  }) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.use(authenticationLogicRef).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return StateListener(
          watchable: currentUserRef,
          onStateChanged: (context, User user) {
            if (user == User.empty) {
              _navigator.pushAndRemoveUntil<void>(
                SignInView.route(),
                (route) => false,
              );
            } else {
              _navigator.pushAndRemoveUntil<void>(
                HomeView.route(),
                (route) => false,
              );
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}
