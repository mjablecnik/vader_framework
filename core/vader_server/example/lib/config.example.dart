class SurrealDbConfig {
  final String address;
  final String user;
  final String password;
  final String namespace;
  final String database;

  const SurrealDbConfig({
    this.address = 'ws://localhost:8000/rpc',
    this.user = '<SURREALDB_USER>',
    this.password = '<SURREALDB_PASSWORD>',
    this.namespace = '<SURREALDB_NAMESPACE>',
    this.database = '<SURREALDB_DATABASE>',
  });
}

class AiConfig {
  static const String togetherAiSdkKey = '<TOGETHER_AI_SDK_KEY>';
}

class TaskConfig {
  static const String todoistApiToken = '<TODOIST_API_TOKEN>';
}
