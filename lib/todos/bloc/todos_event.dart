part of 'todos_bloc.dart';

sealed class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object> get props => [];
}

final class TodosChanged extends TodosEvent {
  const TodosChanged(this.todos);

  final List<Todo> todos;

  @override
  List<Object> get props => [todos];
}

final class TodosTodoCompletionToggled extends TodosEvent {
  const TodosTodoCompletionToggled({
    required this.todo,
    required this.isCompleted,
  });

  final Todo todo;
  final bool isCompleted;

  @override
  List<Object> get props => [todo, isCompleted];
}

final class TodosTodoDeleted extends TodosEvent {
  const TodosTodoDeleted(this.todo);

  final Todo todo;

  @override
  List<Object> get props => [todo];
}

final class TodosUndoDeletionRequested extends TodosEvent {
  const TodosUndoDeletionRequested();
}

class TodosFilterChanged extends TodosEvent {
  const TodosFilterChanged(this.filters, {this.wasAIChange = false});

  final bool wasAIChange;
  final TodosFilters filters;

  @override
  List<Object> get props => [filters, wasAIChange];
}

class TodosToggleAllRequested extends TodosEvent {
  const TodosToggleAllRequested();
}

class TodosClearCompletedRequested extends TodosEvent {
  const TodosClearCompletedRequested();
}
