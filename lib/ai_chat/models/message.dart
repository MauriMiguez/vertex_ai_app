import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// A UUID generator for creating unique message IDs.
const _uuid = Uuid();

/// Represents the role of a message sender (user or LLM).
enum MessageRole { user, llm }

/// Represents the state of a message (complete or streaming).
enum MessageState { complete, streaming }

/// Represents a single message in a chat.
class Message extends Equatable {
  /// Creates a new [Message] object.
  ///
  /// * [id]: A unique identifier for this message.
  /// * [content]: The text content of the message.
  /// * [role]: The role of the sender (user or llm).
  /// * [updatedAt]: The timestamp indicating the last update to the message.
  /// * [state]: The current state of the message (complete or streaming).
  const Message({
    required this.id,
    required this.content,
    required this.role,
    required this.updatedAt,
    required this.state,
  });

  /// Creates a user message with the given [content].  The message is marked
  /// as complete.
  factory Message.userMessage(String content) => Message(
    id: _uuid.v4(),
    content: content,
    role: MessageRole.user,
    updatedAt: DateTime.now().toUtc(),
    state: MessageState.complete,
  );

  /// Creates an LLM message with the given [content] and [state].
  factory Message.llmMessage(String content, MessageState state) => Message(
    id: _uuid.v4(),
    content: content,
    role: MessageRole.llm,
    updatedAt: DateTime.now().toUtc(),
    state: state,
  );

  final String id;
  final String content;
  final MessageRole role;
  final DateTime updatedAt;
  final MessageState state;

  /// Updates an existing message with additional content and a new state.
  /// Takes the content to add as [addContent] and the new [state] of
  /// the message.
  Message updateMessage(String addContent, MessageState state) => copyWith(
    content: content + addContent,
    updatedAt: DateTime.now().toUtc(),
    state: state,
  );

  Message copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? updatedAt,
    MessageState? state,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      updatedAt: updatedAt ?? this.updatedAt,
      state: state ?? this.state,
    );
  }

  @override
  List<Object?> get props => [id, content, role, updatedAt, state];
}
