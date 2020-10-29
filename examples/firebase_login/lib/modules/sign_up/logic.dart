import 'package:binder/binder.dart';
import 'package:firebase_login/data/repositories/authentication.dart';
import 'package:firebase_login/modules/common/busy_logic.dart';
import 'package:firebase_login/modules/common/refs.dart';
import 'package:flutter/scheduler.dart';

final signUpViewLogicRef = LogicRef((scope) => SignUpViewLogic(scope));

final confirmedPasswordRef = StateRef('');
final confirmedPasswordIsValidRef = Computed((watch) {
  return watch(passwordRef) == watch(confirmedPasswordRef);
});

final canBeSubmittedRef = Computed((watch) {
  return watch(emailRef) != '' &&
      watch(emailIsValidRef) &&
      watch(passwordRef) != '' &&
      watch(passwordIsValidRef) &&
      watch(confirmedPasswordIsValidRef);
});

class SignUpViewLogic with Logic, BusyLogic {
  const SignUpViewLogic(this.scope);

  @override
  final Scope scope;

  AuthenticationRepository get _authenticationRepository =>
      use(authenticationRepositoryRef);

  String get email => read(emailRef);
  set email(String value) => write(emailRef, value);

  String get password => read(passwordRef);
  set password(String value) => write(passwordRef, value);

  String get confirmedPassword => read(confirmedPasswordRef);
  set confirmedPassword(String value) => write(confirmedPasswordRef, value);

  Future<void> signUp() async {
    busy = true;
    try {
      _authenticationRepository.signUp(
        email: email,
        password: password,
      );
      write(signUpResultRef, SignUpSuccess());
    } on Exception {
      write(signUpResultRef, SignUpFailure());
    } finally {
      busy = false;
    }
  }
}

final signUpResultRef = StateRef<SignUpResult>(null);

class SignUpResult {}

class SignUpSuccess extends SignUpResult {}

class SignUpFailure extends SignUpResult {}
