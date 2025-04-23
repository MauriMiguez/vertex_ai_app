import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// {@template todo_item}
/// A single `todo` item.
///
/// Contains a [title], [description] and [id], in addition to a [isCompleted]
/// flag.
///
/// If an [id] is provided, it cannot be empty. If no [id] is provided, one
/// will be generated.
///
/// [Todo]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [Todo.fromJson]
/// respectively.
/// {@endtemplate}
@immutable
class Todo extends Equatable {
  /// {@macro todo_item}
  Todo({
    required this.title,
    required this.dueDate,
    String? id,
    this.description = '',
    this.isCompleted = false,
  }) : assert(
         id == null || id.isNotEmpty,
         'id must either be null or not empty',
       ),
       id = id ?? const Uuid().v4();

  /// Deserializes the given [JsonMap] into a [Todo].
  factory Todo.fromJson(JsonMap json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
      dueDate: DateTime.parse(json['dueDate'] as String),
    );
  }

  /// The unique identifier of the `todo`.
  ///
  /// Cannot be empty.
  final String id;

  /// The title of the `todo`.
  ///
  /// Note that the title may be empty.
  final String title;

  /// The description of the `todo`.
  ///
  /// Defaults to an empty string.
  final String description;

  /// Whether the `todo` is completed.
  ///
  /// Defaults to `false`.
  final bool isCompleted;

  /// The due date of the `todo`.
  final DateTime dueDate;

  /// Returns a copy of this `todo` with the given values updated.
  ///
  /// {@macro todo_item}
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  /// Converts this [Todo] into a [JsonMap].
  JsonMap toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [id, title, description, isCompleted, dueDate];
}

/// The type definition for a JSON-serializable [Map].
typedef JsonMap = Map<String, dynamic>;
