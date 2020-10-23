import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'album.freezed.dart';
part 'album.g.dart';

@freezed
abstract class Album with _$Album {
  const factory Album({
    int id,
    int userId,
    String title,
  }) = _Album;

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
