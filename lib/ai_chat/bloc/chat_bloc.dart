import 'package:equatable/equatable.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:vertex_ai_app/ai_chat/ai_chat.dart';
import 'package:vertex_ai_app/todos/todos.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required this.chatSession, required this.todosRepository})
    : super(ChatState.initial()) {
    on<ChatUserAddedMessage>(onChatUserAddedMessage);
    on<ChatTodosFiltersChanged>(onChatTodosFiltersChanged);
  }

  final ChatSession chatSession;
  final TodosRepository todosRepository;

  Future<void> onChatTodosFiltersChanged(
    ChatTodosFiltersChanged event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(todosFilters: event.todosFilters));
  }

  Future<void> onChatUserAddedMessage(
    ChatUserAddedMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state.conversationState == ConversationState.busy) {
      addError("Can't send a message while a conversation is in progress");
      throw Exception(
        "Can't send a message while a conversation is in progress",
      );
    }

    final userMessage = Message.userMessage(event.message);
    final llmMessage = Message.llmMessage('', MessageState.streaming);

    emit(
      state.copyWith(
        chat: state.chat.addMessage(userMessage),
        conversationState: ConversationState.busy,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 200));

    emit(state.copyWith(chat: state.chat.addMessage(llmMessage)));

    try {
      final responseStream = chatSession.sendMessageStream(
        Content.text(event.message),
      );
      await for (final block in responseStream) {
        await _processBlock(block, llmMessage.id, emit);
      }
    } catch (e) {
      addError(e);

      emit(
        state.copyWith(
          chat: state.chat.appendToMessage(
            llmMessage.id,
            "\nI'm sorry, I encountered an error processing your request. "
            'Please try again.',
          ),
        ),
      );
    } finally {
      emit(
        state.copyWith(
          chat: state.chat.finalizeMessage(llmMessage.id),
          conversationState: ConversationState.idle,
        ),
      );
    }
  }

  Future<void> _processBlock(
    GenerateContentResponse block,
    String llmMessageId,
    Emitter<ChatState> emit,
  ) async {
    final blockText = block.text;

    if (blockText != null) {
      emit(
        state.copyWith(
          chat: state.chat.appendToMessage(llmMessageId, blockText),
        ),
      );
    }

    if (block.functionCalls.isNotEmpty) {
      final responseStream = chatSession.sendMessageStream(
        Content.functionResponses([
          for (final functionCall in block.functionCalls)
            FunctionResponse(
              functionCall.name,
              await handleFunctionCall(functionCall.name, functionCall.args),
            ),
        ]),
      );
      await for (final response in responseStream) {
        final responseText = response.text;
        if (responseText != null) {
          emit(
            state.copyWith(
              chat: state.chat.appendToMessage(llmMessageId, responseText),
            ),
          );
        }
      }
    }
  }

  Future<Map<String, Object?>> handleFunctionCall(
    String functionName,
    Map<String, Object?> arguments,
  ) async {
    return switch (functionName) {
      'create_todo' => handleCreateTodo(arguments),
      'filter_todos' => handleFilterTodos(arguments),
      _ => handleUnknownFunction(functionName),
    };
  }

  Future<Map<String, Object?>> handleCreateTodo(
    Map<String, Object?> arguments,
  ) async {
    final title = arguments['title']! as String;
    final description = arguments['description'] as String?;
    final dueDate = arguments['dueDate']! as String;

    final todo = Todo(
      title: title,
      description: description ?? '',
      dueDate: DateTime.parse(dueDate),
    );

    await todosRepository.saveTodo(todo);

    return {'success': true, 'todo': todo.toJson()};
  }

  Future<Map<String, Object?>> handleFilterTodos(
    Map<String, Object?> arguments,
  ) async {
    final toDate =
        arguments['to'] != null
            ? DateTime.parse(arguments['to']! as String)
            : null;
    final fromDate =
        arguments['from'] != null
            ? DateTime.parse(arguments['from']! as String)
            : null;
    final todoStatus = arguments['todoStatus'] as String?;

    final filters = TodosFilters(
      to: toDate,
      from: fromDate,
      todoStatus: TodoStatus.values.firstWhere(
        (status) => status.name == todoStatus,
        orElse: () => throw Exception('Invalid todo status: $todoStatus'),
      ),
    );

    add(ChatTodosFiltersChanged(filters));

    final functionResults = {
      'success': true,
      'filters': filters.toLLMContextMap(),
    };

    return functionResults;
  }

  Map<String, Object?> handleUnknownFunction(String functionName) {
    return {
      'success': false,
      'reason': 'Unsupported function call $functionName',
    };
  }
}
