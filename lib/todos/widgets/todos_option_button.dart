import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertex_ai_app/l10n/l10n.dart';
import 'package:vertex_ai_app/todos/todos.dart';

@visibleForTesting
enum TodosOption { toggleAll, clearCompleted }

class TodosOptionsButton extends StatelessWidget {
  const TodosOptionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final todos = context.select((TodosBloc bloc) => bloc.state.todos);
    final hasTodos = todos.isNotEmpty;
    final completedTodosAmount = todos.where((todo) => todo.isCompleted).length;

    return PopupMenuButton<TodosOption>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      tooltip: l10n.todosOptionsTooltip,
      onSelected: (options) {
        switch (options) {
          case TodosOption.toggleAll:
            context.read<TodosBloc>().add(const TodosToggleAllRequested());
          case TodosOption.clearCompleted:
            context.read<TodosBloc>().add(const TodosClearCompletedRequested());
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: TodosOption.toggleAll,
            enabled: hasTodos,
            child: Text(
              completedTodosAmount == todos.length
                  ? l10n.todosOptionsMarkAllIncomplete
                  : l10n.todosOptionsMarkAllComplete,
            ),
          ),
          PopupMenuItem(
            value: TodosOption.clearCompleted,
            enabled: hasTodos && completedTodosAmount > 0,
            child: Text(l10n.todosOptionsClearCompleted),
          ),
        ];
      },
      icon: const Icon(Icons.more_vert_rounded),
    );
  }
}
