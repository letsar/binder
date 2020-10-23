import 'dart:convert';

import 'package:architecture/data/entities/user.dart';
import 'package:binder/binder.dart';
import 'package:http/http.dart' as http;

final apiClientRef = LogicRef((scope) => ApiClient());

class ApiClient {
  ApiClient({http.Client httpClient, GenericJsonCodec codec})
      : _httpClient = httpClient ?? http.Client(),
        _codec = codec ?? const GenericJsonCodec();

  final http.Client _httpClient;
  final GenericJsonCodec _codec;

  Future<List<User>> getUsers() async {
    final response = await _get('/users');
    return _codec.decodeList<User>(response.body);
  }

  Future<http.Response> _get(String unencodedPath) {
    return _httpClient
        .get(Uri.https('jsonplaceholder.typicode.com', unencodedPath));
  }
}

abstract class JsonCodec<T> {
  const JsonCodec();

  Map<String, dynamic> encode(T value);
  T decode(Map<String, dynamic> value);
}

class UserCodec extends JsonCodec<User> {
  const UserCodec();

  @override
  User decode(Map<String, dynamic> value) => User.fromJson(value);

  @override
  Map<String, dynamic> encode(User value) => value.toJson();
}

class GenericJsonCodec {
  const GenericJsonCodec();

  Map<Type, JsonCodec> get codecs {
    return {
      User: const UserCodec(),
    };
  }

  String encode<T>(T value) {
    final codec = codecs[typeOf<T>()] as JsonCodec<T>;
    return jsonEncode(codec.encode(value));
  }

  String encodeList<T>(List<T> value) {
    final codec = codecs[typeOf<T>()] as JsonCodec<T>;
    return jsonEncode(value.map((x) => codec.encode(x)).toList());
  }

  T decode<T>(String value) {
    final codec = codecs[typeOf<T>()] as JsonCodec<T>;
    return codec.decode(jsonDecode(value) as Map<String, dynamic>);
  }

  List<T> decodeList<T>(String value) {
    final codec = codecs[typeOf<T>()] as JsonCodec<T>;
    return jsonDecode(value)
        .map((dynamic x) => codec.decode(x as Map<String, dynamic>))
        .toList()
        .cast<T>() as List<T>;
  }
}

Type typeOf<T>() => T;
