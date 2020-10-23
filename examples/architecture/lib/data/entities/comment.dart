import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    int id,
    int postId,
    String name,
    String email,
    String body,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}
