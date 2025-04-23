import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertex_ai_app/ai_chat/ai_chat.dart';
import 'package:vertex_ai_app/ai_chat/view/todos_filters_view.dart';
import 'package:vertex_ai_app/todos/todos.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatView();
  }
}

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final conversationState = context.select<ChatBloc, ConversationState>(
      (chat) => chat.state.conversationState,
    );

    return BlocListener<ChatBloc, ChatState>(
      listenWhen:
          (previous, current) => previous.todosFilters != current.todosFilters,
      listener: (context, state) {
        final filters = state.todosFilters;

        context.read<TodosBloc>().add(
          TodosFilterChanged(filters, wasAIChange: true),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('To-do agent')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TodosFiltersView(),
                const SizedBox(height: 16),
                const Expanded(child: MessageList()),
                ChatInput(
                  conversationState: conversationState,
                  sendMessage: (message) {
                    context.read<ChatBloc>().add(ChatUserAddedMessage(message));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
