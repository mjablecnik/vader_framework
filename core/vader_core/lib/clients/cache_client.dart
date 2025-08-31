import 'dart:io';

import 'package:vader_core/clients/logger.dart';
import 'package:vader_core/clients/storage_client.dart';

class Cache {
  Cache(StorageClient storageClient, {required this.duration}) : _storageClient = storageClient;

  static Future<Cache> init({
    String name = 'defaultCache',
    Duration duration = const Duration(hours: 1),
  }) async {
    return Cache(
      await StorageClient.init(name: name, path: Directory.systemTemp.path),
      duration: duration,
    );
  }

  late final StorageClient _storageClient;
  final Duration duration;

  Future<T> get<T>({required String key, Duration? duration, required Future<T> Function() process}) async {
    final Map? data = await _storageClient.getMap(key);
    final untilTime = DateTime.now().millisecondsSinceEpoch - (duration ?? this.duration).inMilliseconds;
    if (data != null && data['time'] > untilTime) {
      logger.debug('Obtain data from cache: $key');
      return data['data'];
    }

    final T response = await process.call();

    await _storageClient.saveMap(key, {'time': DateTime.now().millisecondsSinceEpoch, 'data': response});

    return response;
  }
}
