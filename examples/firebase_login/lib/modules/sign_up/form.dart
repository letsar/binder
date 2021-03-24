import 'package:binder/binder.dart';
import 'package:firebase_login/modules/common/busy_logic.dart';
import 'package:firebase_login/modules/common/refs.dart';
import 'package:firebase_login/modules/sign_up/logic.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateListener<SignUpResult>(
      watchable: signUpResultRef,
      onStateChanged: (BuildContext context, SignUpResult state) {
        if (state is SignUpFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Sign Up Failure')),
            );
        }
      },
      child: Form(
        child: Align(
          alignment: const Alignment(0, -1 / 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              EmailInput(),
              Gap(8),
              PasswordInput(),
              Gap(8),
              ConfirmPasswordInput(),
              Gap(8),
              SignUpButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  const EmailInput({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (email) => context.use(signUpViewLogicRef).email = email,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'email',
        helperText: '',
        errorText: context.watch(emailIsValidRef) ? null : 'email invalid',
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (password) =>
          context.use(signUpViewLogicRef).password = password,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'password',
        helperText: '',
        errorText:
            context.watch(passwordIsValidRef) ? null : 'password invalid',
      ),
    );
  }
}

class ConfirmPasswordInput extends StatelessWidget {
  const ConfirmPasswordInput({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (password) =>
          context.use(signUpViewLogicRef).confirmedPassword = password,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'password',
        helperText: '',
        errorText: context.watch(confirmedPasswordIsValidRef)
            ? null
            : 'passwords do not match',
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  const SignUpButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final busy = context.watch(busyRef);
    return busy
        ? const CircularProgressIndicator()
        : RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            color: Colors.orangeAccent,
            onPressed: context.watch(canBeSubmittedRef)
                ? () => context.use(signUpViewLogicRef).signUp()
                : null,
            child: const Text('SIGN UP'),
          );
  }
}
