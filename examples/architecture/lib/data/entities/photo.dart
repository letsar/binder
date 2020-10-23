import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'photo.freezed.dart';
part 'photo.g.dart';

@freezed
abstract class Photo with _$Photo {
  const factory Photo({
    int albumId,
    int id,
    String title,
    String url,
    String thumbnailUrl,
  }) = _Photo;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}
