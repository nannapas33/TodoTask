import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:todolist/settingpage.dart';
import 'package:todolist/todo/todo.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Sukhumvitset'),
      home: Home(),
    );
  }
}

//Main Provider
final todolistProvider =
    StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier([Todo('', 'New Task', false, false)]);
});

// Filter
final todoListFilterProvider = StateProvider((_) => TodolistFilter.all);

enum TodolistFilter {
  all,
  active,
  completed,
  fav,
  deleted,
}

final filteredTodosProvider = Provider<List<Todo>?>((ref) {
  final filter = ref.watch(todoListFilterProvider);
  final todos = ref.watch(todolistProvider);

  switch (filter) {
    case TodolistFilter.all:
      return todos;
    case TodolistFilter.active:
      return todos.where((todo) => !todo.completed).toList();
    case TodolistFilter.completed:
      return todos.where((todo) => todo.completed).toList();
    case TodolistFilter.fav:
      return todos.where((todo) => todo.favorited).toList();
    case TodolistFilter.deleted:
      break;
  }
});

final currentTodo = Provider<Todo>((ref) => throw UnimplementedError());
final completecountProvider = StateProvider((ref) => 0);

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(filteredTodosProvider);
    String alltask = todos!.length.toString();
    String completed =
        todos.where((todo) => todo.completed).toList().length.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: Colors.grey.shade500,
            size: 32,
          ),
          onPressed: () {
            SideSheet.left(
              context: context,
              width: MediaQuery.of(context).size.width * 0.75,
              body: SafeArea(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ListTile(
                      title: Text(
                        'User Name',
                        style: TextStyle(
                            fontSize: 24, color: Colors.grey.shade800),
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                          ),
                          Text(
                            completed + '/' + alltask,
                            style: const TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                      trailing: IconButton(
                          icon: const Icon(
                            Icons.settings,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SettingPage()));
                          }),
                    ),
                    ExpansionTile(
                      title: Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: const [
                          Icon(
                            Icons.favorite_outline,
                            size: 16,
                          ),
                          Text('Favorite'),
                        ],
                      ),
                    ),
                    ExpansionTile(
                      title: Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: const [
                          Icon(
                            Icons.star_border,
                            size: 18,
                          ),
                          Text('Stared'),
                        ],
                      ),
                    ),
                    ExpansionTile(
                      title: Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: const [
                          Icon(
                            Icons.label_important_outline,
                            size: 16,
                          ),
                          Text('Labeled'),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          const ToolBar(),
          if (todos.isNotEmpty)
            const Divider(
              height: 1,
            ),
          for (var i = 0; i < todos.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ProviderScope(
                overrides: [currentTodo.overrideWithValue(todos[i])],
                child: const TodoItem())
          ],
        ],
      )),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
                child: IconButton(
                    onPressed: () {
                      ref.read(todoListFilterProvider.notifier).state =
                          TodolistFilter.all;
                    },
                    icon: Icon(
                      Icons.home,
                      color: Colors.grey.shade700,
                    ))),
            Expanded(
                child: IconButton(
                    onPressed: () {
                      ref.read(todoListFilterProvider.notifier).state =
                          TodolistFilter.fav;
                    },
                    icon: Icon(Icons.favorite_rounded,
                        color: Colors.grey.shade700))),
            Expanded(
                child: IconButton(
                    onPressed: () {
                      ref.read(todoListFilterProvider.notifier).state =
                          TodolistFilter.completed;
                    },
                    icon: Icon(Icons.check_box, color: Colors.grey.shade700))),
          ],
        ),
      ),
    );
  }
}

class ToolBar extends ConsumerStatefulWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ToolBarState();
}

class _ToolBarState extends ConsumerState<ToolBar> {
  var searchControlller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Expanded(
                child: TextField(
              decoration: InputDecoration(
                  icon: const Icon(Icons.search_outlined),
                  hintText: 'Search for ...',
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 0.5),
                      borderRadius: BorderRadius.circular(16))),
              controller: searchControlller,
            )),
            IconButton(
                onPressed: () {
                  showtodoTextfield();
                },
                icon: Icon(
                  Icons.add_rounded,
                  size: 30,
                  color: Colors.grey.shade500,
                ))
          ],
        ),
      ),
    );
  }

  Future showtodoTextfield() {
    var newtodocontroller = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('New Todo'),
              content: TextField(
                controller: newtodocontroller,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      final newTask = newtodocontroller.value.text;
                      ref.read(todolistProvider.notifier).add(newTask);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            ));
  }
}

class TodoItem extends ConsumerStatefulWidget {
  const TodoItem({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TodoItemState();
}

final buttonOnTapProvider = StateProvider((ref) => false);
final favButtonProvider =
    StateProvider((ref) => const Icon(Icons.favorite_outline_rounded));

class _TodoItemState extends ConsumerState<TodoItem> {
  var edittodocontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todo = ref.watch(currentTodo);
    return Material(
      child: ListTile(
        leading: Checkbox(
          activeColor: Colors.grey.shade700,
          value: todo.completed,
          onChanged: (value) =>
              ref.read(todolistProvider.notifier).toggle(todo.id),
        ),
        title: Text(todo.todotask),
        trailing: Wrap(
          children: [
            IconButton(
              icon: todo.favorited == true
                  ? const Icon(Icons.favorite_rounded)
                  : const Icon(Icons.favorite_outline_rounded),
              onPressed: () {
                ref.read(todolistProvider.notifier).fav(todo.id);
              },
            ),
            PopupMenuButton<int>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () {
                    Future.delayed(const Duration(seconds: 0),
                        () => showEditTodotextfield(todo.id));
                  },
                  child: Row(
                    children: const [
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Edit")
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => ref.read(todolistProvider.notifier).delete(todo),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Delete")
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future showEditTodotextfield(todoId) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('New Todo'),
              content: TextField(
                controller: edittodocontroller,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      final editedTask = edittodocontroller.value.text;
                      ref
                          .read(todolistProvider.notifier)
                          .edit(id: todoId, todotask: editedTask);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            ));
  }
}
