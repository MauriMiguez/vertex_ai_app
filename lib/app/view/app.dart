import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:vertex_ai_app/home/home.dart';
import 'package:vertex_ai_app/l10n/l10n.dart';
import 'package:vertex_ai_app/theme/theme.dart';

class App extends StatelessWidget {
  const App({
    required this.todosRepository,
    required this.chatSession,
    super.key,
  });

  final TodosRepository todosRepository;
  final ChatSession chatSession;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: todosRepository),
        RepositoryProvider.value(value: chatSession),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlutterTodosTheme.light,
      darkTheme: FlutterTodosTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
