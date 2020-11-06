import 'package:binder/binder.dart';
import 'package:optimistic_ui/data/entities/text_message.dart';
import 'package:optimistic_ui/data/sources/api_client.dart';

final chatRepositoryRef = LogicRef((scope) => ChatRepository(scope));

class ChatRepository with Logic {
  const ChatRepository(this.scope);

  @override
  final Scope scope;

  ApiClient get _apiClient => use(apiClientRef);

  Future<bool> send(TextMessage message) => _apiClient.sendTextMessage(message);
}
