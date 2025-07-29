import 'package:dio/dio.dart';
import 'package:vader_core/clients/logger.dart';
import 'dart:convert';
import 'package:vader_server/vader_serinus_server.dart';
import 'package:vader_server_example/config.dart';


class AiClient extends Provider {
  DateTime lastRequest = DateTime.now().subtract(Duration(minutes: 1));
  final Dio dio = _getTogetherAiDio();

  static _getTogetherAiDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.together.xyz',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AiConfig.togetherAiSdkKey}',
        },
      ),
    );
    //dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return dio;
  }

  Future<Response> _makeQuery(Future<Response> Function() query) async {
    if (lastRequest.isAfter(DateTime.now().subtract(Duration(seconds: 11)))) {
      await Future.delayed(Duration(seconds: 11) - DateTime.now().difference(lastRequest));
    }

    final Response response = await query.call();

    lastRequest = DateTime.now();
    return response;
  }

  Future<Map<String, dynamic>> query({
    required String rules,
    required String question,
    required String queryName,
  }) async {
    final payload = {
      'model': 'meta-llama/Llama-3.3-70B-Instruct-Turbo-Free',
      'stop': ['</s>', '[/INST]'],
      'max_tokens': 3000,
      'temperature': 0.7,
      'top_p': 0.7,
      'top_k': 50,
      'repetition_penalty': 1,
      'messages': [
        {'role': 'system', 'content': rules},
        {'role': 'user', 'content': question},
      ],
    };

    final Response response = await _makeQuery(() => dio.post('/v1/chat/completions', data: payload));

    final data = response.data;
    logger.info('$queryName: ${data['usage']}');
    //logger.info(queryName + ': ' + data['choices'][0]['message']['content']);
    //print(queryName + ': ' + data['choices'][0]['message']['content']);

    final String content = data['choices'][0]['message']['content'].replaceAll('\\\n', '\\n');

    return jsonDecode(content.replaceAll('```', ''));
  }
}
