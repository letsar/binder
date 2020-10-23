import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(
    this.firstName,
    this.lastName,
    this.score,
  );

  final String firstName;
  final String lastName;
  final int score;

  @override
  List<Object> get props => [firstName, lastName, score];
}
