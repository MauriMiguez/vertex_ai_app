import 'package:equatable/equatable.dart';
import 'package:vertex_ai_app/ai_chat/ai_chat.dart';

class Chat extends Equatable {
  const Chat({required this.messages});

  /// Creates an initial [Chat] with an empty list of messages.
  factory Chat.initial() => const Chat(messages: []);

  final List<Message> messages;

  Chat copyWith({List<Message>? messages}) {
    return Chat(messages: messages ?? this.messages);
  }

  @override
  List<Object?> get props => [messages];

  Chat addMessage(Message message) =>
      copyWith(messages: [...messages, message]);

  // /// Adds a new LLM (Language Model) message to the chat, with [content] as
  // /// the text of the LLM's message, and [state] the current state of the
  // /// message.
  // Chat addLlmMessage(String content, MessageState state) =>
  //     copyWith(messages: [...messages, Message.llmMessage(content, state)]);

  /// Appends additional content, as [addContent], to an existing
  /// message identified by [id]. If no message with the given [id]
  /// is found, the current [Chat] is returned unchanged.
  Chat appendToMessage(String id, String addContent) {
    final splitIndex = messages.indexWhere((message) => message.id == id);
    if (splitIndex == -1) {
      return this;
    }
    final before = messages.sublist(0, splitIndex);
    final message = messages[splitIndex];
    final updatedMessage = message.copyWith(
      content: message.content + addContent,
    );
    final after = messages.sublist(splitIndex + 1);
    return copyWith(messages: [...before, updatedMessage, ...after]);
  }

  /// Finalizes a message in the chat, identified by [id], marking it as
  /// complete. If no message with the given [id] is found, the current
  /// [Chat] is returned unchanged.
  Chat finalizeMessage(String id) {
    final splitIndex = messages.indexWhere((message) => message.id == id);
    if (splitIndex == -1) {
      return this;
    }
    final before = messages.sublist(0, splitIndex);
    final message = messages[splitIndex];
    final updatedMessage = message.copyWith(
      state: MessageState.complete,
      content: message.content.trimRight(),
    );
    final after = messages.sublist(splitIndex + 1);
    return copyWith(messages: [...before, updatedMessage, ...after]);
  }

  /// Clears all messages from the chat.
  Chat clearMessages() => copyWith(messages: []);
}
