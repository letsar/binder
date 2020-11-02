import 'package:binder/binder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firebaseAuthRef = StateRef(FirebaseAuth.instance);
final todoCollectionRef =
    StateRef(FirebaseFirestore.instance.collection('todos'));
