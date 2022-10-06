import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
part "todo.freezed.dart";
part "todo.g.dart";

const _uuid = Uuid();

@freezed
class Todo with _$Todo {
  factory Todo(
    @required String id,
    @required String todotask,
    @required bool completed,
    @required bool favorited,
  ) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier([List<Todo>? initialTodos]) : super(initialTodos ?? []);
  void add(String todotask) {
    state = [...state, Todo(_uuid.v4(), todotask, false, false)];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            todo.id,
            todo.todotask,
            !todo.completed,
            todo.favorited,
          )
        else
          todo,
    ];
  }

  void fav(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            todo.id,
            todo.todotask,
            todo.completed,
            !todo.favorited,
          )
        else
          todo,
    ];
  }

  void edit({required String id, required String todotask}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            todo.id,
            todotask,
            todo.completed,
            todo.favorited,
          )
        else
          todo,
    ];
  }

  void delete(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
  }
}
