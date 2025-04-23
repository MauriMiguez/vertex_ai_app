// Copyright 2025 Brett Morgan. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vertex_ai_app/ai_chat/ai_chat.dart';

/// Displays a single message bubble in a chat interface.
///
/// This widget renders a visually distinct message bubble based on whether
/// the message was sent by the user or the AI.  It handles different message
/// states, such as streaming messages (indicated by a "Thinking..." indicator).
class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isStreaming = message.state == MessageState.streaming;
    final colorScheme = ColorScheme.of(context);

    if (isStreaming) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: JumpingDotsLoadingIndicator(),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.3,
        ),
        decoration: BoxDecoration(
          color:
              isUser
                  ? colorScheme.primary.withAlpha(25)
                  : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isUser
                    ? colorScheme.primary.withAlpha(50)
                    : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            MarkdownBody(
              data: message.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(p: const TextStyle(height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}
