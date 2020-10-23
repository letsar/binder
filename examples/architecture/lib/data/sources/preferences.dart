import 'package:binder/binder.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore_for_file: avoid_field_initializers_in_const_classes

final preferencesRef = LogicRef((scope) => const Preferences());

class Preferences {
  const Preferences()
      : rememberMe = const _SharedPref('remember_me'),
        lastSignIn = const _SharedPref('last_sign_in');

  /// Indicates whether we should automatically authenticate the user.
  final Preference<bool> rememberMe;

  /// The last time the user signed in (in milliseconds).
  final Preference<int> lastSignIn;
}

/// Represents a singular preference.
abstract class Preference<T> {
  const Preference();

  Future<T> load();
  Future<void> save(T value);
}

class _SharedPref<T> extends Preference<T> {
  const _SharedPref(this.key);

  final String key;

  @override
  Future<T> load() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final Object value = sharedPreferences.get(key);
    if (value is T) {
      return value;
    }
    return null;
  }

  @override
  Future<void> save(T value) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (value == null) {
      // Removes the value from the preferences.
      return sharedPreferences.remove(key);
    } else if (value is bool) {
      return sharedPreferences.setBool(key, value);
    } else if (value is double) {
      return sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      return sharedPreferences.setInt(key, value);
    } else if (value is String) {
      return sharedPreferences.setString(key, value);
    } else if (value is List<String>) {
      return sharedPreferences.setStringList(key, value);
    } else {
      throw UnsupportedError('The type $T is not supported');
    }
  }
}
