import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:vertex_ai_app/edit_todo/edit_todo.dart';
import 'package:vertex_ai_app/l10n/l10n.dart';
import 'package:vertex_ai_app/todos/todos.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TodosView();
  }
}

class TodosView extends StatelessWidget {
  const TodosView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<TodosBloc, TodosState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == TodosStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(l10n.todosErrorSnackbarText)),
                );
            }
          },
        ),
        BlocListener<TodosBloc, TodosState>(
          listenWhen:
              (previous, current) =>
                  previous.lastDeletedTodo != current.lastDeletedTodo &&
                  current.lastDeletedTodo != null,
          listener: (context, state) {
            final deletedTodo = state.lastDeletedTodo!;
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.todosTodoDeletedSnackbarText(deletedTodo.title),
                  ),
                  action: SnackBarAction(
                    label: l10n.todosUndoDeletionButtonText,
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                      context.read<TodosBloc>().add(
                        const TodosUndoDeletionRequested(),
                      );
                    },
                  ),
                ),
              );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.todosAppBarTitle),
          actions: const [TodosOptionsButton()],
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          key: const Key('homeView_addTodo_floatingActionButton'),
          onPressed: () => Navigator.of(context).push(EditTodoPage.route()),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<TodosBloc, TodosState>(
          builder: (context, state) {
            return switch (state.status) {
              TodosStatus.initial => const SizedBox(),
              TodosStatus.loading => const Center(
                child: CupertinoActivityIndicator(),
              ),
              TodosStatus.success => CupertinoScrollbar(
                child:
                    state.todos.isNotEmpty
                        ? ListView.builder(
                          itemCount: state.todos.length,
                          itemBuilder: (context, index) {
                            final todo = state.todos[index];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: _dateSeparatorBuilder(
                                    context,
                                    index,
                                    state.todos,
                                  ),
                                ),
                                TodoListTile(
                                  todo: todo,
                                  onToggleCompleted: (isCompleted) {
                                    context.read<TodosBloc>().add(
                                      TodosTodoCompletionToggled(
                                        todo: todo,
                                        isCompleted: isCompleted,
                                      ),
                                    );
                                  },
                                  onDismissed: (_) {
                                    context.read<TodosBloc>().add(
                                      TodosTodoDeleted(todo),
                                    );
                                  },
                                  onTap: () {
                                    Navigator.of(context).push(
                                      EditTodoPage.route(initialTodo: todo),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        )
                        : Center(
                          child: Text(
                            l10n.todosEmptyText,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
              ),
              TodosStatus.failure => Center(
                child: Text(
                  'There was an error while fetching your todos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}

Widget _dateSeparatorBuilder(
  BuildContext context,
  int index,
  List<Todo> todos,
) {
  final textTheme = Theme.of(context).textTheme;

  final todo = todos[index];
  final formattedDate = DateFormat.yMMMd().format(todo.dueDate);
  if (index == 0) {
    return Text(formattedDate, style: textTheme.titleMedium);
  }
  final previousTodo = todos[index - 1];
  if (!DateUtils.isSameDay(todo.dueDate, previousTodo.dueDate)) {
    return Text(formattedDate, style: textTheme.titleMedium);
  }
  return const SizedBox.shrink();
}
