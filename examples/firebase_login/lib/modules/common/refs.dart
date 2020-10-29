import 'package:binder/binder.dart';

final RegExp _emailRegExp = RegExp(
  r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
);
final emailRef = StateRef('');
final emailIsValidRef = Computed((watch) {
  final email = watch(emailRef);
  return email == '' || _emailRegExp.hasMatch(email);
});

final _passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
final passwordRef = StateRef('');

final passwordIsValidRef = Computed((watch) {
  final password = watch(passwordRef);
  return password == '' || _passwordRegExp.hasMatch(password);
});
