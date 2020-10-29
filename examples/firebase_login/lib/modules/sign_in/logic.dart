import 'package:binder/binder.dart';
import 'package:firebase_login/data/repositories/authentication.dart';
import 'package:firebase_login/modules/common/busy_logic.dart';
import 'package:firebase_login/modules/common/refs.dart';
import 'package:flutter/scheduler.dart';

final signInViewLogicRef = LogicRef((scope) => SignInViewLogic(scope));

final canBeSubmittedRef = Computed((watch) {
  return watch(emailRef) != '' &&
      watch(emailIsValidRef) &&
      watch(passwordRef) != '' &&
      watch(passwordIsValidRef);
});

class SignInViewLogic with Logic, BusyLogic {
  const SignInViewLogic(this.scope);

  @override
  final Scope scope;

  AuthenticationRepository get _authenticationRepository =>
      use(authenticationRepositoryRef);

  String get email => read(emailRef);
  set email(String value) => write(emailRef, value);

  String get password => read(passwordRef);
  set password(String value) => write(passwordRef, value);

  Future<void> signInWithCredentials() async {
    busy = true;
    try {
      await _authenticationRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      write(signInResultRef, SignInSuccess());
    } on Exception {
      write(signInResultRef, SignInFailure());
    } finally {
      busy = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _authenticationRepository.signInWithGoogle();
      write(signInResultRef, SignInSuccess());
    } on Exception {
      write(signInResultRef, SignInFailure());
    }
  }
}

final signInResultRef = StateRef<SignInResult>(null);

class SignInResult {}

class SignInSuccess extends SignInResult {}

class SignInFailure extends SignInResult {}
