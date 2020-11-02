import 'package:binder/binder.dart';
import 'package:flutter/material.dart';

enum AppTab { todos, stats }

final activeTabRef = StateRef(AppTab.todos);

final tabSelectorLogicRef = LogicRef((scope) => TabSelectorLogic(scope));

class TabSelectorLogic with Logic {
  const TabSelectorLogic(this.scope);

  @override
  final Scope scope;

  AppTab get activeTab => read(activeTabRef);
  set activeTab(AppTab value) => write(activeTabRef, value);
}

class TabSelector extends StatelessWidget {
  const TabSelector({
    Key key,
    @required this.onTabSelected,
  }) : super(key: key);

  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final activeTab = context.watch(activeTabRef);
    return BottomNavigationBar(
      currentIndex: AppTab.values.indexOf(activeTab),
      onTap: (index) => onTabSelected(AppTab.values[index]),
      items: [
        ...AppTab.values.map((tab) {
          return BottomNavigationBarItem(
            icon: Icon(
              tab == AppTab.todos ? Icons.list : Icons.show_chart,
            ),
            label: tab == AppTab.stats ? 'Stats' : 'Todos',
          );
        }),
      ],
    );
  }
}
