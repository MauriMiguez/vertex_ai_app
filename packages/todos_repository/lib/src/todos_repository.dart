import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todos_repository/todos_repository.dart';

/// {@template todo_exception}
// An exception to throw when there is an error fetching the `todo`.
/// {@endtemplate}
class TodoException implements Exception {
  /// {@macro todo_exception}
  const TodoException(this.error, this.stackTrace);

  /// The error that was caught.
  final Object error;

  /// The stack trace associated with the error.
  final StackTrace stackTrace;

  @override
  String toString() => error.toString();
}

/// {@template todo_not_found_exception}
/// Error thrown when a [Todo] with a given id is not found.
/// {@endtemplate}
class TodoNotFoundException extends TodoException {
  /// {@macro todo_not_found_exception}
  TodoNotFoundException(super.error, super.stackTrace);
}

/// {@template todos_repository}
/// A repository to manage the todos domain.
/// {@endtemplate}
class TodosRepository {
  /// {@macro todos_repository}
  TodosRepository({required FirebaseFirestore firebaseFirestore})
    : todosCollection = firebaseFirestore
          .collection('todos')
          .withConverter(
            fromFirestore: (snapshot, _) => Todo.fromJson(snapshot.data()!),
            toFirestore: (todo, _) => todo.toJson(),
          );

  /// The [CollectionReference] for the todos.
  final CollectionReference<Todo> todosCollection;

  /// Provides a [Stream] of all todos.
  Stream<List<Todo>> getTodos({
    DateTime? to,
    DateTime? from,
    bool? isCompleted,
  }) {
    try {
      Query<Todo> query = todosCollection;
      if (to != null) {
        final isToDate = to.toIso8601String();
        query = query.where('dueDate', isLessThanOrEqualTo: isToDate);
      }
      if (from != null) {
        final isFromDate = from.toIso8601String();
        query = query.where('dueDate', isGreaterThanOrEqualTo: isFromDate);
      }
      if (isCompleted != null) {
        query = query.where('isCompleted', isEqualTo: isCompleted);
      }
      query = query.orderBy('dueDate', descending: false);
      return query.snapshots().map(
        (event) => event.docs.map((doc) => doc.data()).toList(),
      );
    } catch (error, stackStrace) {
      throw TodoException(error, stackStrace);
    }
  }

  /// Provides a [Future] of todos filtered by the given parameters.
  ///
  /// Returns a list of todos that match the given parameters.
  Future<List<Todo>> getFilteredTodos({
    DateTime? to,
    DateTime? from,
    bool? isCompleted,
  }) async {
    try {
      Query<Todo> query = todosCollection;
      if (to != null) {
        final isToDate = to.toIso8601String();
        query = query.where('dueDate', isLessThanOrEqualTo: isToDate);
      }
      if (from != null) {
        final isFromDate = from.toIso8601String();
        query = query.where('dueDate', isGreaterThanOrEqualTo: isFromDate);
      }
      if (isCompleted != null) {
        query = query.where('isCompleted', isEqualTo: isCompleted);
      }
      final todosSnapshot = await query.get();

      final todos = todosSnapshot.docs.map((doc) => doc.data()).toList();

      return todos;
    } catch (error, stackStrace) {
      throw TodoException(error, stackStrace);
    }
  }

  /// Add a [todo].
  ///
  /// If a [todo] with the same id already exists, it will be replaced.
  Future<void> saveTodo(Todo todo) async {
    try {
      await todosCollection.doc(todo.id).set(todo);
    } catch (error, stackStrace) {
      throw TodoException(error, stackStrace);
    }
  }

  /// Deletes the `todo` with the given id.
  ///
  /// If no `todo` with the given id exists, a [TodoNotFoundException] error is
  /// thrown.
  Future<void> deleteTodo(String id) async {
    try {
      await todosCollection.doc(id).delete();
    } catch (error, stackStrace) {
      throw TodoException(error, stackStrace);
    }
  }

  /// Deletes all completed todos.
  ///
  /// Returns the number of deleted todos.
  Future<int> clearCompleted() async {
    try {
      final snapshot =
          await todosCollection.where('isCompleted', isEqualTo: true).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      return snapshot.size;
    } catch (error, stackStrace) {
      throw TodoException(error, stackStrace);
    }
  }

  /// Sets the `isCompleted` state of all todos to the given value.
  ///
  /// Returns the number of updated todos.
  Future<int> completeAll({required bool isCompleted}) async {
    try {
      final snapshot = await todosCollection.get();
      for (final doc in snapshot.docs) {
        await doc.reference.update({'isCompleted': isCompleted});
      }

      return snapshot.size;
    } catch (error, stackStrace) {
      throw TodoException(error, stackStrace);
    }
  }
}
