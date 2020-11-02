import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  const Todo(
    this.task, {
    this.id,
    String note = '',
    this.complete = false,
  }) : note = note ?? '';

  factory Todo.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();
    return Todo(
      data['task'] as String,
      id: snapshot.id,
      note: data['note'] as String,
      complete: data['complete'] as bool,
    );
  }

  final bool complete;
  final String id;
  final String note;
  final String task;

  Todo copyWith({bool complete, String id, String note, String task}) {
    return Todo(
      task ?? this.task,
      complete: complete ?? this.complete,
      id: id ?? this.id,
      note: note ?? this.note,
    );
  }

  Map<String, Object> toDocument() {
    return {
      "complete": complete,
      "task": task,
      "note": note,
    };
  }

  @override
  List<Object> get props => [complete, id, note, task];

  @override
  String toString() {
    return 'TodoEntity { complete: $complete, task: $task, note: $note, id: $id }';
  }
}
