import 'dart:math';

import 'package:binder/binder.dart';
import 'package:optimistic_ui/data/entities/task.dart';
import 'package:optimistic_ui/data/entities/text_message.dart';

final apiClientRef = LogicRef((scope) => ApiClient());

class ApiClient {
  final Random random = Random();

  Future<bool> sendTextMessage(TextMessage textMessage) async {
    await _simulateLatency();

    // We simulate an success/failure.
    return random.nextBool();
  }

  Future<bool> addTask(Task task) async {
    await _simulateLatency();

    // We simulate an success/failure.
    return random.nextBool();
  }

  Future<bool> deleteTask(Task task) async {
    await _simulateLatency();

    // We simulate an success/failure.
    return random.nextBool();
  }

  Future<void> _simulateLatency() {
    // We simulate a latency from 500 to 2000 ms.
    return Future<void>.delayed(
      Duration(milliseconds: random.nextInt(1500) + 500),
    );
  }
}
