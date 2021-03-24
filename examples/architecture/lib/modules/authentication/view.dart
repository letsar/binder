import 'package:architecture/core/logics/busy.dart';
import 'package:architecture/core/widgets/busy_listener.dart';
import 'package:architecture/modules/authentication/logic.dart';
import 'package:architecture/modules/app/route_names.dart' as route_names;
import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AuthenticationView extends StatelessWidget {
  const AuthenticationView({
    Key key,
    this.logicOverride,
  }) : super(key: key);

  final BinderOverride<AuthenticationViewLogic> logicOverride;

  @override
  Widget build(BuildContext context) {
    return BinderScope(
      overrides: [
        busyRef.overrideWith(false),
        logicOverride ?? authenticationViewLogicRef.overrideWithSelf(),
      ],
      child: BusyListener(
        child: AuthenticationResultHandler(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Authentication'),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  UsernameInput(),
                  Gap(12),
                  PasswordInput(),
                  Gap(12),
                  RememberMeInput(),
                  Gap(24),
                  SignInButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticationResultHandler extends StatelessWidget {
  const AuthenticationResultHandler({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StateListener<AuthenticationResult>(
      watchable: authenticationResultRef,
      onStateChanged: (BuildContext context, AuthenticationResult state) {
        if (state is AuthenticationFailure) {
          showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Authentication failed'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Ok'),
                  ),
                ],
              );
            },
          );
        } else {
          Navigator.of(context).pushReplacementNamed(route_names.home);
        }
      },
      child: child,
    );
  }
}

class UsernameInput extends StatelessWidget {
  const UsernameInput({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(labelText: 'username'),
      onChanged: (value) => context.logic.username = value,
    );
  }
}

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(labelText: 'password'),
      onChanged: (value) => context.logic.password = value,
    );
  }
}

class RememberMeInput extends StatelessWidget {
  const RememberMeInput({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Remember me'),
        const Gap(12),
        Switch(
          value: context.watch(rememberMeRef),
          onChanged: (value) => context.logic.rememberMe = value,
        ),
      ],
    );
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.logic.signIn(),
      child: const Text('Sign In'),
    );
  }
}

extension on BuildContext {
  AuthenticationViewLogic get logic => use(authenticationViewLogicRef);
}
