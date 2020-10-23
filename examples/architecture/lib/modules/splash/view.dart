import 'package:architecture/core/widgets/logic_loader.dart';
import 'package:architecture/modules/splash/logic.dart';
import 'package:architecture/modules/app/route_names.dart' as route_names;
import 'package:binder/binder.dart';
import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LogicLoader(
      loader: (context) => context.use(splashViewLogicRef).load(),
      child: StateListener(
        watchable: navigationResultRef,
        onStateChanged: (context, NavigationResult state) {
          final navigator = Navigator.of(context);
          if (state is NavigateToHome) {
            navigator.pushReplacementNamed(route_names.home);
          } else if (state is NavigateToAuthentication) {
            navigator.pushReplacementNamed(route_names.authentication);
          }
        },
        child: Scaffold(
          body: Center(
            child: Text(
              'Architecture Example',
              style: Theme.of(context).textTheme.headline2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
