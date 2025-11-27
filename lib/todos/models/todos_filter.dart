import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

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

  String toChatMessage() {
    final todoStatusString = switch (todoStatus) {
      TodoStatus.all => 'all',
      TodoStatus.activeOnly => 'active',
      TodoStatus.completedOnly => 'completed',
    };

    var filterString = 'by $todoStatusString';

    final dateFormat = DateFormat.yMMMd();

    final fromDateFormatted = from != null ? dateFormat.format(from!) : null;
    if (fromDateFormatted != null) {
      filterString = '$filterString and from $fromDateFormatted';
    }

    final toDateFormatted = to != null ? dateFormat.format(to!) : null;
    if (toDateFormatted != null) {
      filterString = '$filterString to $toDateFormatted';
    }

    return filterString;
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
