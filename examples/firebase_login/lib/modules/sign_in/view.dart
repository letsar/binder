import 'package:binder/binder.dart';
import 'package:firebase_login/modules/common/busy_logic.dart';
import 'package:firebase_login/modules/common/refs.dart';
import 'package:firebase_login/modules/sign_in/form.dart';
import 'package:firebase_login/modules/sign_in/logic.dart';
import 'package:flutter/material.dart';

class SignInView extends StatelessWidget {
  const SignInView({
    Key key,
  }) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SignInView());
  }

  @override
  Widget build(BuildContext context) {
    return BinderScope(
      overrides: [
        signInViewLogicRef.overrideWithSelf(),
        busyRef.overrideWith(false),
        emailRef.overrideWith(''),
        passwordRef.overrideWith(''),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign in')),
        body: const Padding(
          padding: EdgeInsets.all(8),
          child: SignInForm(),
        ),
      ),
    );
  }
}
