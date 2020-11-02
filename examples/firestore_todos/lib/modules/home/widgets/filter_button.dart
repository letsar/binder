import 'package:firestore_todos/modules/common/widgets/generic_popup_menu_entry.dart';
import 'package:firestore_todos/modules/home/logic.dart';
import 'package:flutter/material.dart';
import 'package:binder/binder.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({
    Key key,
    this.visible,
  }) : super(key: key);

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final button = _Button(
      onSelected: (filter) => context.use(homeViewLogicRef).filter = filter,
    );
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 150),
      child: visible ? button : IgnorePointer(child: button),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key key,
    @required this.onSelected,
  }) : super(key: key);

  final PopupMenuItemSelected<VisibilityFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VisibilityFilter>(
      tooltip: 'Filter Todos',
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => [
        const FilterPopupMenuItem(
          label: 'Show All',
          value: VisibilityFilter.all,
        ),
        const FilterPopupMenuItem(
          label: 'Show Active',
          value: VisibilityFilter.active,
        ),
        const FilterPopupMenuItem(
          label: 'Show Completed',
          value: VisibilityFilter.completed,
        ),
      ],
      icon: const Icon(Icons.filter_list),
    );
  }
}

class FilterPopupMenuItem extends GenericPopupMenuEntry<VisibilityFilter> {
  const FilterPopupMenuItem({
    Key key,
    @required this.value,
    @required this.label,
  })  : assert(value != null),
        assert(label != null),
        super(key: key);

  @override
  final VisibilityFilter value;

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyText2;
    final activeStyle = defaultStyle.copyWith(color: theme.accentColor);

    return PopupMenuItem<VisibilityFilter>(
      value: value,
      child: Text(
        label,
        style: context.watch(activeFilterRef) == value
            ? activeStyle
            : defaultStyle,
      ),
    );
  }
}
