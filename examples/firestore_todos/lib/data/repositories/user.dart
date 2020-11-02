import 'package:binder/binder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_todos/data/sources/refs.dart';

final userRepositoryRef = LogicRef((scope) => UserRepository(scope));

class UserRepository with Logic {
  const UserRepository(this.scope);

  @override
  final Scope scope;

  FirebaseAuth get _firebaseAuth => read(firebaseAuthRef);

  Stream<bool> get isAuthenticated {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser != null;
    });
  }

  Future<void> authenticate() {
    return _firebaseAuth.signInAnonymously();
  }
}
