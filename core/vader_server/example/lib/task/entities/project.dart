import 'package:uuid/uuid.dart';

class Project {
  /// Unique identifier for the project
  final String id;

  /// Name of the project
  String name;

  /// When the project was created
  final DateTime created;

  /// Constructor for creating a new project
  Project({
    String? id,
    required this.name,
    DateTime? created,
  }) :
    id = id ?? const Uuid().v4(),
    created = created ?? DateTime.now();

  /// Convert project to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created': created.toIso8601String(),
    };
  }

  /// Create project from JSON map
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String?,
      name: json['name'] as String,
      created: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : null,
    );
  }

  /// Create a copy of this project with optional new values
  Project copyWith({
    String? name,
    String? color,
    DateTime? created,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      created: created ?? this.created,
    );
  }

  @override
  String toString() {
    return 'Project{id: $id, name: $name, created: $created}';
  }
}