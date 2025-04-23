part of 'chat_bloc.dart';

class ChatState extends Equatable {
  const ChatState({
    required this.chat,
    required this.conversationState,
    this.todosFilters = const TodosFilters(),
  });

  ChatState.initial()
    : this(chat: Chat.initial(), conversationState: ConversationState.idle);

  final Chat chat;
  final ConversationState conversationState;
  final TodosFilters todosFilters;

  ChatState copyWith({
    Chat? chat,
    ConversationState? conversationState,
    TodosFilters? todosFilters,
  }) {
    return ChatState(
      chat: chat ?? this.chat,
      conversationState: conversationState ?? this.conversationState,
      todosFilters: todosFilters ?? this.todosFilters,
    );
  }

  @override
  List<Object?> get props => [chat, conversationState, todosFilters];
}
