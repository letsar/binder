import 'package:binder/binder.dart';
import 'package:firebase_login/modules/common/busy_logic.dart';
import 'package:firebase_login/modules/common/refs.dart';
import 'package:firebase_login/modules/sign_up/form.dart';
import 'package:firebase_login/modules/sign_up/logic.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({
    Key key,
  }) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SignUpView());
  }

  @override
  Widget build(BuildContext context) {
    return BinderScope(
      overrides: [
        signUpViewLogicRef.overrideWithSelf(),
        busyRef.overrideWith(false),
        emailRef.overrideWith(''),
        passwordRef.overrideWith(''),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: const Padding(
          padding: EdgeInsets.all(8),
          child: SignUpForm(),
        ),
      ),
    );
  }
}
