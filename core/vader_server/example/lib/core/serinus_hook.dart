import 'package:vader_server/vader_server.dart';

class SerinusHook extends Hook with OnRequestResponse {
  @override
  Future<void> onRequest(Request request, InternalResponse response) async {
    //print('[${DateTime.now()}] ${request.method} ${request.uri}');
  }

  @override
  Future<void> onResponse(Request request, dynamic data, ResponseProperties properties) async {
    print('[${DateTime.now()}] ${data.status.code} ${request.method} ${request.uri}');
  }
}
