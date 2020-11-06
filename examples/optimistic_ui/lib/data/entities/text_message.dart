import 'package:meta/meta.dart';

enum Status {
  // The message has been sent to the server.
  sent,

  // The server has received the message and delivered it to the recipient.
  delivered,

  // There have been an error on the server.
  undelivered,
}

@immutable
class TextMessage {
  const TextMessage({
    @required this.id,
    @required this.userId,
    @required this.contents,
    @required this.timeStamp,
    @required this.status,
  });

  final String id;
  final String userId;
  final String contents;
  final int timeStamp;
  final Status status;

  TextMessage copyWithNewStatus(Status status) {
    return TextMessage(
      id: id,
      userId: userId,
      contents: contents,
      timeStamp: timeStamp,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TextMessage &&
        other.id == id &&
        other.userId == userId &&
        other.contents == contents &&
        other.timeStamp == timeStamp &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        contents.hashCode ^
        timeStamp.hashCode ^
        status.hashCode;
  }

  @override
  String toString() {
    return 'TextMessage(userId: $userId, contents: $contents, timeStamp: $timeStamp, status: $status)';
  }
}
