import 'package:firebase_core/firebase_core.dart';
import 'package:firestore_todos/modules/add_edit/view.dart';
import 'package:firestore_todos/modules/authentication/view.dart';
import 'package:firestore_todos/modules/home/view.dart';
import 'package:flutter/material.dart';
import 'package:binder/binder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BinderScope(child: TodosApp()));
}

class TodosApp extends StatelessWidget {
  const TodosApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Todos',
      routes: {
        '/': (context) {
          return const AuthenticationView();
        },
        '/home': (context) {
          return const HomeView();
        },
        '/addTodo': (context) {
          return const AddEditView(isEditing: false);
        },
      },
    );
  }
}
