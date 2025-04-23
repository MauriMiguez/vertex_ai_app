import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:vertex_ai_app/todos/todos.dart';

part 'todos_event.dart';
part 'todos_state.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  TodosBloc({required TodosRepository todosRepository})
    : _todosRepository = todosRepository,
      super(const TodosState()) {
    on<TodosTodoCompletionToggled>(_onTodoCompletionToggled);
    on<TodosTodoDeleted>(_onTodoDeleted);
    on<TodosUndoDeletionRequested>(_onUndoDeletionRequested);
    on<TodosFilterChanged>(_onFilterChanged);
    on<TodosToggleAllRequested>(_onToggleAllRequested);
    on<TodosClearCompletedRequested>(_onClearCompletedRequested);
    on<TodosChanged>(_onTodosChanged);

    _todosSubscription = _todosRepository.getTodos().listen(_todosChanged);
  }

  final TodosRepository _todosRepository;
  late StreamSubscription<List<Todo>> _todosSubscription;

  Future<void> _todosChanged(List<Todo> todos) async {
    add(TodosChanged(todos));
  }

  Future<void> _onTodosChanged(
    TodosChanged event,
    Emitter<TodosState> emit,
  ) async {
    emit(
      state.copyWith(
        todos: () => event.todos,
        status: () => TodosStatus.success,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _todosSubscription.cancel();
    return super.close();
  }

  Future<void> _onTodoCompletionToggled(
    TodosTodoCompletionToggled event,
    Emitter<TodosState> emit,
  ) async {
    final newTodo = event.todo.copyWith(isCompleted: event.isCompleted);
    await _todosRepository.saveTodo(newTodo);
  }

  Future<void> _onTodoDeleted(
    TodosTodoDeleted event,
    Emitter<TodosState> emit,
  ) async {
    emit(state.copyWith(lastDeletedTodo: () => event.todo));
    await _todosRepository.deleteTodo(event.todo.id);
  }

  Future<void> _onUndoDeletionRequested(
    TodosUndoDeletionRequested event,
    Emitter<TodosState> emit,
  ) async {
    assert(state.lastDeletedTodo != null, 'Last deleted todo can not be null.');

    final todo = state.lastDeletedTodo!;
    emit(state.copyWith(lastDeletedTodo: () => null));
    await _todosRepository.saveTodo(todo);
  }

  Future<void> _onFilterChanged(
    TodosFilterChanged event,
    Emitter<TodosState> emit,
  ) async {
    await _todosSubscription.cancel();
    if (event.wasAIChange) {
      emit(
        state.copyWith(
          status: () => TodosStatus.loading,
          todos: () => [],
          filters: () => event.filters,
        ),
      );
    } else {
      emit(
        UserFilterChanged(status: TodosStatus.loading, filters: event.filters),
      );
    }

    _todosSubscription = _todosRepository
        .getTodos(
          to: event.filters.to,
          from: event.filters.from,
          isCompleted: event.filters.todoStatus.completedFilter(),
        )
        .listen(_todosChanged);
  }

  Future<void> _onToggleAllRequested(
    TodosToggleAllRequested event,
    Emitter<TodosState> emit,
  ) async {
    final areAllCompleted = state.todos.every((todo) => todo.isCompleted);
    await _todosRepository.completeAll(isCompleted: !areAllCompleted);
  }

  Future<void> _onClearCompletedRequested(
    TodosClearCompletedRequested event,
    Emitter<TodosState> emit,
  ) async {
    await _todosRepository.clearCompleted();
  }
}
