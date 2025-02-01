import 'package:save_earth/extension/map_extension.dart';

class DataStore {
  DataStore._internal();

  static final DataStore _instance = DataStore._internal();

  factory DataStore() => _instance;

  final Map<String, dynamic> _args = {};
  final Map<String, dynamic> _env = {};

  void setArgs(Map<String, dynamic> args) {
    _args.addAll(args);
  }

  addArgs<T>(String key, T value) {
    _args[key] = value;
  }

  T getArgs<T>(String key) {
    T? value = _args.filterByKey(key) as T?;
    if (value == null) {
      throw Exception("Not found value with key : $key");
    }
    return value;
  }

  void setEnv(Map<String, dynamic> env) {
    _env.addAll(env);
  }

  T getEnv<T>(String key) {
    T? value = _env.filterByKey(key) as T?;
    if (value == null) {
      throw Exception("Not found value with key : $key");
    }
    return value;
  }
}
