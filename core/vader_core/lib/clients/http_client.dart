import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hashlib/hashlib.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retry/retry.dart';
import 'package:vader_core/clients/cache_client.dart';
import 'package:vader_core/clients/logger.dart';
import 'package:vader_core/foundation/exceptions.dart';

class HttpClientMock extends Mock implements HttpClient {}

enum HttpMethod { get, post, put, delete, head, options, patch }

enum HttpResponseType { success, failed }

class HttpResponse {
  const HttpResponse({required this.data, this.type = HttpResponseType.success});

  bool get hasFailed => type == HttpResponseType.failed;

  final dynamic data;
  final HttpResponseType type;
}

class HttpClient {
  late final Dio _dio;

  final String apiUrl;
  final bool enableLogs;
  final bool preventLargeResponses;
  final Duration? connectTimeout;
  final int maxAttempts;
  final bool kIsWeb;

  HttpClient({
    required this.apiUrl,
    required this.enableLogs,
    required this.preventLargeResponses,
    this.connectTimeout = const Duration(seconds: 5),
    this.maxAttempts = 3,
    this.kIsWeb = false,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: connectTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    if (enableLogs) {
      _dio.interceptors.add(Logger.dioInterceptor(preventLargeResponses: preventLargeResponses));
    }
    /*
    dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
    ));
    */
  }

  bool setHeader(String key, String? value) {
    try {
      if (value == null) {
        if (_dio.options.headers.containsKey('authorization')) {
          _dio.options.headers.remove('authorization');
        }
      }
      _dio.options.headers[key] = value;
      return true;
    } catch (e) {
      logger.exception(e);
      return false;
    }
  }

  bool setHeaders(Map<String, String> map) {
    try {
      _dio.options.headers = {...map};
      return true;
    } catch (e) {
      logger.exception(e);
      return false;
    }
  }

  Future<HttpResponse> request({
    required String path,
    required HttpMethod method,
    Object? data,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    int? maxAttempts,
  }) {
    final options = Options(headers: headers, method: method.name.toUpperCase());
    return _createRequest(
      () => _dio.request(path, data: data, queryParameters: params, options: options),
      onSuccess: (data) async => HttpResponse(data: data),
      onServerError: (status, data) async => HttpResponse(data: data, type: HttpResponseType.failed),
      maxAttempts: maxAttempts,
    );
  }

  Future<HttpResponse> fetch({
    required String path,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    int? maxAttempts,
    Cache? enableCache,
  }) async {
    Future makeRequest() {
      logger.debug('Make request: $path');
      return _createRequest(
        () => _dio.get(path, queryParameters: params, options: Options(headers: headers)),
        onSuccess: (data) => Future.value(data),
        maxAttempts: maxAttempts,
      );
    }

    final result;
    if (enableCache == null) {
      result = await makeRequest();
    } else {
      final key = sha1.string(path + jsonEncode(params)).base64();
      final cache = await Cache.init(duration: enableCache.duration);
      result = await cache.get(key: key, process: makeRequest);
    }

    return HttpResponse(data: result);
  }

  Future<bool> hasInternetConnection({String testAddress = 'https://www.google.com/'}) async {
    try {
      final result = await request(path: testAddress, method: HttpMethod.get, maxAttempts: 1);
      return result.type == HttpResponseType.success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isConnectedToInternet([testAddress = 'google.com']) async {
    try {
      final result = await InternetAddress.lookup(testAddress);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<T> _createRequest<T>(
    Future<Response> Function() request, {
    required Future<T> Function(dynamic data) onSuccess,
    Future<T> Function(int? status, dynamic data)? onServerError,
    int? maxAttempts,
  }) async {
    try {
      final response = await RetryOptions(maxAttempts: maxAttempts ?? this.maxAttempts).retry(
        () => request.call(),
        retryIf: (e) async => await _isConnectedToInternet() && (e is SocketException || e is TimeoutException),
      );

      //final response = await request.call();
      if (response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
        try {
          return await onSuccess(response.data);
        } on Error catch (error) {
          logger.exception(error, stackTrace: error.stackTrace);
          throw ParseDataException();
        }
      }
      throw ServerException();
    } on DioException catch (e) {
      bool result = await _isConnectedToInternet();
      if (!result) throw InternetConnectionException();

      if (e.response?.statusCode == 403) {
        throw AccessDeniedException();
      } else {
        if (onServerError != null && e.response != null) {
          try {
            final error = await onServerError.call(e.response?.statusCode, e.response?.data);
            if (error != null) throw error;
          } on Error catch (error) {
            logger.exception(error, stackTrace: error.stackTrace);
          }
        }
        throw ServerException(message: "DioException response status code: ${e.response?.statusCode}");
      }
    }
  }
}
