import 'package:uuid/uuid.dart';

class Task {
  /// Unique identifier for the task_manager
  final String id;

  /// Name of the task_manager
  String name;

  /// Description of the task_manager
  String description;

  /// Deadline for the task_manager
  DateTime? deadline;

  /// Whether the task is solved or not
  bool solved;

  /// Priority of the task (1-4, where 4 is highest)
  int priority;

  /// When the task was created
  final DateTime created;

  /// Constructor for creating a new task_manager
  Task({
    String? id,
    required this.name,
    this.description = '',
    this.deadline,
    this.solved = false,
    this.priority = 1,
    DateTime? created,
  }) :
    id = id ?? const Uuid().v4(),
    created = created ?? DateTime.now();

  /// Convert task_manager to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'solved': solved,
      'priority': priority,
      'created': created.toIso8601String(),
    };
  }

  /// Create task_manager from JSON map
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      solved: json['solved'] as bool? ?? false,
      priority: json['priority'] as int? ?? 1,
      created: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : null,
    );
  }

  /// Create a copy of this task_manager with optional new values
  Task copyWith({
    String? name,
    String? description,
    DateTime? deadline,
    bool? solved,
    int? priority,
    DateTime? created,
  }) {
    return Task(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      solved: solved ?? this.solved,
      priority: priority ?? this.priority,
      created: created ?? this.created,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, name: $name, description: $description, deadline: $deadline, solved: $solved, priority: $priority, created: $created}';
  }
}

