import 'package:surrealdb/surrealdb.dart';
import 'package:vader_server_example/config.dart';

export 'package:surrealdb/surrealdb.dart';

class SurrealDbClient {
  static Future<SurrealDB> init({SurrealDbConfig config = const SurrealDbConfig()}) async {
    final db = SurrealDB(config.address);
    db.connect();
    await db.wait();

    final token = await db.signin(user: config.user, pass: config.password);
    await db.authenticate(token);

    await db.use(config.namespace, config.database);
    return db;
  }

  static Future<SurrealDB> initDancee() async {
    return init(config: SurrealDbConfig());
  }
}