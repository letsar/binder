import 'package:binder/binder.dart';
import 'package:optimistic_ui/data/entities/text_message.dart';
import 'package:optimistic_ui/data/repositories/chat.dart';
import 'package:uuid/uuid.dart';

final Uuid _uuid = Uuid();

final textMessagesRef = StateRef(const <TextMessage>[]);

final chatViewLogicRef = LogicRef((scope) => ChatViewLogic(scope));

class ChatViewLogic with Logic {
  const ChatViewLogic(this.scope);

  @override
  final Scope scope;

  ChatRepository get _chatRepository => use(chatRepositoryRef);

  Future<void> send(String message) async {
    final textMessage = TextMessage(
      id: _uuid.v4(),
      userId: 'me',
      contents: message,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      status: Status.sent,
    );
    _add(textMessage);

    final success = await _chatRepository.send(textMessage);
    final status = success ? Status.delivered : Status.undelivered;
    _update(textMessage.copyWithNewStatus(status));
  }

  Future<void> retry(TextMessage textMessage) async {
    _update(textMessage.copyWithNewStatus(Status.sent));
    final success = await _chatRepository.send(textMessage);
    final status = success ? Status.delivered : Status.undelivered;
    _update(textMessage.copyWithNewStatus(status));
  }

  void _add(TextMessage textMessage) {
    write(textMessagesRef, [textMessage, ...read(textMessagesRef)]);
  }

  void _update(TextMessage textMessage) {
    final id = textMessage.id;
    write(
      textMessagesRef,
      read(textMessagesRef).map((m) => m.id == id ? textMessage : m).toList(),
    );
  }
}
