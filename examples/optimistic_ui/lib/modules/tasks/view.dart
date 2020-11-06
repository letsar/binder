import 'package:flutter/material.dart';
import 'package:binder/binder.dart';
import 'package:optimistic_ui/data/entities/task.dart';
import 'package:optimistic_ui/modules/tasks/logic.dart';

final currentTaskRef = StateRef<Task>(null);

final sortedTasksRef = Computed((watch) {
  return watch(tasksRef).toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
});

class TasksView extends StatelessWidget {
  const TasksView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateListener(
      watchable: errorRef,
      onStateChanged: (context, String error) {
        Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(error),
            behavior: SnackBarBehavior.floating,
          ));
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Tasks')),
        body: const TaskList(),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () => context.use(tasksViewLogicRef).add(),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch(sortedTasksRef);
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return BinderScope(
          overrides: [currentTaskRef.overrideWith(tasks[index])],
          child: const TaskTile(),
        );
      },
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final task = context.watch(currentTaskRef);
    return ListTile(
      title: Text(task.id),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          context.use(tasksViewLogicRef).delete(task);
        },
      ),
    );
  }
}
