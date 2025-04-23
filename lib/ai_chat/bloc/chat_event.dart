part of 'chat_bloc.dart';

sealed class ChatEvent {}

final class ChatUserAddedMessage extends ChatEvent {
  ChatUserAddedMessage(this.message);

  final String message;
}

final class ChatTodosFiltersChanged extends ChatEvent {
  ChatTodosFiltersChanged(this.todosFilters);

  final TodosFilters todosFilters;
}
