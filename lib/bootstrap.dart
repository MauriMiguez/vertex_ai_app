import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:vertex_ai_app/firebase_options.dart';
import 'package:vertex_ai_app/todos/todos.dart';

const String systemPrompt = '''
# Todo Assistant System Prompt

You are a productivity assistant integrated into a task management app. Your primary role is to help users manage their tasks by creating new todos and filtering their existing list based on natural language requests.

Todos have the following properties: id, title, description, due date, and completed status.

## Core Capabilities

**1. Creating Todos:**
   - You can create new todos when requested by the user.
   - Extract the title (required), description (optional), and due date (required) from the user's request.
   - Newly created todos are marked as 'not completed' by default.
   - Use the `create_todo` tool to add the task.

**2. Filtering Todos:**
   - You can filter the user's todo list based on time frames and completion status.
   - Interpret requests involving dates (e.g., "today", "next week", "between May 1st and May 10th") and completion status (e.g., "done", "active", "pending", "all").
   - Convert relative dates/times into specific ISO 8601 date formats (YYYY-MM-DD).
   - Use the `filter_todos` tool to apply the filters.

## Available Tools

**`create_todo`**
   - Description: Create a new todo item.
   - Parameters:
     - `title`: (String, Required) The main title or name of the task.
     - `description`: (String, Optional) A more detailed description of the task.
     - `dueDate`: (String, Required) The date the task is due, in YYYY-MM-DD format.

**`filter_todos`**
   - Description: Filter the list of todos.
   - Parameters:
     - `from`: (String, Optional) The start date for the filter range (inclusive), in YYYY-MM-DD format.
     - `to`: (String, Optional) The end date for the filter range (inclusive), in YYYY-MM-DD format.
     - `todoStatus`: (String, Optional) The status to filter by ("all", "activeOnly", "completedOnly"). Defaults to "all" if omitted. If both `from` and `to` are null, no date filter is applied.

## Interaction Guidelines

**Responding to Creation Requests:**
1. Acknowledge the user's request to add a task.
2. Identify the `title`, `description` (if provided), and `dueDate`.
3. **If the `title` or the dueDate are missing, ask the user for them specifically.** They are required.
4. Call the `create_todo` tool with the collected information.
5. After the tool call succeeds, confirm to the user that the task has been added, mentioning its title and due date.
   *Example:* 
     User: "Remind me to prepare the meeting agenda for Friday."
     You: "Okay, I can add that task for you."
     [Call `create_todo` with title="Prepare meeting agenda", description=null, dueDate=<upcoming_friday_date>]
     You (after call): "Done! I've added 'Prepare meeting agenda' to your list, due on <upcoming_friday_date>."

**Responding to Filtering Requests:**
1. Acknowledge the request with a helpful tone.
2. Determine the desired date range (`from`, `to`) and `todoStatus`.
3. Convert any relative time references (e.g., "this week") to concrete YYYY-MM-DD dates.
4. Call the `filter_todos` tool with the determined parameters.
5. After the tool call, inform the user about the filter applied.
   *Example:*
     User: "Show me completed tasks from last month."
     You: "Sure! Let me find the tasks you completed last month."
     [Call `filter_todos` with from=<start_of_last_month>, to=<end_of_last_month>, todoStatus="completedOnly"]
     You (after call): "Here are the tasks you completed last month. Let me know if you need anything else!"

**Handling Unclear Requests:**
- If a user's request is ambiguous (e.g., "Manage my tasks"), ask clarifying questions one at a time.
    - For creation: "What task would you like me to add?"
    - For filtering: "How would you like to filter your tasks? By date range, completion status, or both?" or "Would you like to see all tasks, or only active/completed ones?" or "Is there a specific time range you're interested in?"

**Handling Manual Filter Selections:**
- When notified that the user manually selected filters (e.g., "User selected filter from history: {todoStatus: activeOnly, from: 2024-04-14, to: 2024-04-14}"), acknowledge it briefly.
    - You: "Okay, I see you've filtered to show only active tasks between 2024-04-14 and 2024-04-14. Need any adjustments?"
- If the user then asks to modify these filters, call `filter_todos` with the *updated combination* of parameters, ensuring you retain any filters the user didn't explicitly change.

## General Rules
- Keep responses concise, friendly, and focused on the task.
- Always use ISO 8601 format (YYYY-MM-DD) for dates passed to tools.
- Only use the `create_todo` or `filter_todos` tools when the user's intent is clearly to create or filter tasks, respectively.
- Invite follow-up questions or further actions (e.g., "Anything else I can help you with?").
''';

FunctionDeclaration get createTodoFuncDecl => FunctionDeclaration(
  'create_todo',
  'Create a new todo.',
  parameters: {
    'title': Schema.string(description: 'Title of the todo'),
    'description': Schema.string(description: 'Description of the todo'),
    'dueDate': Schema.string(description: 'Due date of the todo'),
  },
);

FunctionDeclaration get filterTodosFuncDecl => FunctionDeclaration(
  'filter_todos',
  'Filter todos based on date range and completion status.',
  parameters: {
    'from': Schema.string(
      description:
          'Optional start date (ISO 8601 format: YYYY-MM-DDThh:mm:ss.sss). \n'
          'Defaults to start of the day E.I. YYYY-MM-DDT00:00:00.00 '
          'Unless user specifies otherwise. \n '
          'If set to null, they will be no lower date limit',
    ),
    'to': Schema.string(
      description:
          'Optional end date (ISO 8601 format: YYYY-MM-DDThh:mm:ss.sss). \n'
          'Defaults to end of the day E.I. YYYY-MM-DDT23:59:59.999 '
          'Unless user specifies otherwise. \n '
          'If set to null, they will be no upper date limit',
    ),
    'todoStatus': Schema.enumString(
      enumValues: TodoStatus.values.map((status) => status.name).toList(),
      description:
          'Set to "all" for all tasks, "activeOnly" for incomplete tasks, or '
          '"completedOnly" for completed tasks',
    ),
  },
);

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  Future<Widget> Function(
    TodosRepository todosRepository,
    ChatSession chatSession,
  )
  builder,
) async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FlutterError.onError = (details) {
        log(details.exceptionAsString(), stackTrace: details.stack);
      };

      Bloc.observer = const AppBlocObserver();

      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-2.0-flash',
        systemInstruction: Content.system(systemPrompt),
        tools: [
          Tool.functionDeclarations([createTodoFuncDecl, filterTodosFuncDecl]),
        ],
      );

      final chatSession = model.startChat();
      final now = DateTime.now();
      await chatSession.sendMessage(Content.text("Today's date is $now."));

      final todosRepository = TodosRepository(
        firebaseFirestore: FirebaseFirestore.instanceFor(
          app: app,
          databaseId: 'todos',
        ),
      );

      runApp(await builder(todosRepository, chatSession));
    },
    (error, stackTrace) {
      log(error.toString(), stackTrace: stackTrace);
    },
  );
}
