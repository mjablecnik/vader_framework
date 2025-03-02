import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:vader_core/clients/cache_client.dart';
import 'package:vader_core/framework.dart';

void main() {
  final injector = Injector();
  injector.addInstance(HttpClient(apiUrl: "https://dummyjson.com", enableLogs: true, preventLargeResponses: false));
  injector.addInstance(StorageClient(path: Directory.systemTemp.path));
  injector.commit();

  final httpClient = injector.use<HttpClient>();

  test('HttpClient request', () async {
    print('\nHttpClient request:');
    final response = await httpClient.request(path: '/test', method: HttpMethod.get);
    final result = jsonEncode(response.data).toString();
    expect(result, '{"status":"ok","method":"GET"}');
  });

  test('HttpClient fetch without cache', () async {
    print('\nHttpClient fetch without cache:');
    final response = await httpClient.fetch(path: '/test');
    final result = jsonEncode(response.data).toString();
    expect(result, '{"status":"ok","method":"GET"}');
  });

  test('HttpClient fetch with cache', () async {
    print('\nHttpClient fetch with cache:');
    var response = await httpClient.fetch(path: '/test', enableCache: Cache(duration: Duration(seconds: 10)));
    var result = jsonEncode(response.data).toString();
    expect(result, '{"status":"ok","method":"GET"}');

    print('\nLoad data from cache:');
    response = await httpClient.fetch(path: '/test', enableCache: Cache(duration: Duration(seconds: 10)));
    result = jsonEncode(response.data).toString();
    expect(result, '{"status":"ok","method":"GET"}');
    print('Success');

    print('\nClean cache and fetch:');
    await httpClient.cleanCache();
    response = await httpClient.fetch(path: '/test', enableCache: Cache(duration: Duration(seconds: 10)));
    result = jsonEncode(response.data).toString();
    expect(result, '{"status":"ok","method":"GET"}');

    await Future.delayed(Duration(seconds: 2));
    print('\nFetch after delay:');
    response = await httpClient.fetch(path: '/test', enableCache: Cache(duration: Duration(seconds: 1)));
    result = jsonEncode(response.data).toString();
    expect(result, '{"status":"ok","method":"GET"}');

    await httpClient.cleanCache();
  });
}
