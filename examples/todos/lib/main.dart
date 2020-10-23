import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:todos/home_logic.dart';

import 'entities/todo.dart';

final currentTodoRef = StateRef<Todo>(null);
final uncompletedTodosCountRef = Computed(
  (watch) => watch(todoListRef).where((todo) => !todo.completed).length,
);
final filteredTodosRef = Computed<List<Todo>>((watch) {
  final TodoListFilter filter = watch(todoListFilterRef);
  final List<Todo> todos = watch(todoListRef);

  switch (filter) {
    case TodoListFilter.active:
      return todos.where((todo) => !todo.completed).toList();
    case TodoListFilter.completed:
      return todos.where((todo) => todo.completed).toList();
    case TodoListFilter.all:
    default:
      return todos;
  }
});

void main() {
  runApp(const MyApp());
}

class Init extends StatefulWidget {
  const Init({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _InitState createState() => _InitState();
}

class _InitState extends State<Init> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      context.use(homeLogicRef).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BinderScope(
      child: Init(
        child: MaterialApp(
          home: Home(),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    Key key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Todo> todos = context.watch(filteredTodosRef);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            const Title(),
            TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                labelText: 'What needs to be done?',
              ),
              onSubmitted: (value) {
                context.use(homeLogicRef).add(value);
                textEditingController.clear();
              },
            ),
            const SizedBox(height: 42),
            const Toolbar(),
            if (todos.isNotEmpty) const Divider(height: 0),
            for (int i = 0; i < todos.length; i++) ...[
              if (i > 0) const Divider(height: 0),
              Dismissible(
                key: ValueKey(todos[i].id),
                onDismissed: (_) {
                  context.use(homeLogicRef).remove(todos[i].id);
                },
                child: BinderScope(
                  overrides: [currentTodoRef.overrideWith(todos[i])],
                  // child: TodoItem(id: todos[i].id),
                  child: const TodoItem(),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'todos',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(38, 47, 47, 247),
        fontSize: 100,
        fontWeight: FontWeight.w100,
        fontFamily: 'Helvetica Neue',
      ),
    );
  }
}

class Toolbar extends StatelessWidget {
  const Toolbar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int count = context.watch(uncompletedTodosCountRef);

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$count items left',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const TodoFilterTab(
            tooltip: 'All todos',
            label: 'All',
            filter: TodoListFilter.all,
          ),
          const TodoFilterTab(
            tooltip: 'Only uncompleted todos',
            label: 'Active',
            filter: TodoListFilter.active,
          ),
          const TodoFilterTab(
            tooltip: 'Only completed todos',
            label: 'Completed',
            filter: TodoListFilter.completed,
          ),
        ],
      ),
    );
  }
}

class TodoFilterTab extends StatelessWidget {
  const TodoFilterTab({
    Key key,
    this.tooltip,
    this.filter,
    this.label,
  }) : super(key: key);

  final String tooltip;
  final TodoListFilter filter;
  final String label;

  @override
  Widget build(BuildContext context) {
    final TodoListFilter currentFilter = context.watch(todoListFilterRef);

    return Tooltip(
      message: tooltip,
      child: FlatButton(
        onPressed: () => context.use(homeLogicRef).filter = filter,
        visualDensity: VisualDensity.compact,
        textColor: currentFilter == filter ? Colors.blue : null,
        child: Text(label),
      ),
    );
  }
}

class TodoItem extends StatefulWidget {
  const TodoItem({
    Key key,
    this.id,
  }) : super(key: key);

  final String id;

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  FocusNode itemFocusNode;
  FocusNode textFieldFocusNode;
  TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    itemFocusNode = FocusNode();
    textFieldFocusNode = FocusNode();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    itemFocusNode.dispose();
    textFieldFocusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Todo todo = context.watch(currentTodoRef);
    final isFocused = itemFocusNode.hasFocus;

    return Material(
      color: Colors.white,
      elevation: 6,
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = todo.description;
            setState(() {});
          } else {
            context.use(homeLogicRef).edit(
                  id: todo.id,
                  description: textEditingController.text,
                );
          }
        },
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) => context.use(homeLogicRef).toggle(todo.id),
          ),
          title: isFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(todo.description),
        ),
      ),
    );
  }
}
