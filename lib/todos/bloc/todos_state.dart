part of 'todos_bloc.dart';

enum TodosStatus { initial, loading, success, failure }

final class TodosState extends Equatable {
  const TodosState({
    this.status = TodosStatus.initial,
    this.todos = const [],
    this.lastDeletedTodo,
    this.filters = const TodosFilters(),
  });

  final TodosStatus status;
  final List<Todo> todos;
  final Todo? lastDeletedTodo;
  final TodosFilters filters;

  TodosState copyWith({
    TodosStatus Function()? status,
    List<Todo> Function()? todos,
    TodosFilters Function()? filters,
    Todo? Function()? lastDeletedTodo,
  }) {
    return TodosState(
      status: status != null ? status() : this.status,
      todos: todos != null ? todos() : this.todos,
      filters: filters != null ? filters() : this.filters,
      lastDeletedTodo:
          lastDeletedTodo != null ? lastDeletedTodo() : this.lastDeletedTodo,
    );
  }

  @override
  List<Object> get props => [status, todos, filters];
}

final class UserFilterChanged extends TodosState {
  const UserFilterChanged({
    super.status,
    super.todos,
    super.lastDeletedTodo,
    super.filters,
  }) : super();
}
