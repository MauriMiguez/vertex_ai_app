// Copyright 2025 Brett Morgan. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertex_ai_app/ai_chat/ai_chat.dart';
import 'package:vertex_ai_app/utils/utils.dart';

/// A scrollable list displaying chat messages.
///
/// The list of messages is animated to the bottom (the newest message) whenever
/// the message list changes. This is done to keep the messages coming from the
/// LLM in frame as they stream in. If no messages are present, it displays a
/// prompt encouraging the user to start a conversation.
class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen:
          (previous, current) =>
              previous.chat.messages != current.chat.messages,
      listener: (context, state) {
        _scrollController.scrollToBottomAfterFrame();
      },
      builder: (context, state) {
        return BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final messages = state.chat.messages;
            if (messages.isEmpty) {
              return const Center(
                child: Text(
                  'Ask AI to create or filter your todos',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: messages[index]);
              },
            );
          },
        );
      },
    );
  }
}
