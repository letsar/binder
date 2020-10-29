import 'package:binder/binder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthRef = StateRef(FirebaseAuth.instance);
final googleSignInRef = StateRef(GoogleSignIn.standard());
