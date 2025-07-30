import 'package:surrealdb/surrealdb.dart';

class ErrorService {
  const ErrorService(this.surrealDB);

  final SurrealDB surrealDB;

  Future<List<String>> getAllErrors() async {
    final groups = (await surrealDB.query(r'SELECT * FROM errors') as List).first['result'] as List<dynamic>;
    return groups.map((e) => e['url'] as String).toList();
  }

  Future<bool> existsError(String url) async {
    final groups = (await surrealDB.query(
      r'SELECT * FROM errors WHERE url = $url',
      {'url': url},
    ) as List).first['result'] as List<dynamic>;

    return groups.isNotEmpty;
  }

  Future<bool> createError(String url, String message) async {
    try {
      if (!await existsError(url)) {
        await surrealDB.create('errors', {'url': url, 'message': message});
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
