import 'package:binder/binder.dart';
import 'package:firestore_todos/modules/filtered_todos/view.dart';
import 'package:firestore_todos/modules/home/widgets/extra_actions.dart';
import 'package:firestore_todos/modules/home/widgets/filter_button.dart';
import 'package:firestore_todos/modules/home/widgets/tab_selector.dart';
import 'package:firestore_todos/modules/stats/view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeTab = context.watch(activeTabRef);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Todos'),
        actions: [
          FilterButton(visible: activeTab == AppTab.todos),
          const ExtraActions(),
        ],
      ),
      body: activeTab == AppTab.todos
          ? const FilteredTodosView()
          : const StatsView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTodo');
        },
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: TabSelector(
        onTabSelected: (tab) =>
            context.use(tabSelectorLogicRef).activeTab = tab,
      ),
    );
  }
}
