import 'package:meta/meta.dart';

@immutable
class Task {
  const Task({
    @required this.id,
    @required this.timestamp,
  });

  final String id;
  final int timestamp;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Task && other.id == id && other.timestamp == timestamp;
  }

  @override
  int get hashCode => id.hashCode ^ timestamp.hashCode;

  @override
  String toString() => 'Task(id: $id, timestamp: $timestamp)';
}
