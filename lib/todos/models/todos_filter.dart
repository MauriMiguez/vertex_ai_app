import 'package:equatable/equatable.dart';

enum TodoStatus { all, activeOnly, completedOnly }

extension TodoStatusExtension on TodoStatus {
  bool? completedFilter() {
    switch (this) {
      case TodoStatus.all:
        return null;
      case TodoStatus.activeOnly:
        return false;
      case TodoStatus.completedOnly:
        return true;
    }
  }
}

class TodosFilters extends Equatable {
  const TodosFilters({this.to, this.from, this.todoStatus = TodoStatus.all});

  final DateTime? to;
  final DateTime? from;
  final TodoStatus todoStatus;

  Map<String, Object?> toLLMContextMap() {
    return {
      'to': to?.toIso8601String(),
      'from': from?.toIso8601String(),
      'todoStatus': todoStatus.name,
    };
  }

  TodosFilters copyWith({
    DateTime? Function()? to,
    DateTime? Function()? from,
    TodoStatus Function()? todoStatus,
  }) {
    return TodosFilters(
      to: to?.call() ?? this.to,
      from: from?.call() ?? this.from,
      todoStatus: todoStatus?.call() ?? this.todoStatus,
    );
  }

  @override
  List<Object?> get props => [to, from, todoStatus];
}
