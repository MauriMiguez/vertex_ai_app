import 'package:vertex_ai_app/app/app.dart';
import 'package:vertex_ai_app/bootstrap.dart';

void main() {
  bootstrap((todosRepository, chatSession) async {
    return App(todosRepository: todosRepository, chatSession: chatSession);
  });
}
