import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

class StorageClientMock extends Mock implements StorageClient {}

class StorageClient {
  final Box _storage;

  const StorageClient(Box storage) : _storage = storage;

  static Future<StorageClient> init({String name = 'defaultBox', required String path}) async {
    Hive.init(path);
    final storage = await Hive.openBox(name, path: path);
    return StorageClient(storage);
  }

  Future<int> removeAll() async {
    return _storage.clear();
  }

  Future<void> remove(String key) {
    return _storage.delete(key);
  }

  Future<void> saveString(String key, String value) {
    return _storage.put(key, value);
  }

  Future<String?> getString(String key) {
    try {
      return Future.value(_storage.get(key));
    } catch (e) {
      return Future.value(null);
    }
  }

  Future<void> saveList(String key, List value) {
    return saveMap(key, {"data": value});
  }

  Future<dynamic> getList(String key) async {
    try {
      return (await getMap(key))["data"];
    } catch (e) {
      return Future.value(null);
    }
  }

  Future<void> saveMap(String key, Map value) {
    return _storage.put(key, json.encode(value));
  }

  Future<dynamic> getMap(String key) async {
    try {
      return json.decode((await _storage.get(key)).toString());
    } catch (e) {
      return Future.value(null);
    }
  }
}
