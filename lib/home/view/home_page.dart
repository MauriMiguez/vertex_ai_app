import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:vertex_ai_app/ai_chat/ai_chat.dart';
import 'package:vertex_ai_app/todos/todos.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  TodosBloc(todosRepository: context.read<TodosRepository>()),
        ),
        BlocProvider(
          create:
              (_) => ChatBloc(
                chatSession: context.read<ChatSession>(),
                todosRepository: context.read<TodosRepository>(),
              ),
        ),
      ],
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodosBloc, TodosState>(
      listenWhen: (_, current) => current is UserFilterChanged,
      listener: (context, state) {
        final encodedFilters = state.filters.toChatMessage();

        context.read<ChatBloc>().add(
          ChatUserAddedMessage('User filtered tasks $encodedFilters'),
        );
      },

      child: const Scaffold(
        body: Row(
          children: [Expanded(child: TodosPage()), Expanded(child: ChatPage())],
        ),
      ),
    );
  }
}
