import 'package:flutter/material.dart';
import 'package:binder/binder.dart';
import 'package:optimistic_ui/data/entities/text_message.dart';
import 'package:optimistic_ui/modules/chat/logic.dart';

final currentTextMessageRef = StateRef<TextMessage>(null);

class ChatView extends StatelessWidget {
  const ChatView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: const [
          Expanded(child: TextMessageList()),
          AddTextMessageInput(),
        ],
      ),
    );
  }
}

class AddTextMessageInput extends StatefulWidget {
  const AddTextMessageInput({
    Key key,
  }) : super(key: key);

  @override
  _AddTextMessageInputState createState() => _AddTextMessageInputState();
}

class _AddTextMessageInputState extends State<AddTextMessageInput> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Message',
        ),
        onSubmitted: (message) {
          context.use(chatViewLogicRef).send(message);
          controller.clear();
        },
      ),
    );
  }
}

class TextMessageList extends StatelessWidget {
  const TextMessageList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textMessages = context.watch(textMessagesRef);

    return ListView.builder(
      reverse: true,
      itemCount: textMessages.length,
      itemBuilder: (context, index) {
        final textMessage = textMessages[index];
        if (textMessage == null) {
          return null;
        } else {
          return BinderScope(
            overrides: [currentTextMessageRef.overrideWith(textMessage)],
            child: const TextMessageView(),
          );
        }
      },
    );
  }
}

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Card(
              child: InkWell(
                onLongPress: () {},
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Consumer<String>(
                    watchable:
                        currentTextMessageRef.select((state) => state.contents),
                    builder:
                        (BuildContext context, String value, Widget child) {
                      return Text(value);
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const TextMessageStatusView(),
        ],
      ),
    );
  }
}

class TextMessageStatusView extends StatelessWidget {
  const TextMessageStatusView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status =
        context.watch(currentTextMessageRef.select((state) => state.status));

    final icon = Icon(
      status.toIcon(),
      color: status.toColor(),
    );

    if (status == Status.undelivered) {
      return GestureDetector(
        onTap: () {
          context
              .use(chatViewLogicRef)
              .retry(context.read(currentTextMessageRef));
        },
        child: icon,
      );
    } else {
      return icon;
    }
  }
}

extension on Status {
  IconData toIcon() {
    switch (this) {
      case Status.delivered:
        return Icons.check_circle;
      case Status.undelivered:
        return Icons.error;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color toColor() {
    switch (this) {
      case Status.undelivered:
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}
