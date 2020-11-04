import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:shopper/models/cart.dart';
import 'package:shopper/models/catalog.dart';

class MyCatalog extends StatelessWidget {
  const MyCatalog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const _MyAppBar(),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _MyListItem(index),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    // The ref.select() method will let you listen to changes to
    // a *part* of a state. You define a function that "selects" (i.e. returns)
    // the part you're interested in, and the binder package will not rebuild
    // this widget unless that particular part of the state changes.
    //
    // This can lead to significant performance improvements.
    final isInCart = context.watch(itemsRef.select(
      // Here, we are only interested whether [item] is inside the cart.
      (items) => items.contains(item),
    ));

    return FlatButton(
      onPressed: isInCart
          ? null
          : () {
              // If the item is not in cart, we let the user add it.
              // We are using context.use() here because the callback
              // is executed whenever the user taps the button. In other
              // words, it is executed outside the build method.
              final cartLogic = context.use(cartLogicRef);
              cartLogic.add(item);
            },
      splashColor: Theme.of(context).primaryColor,
      child: isInCart
          ? const Icon(Icons.check, semanticLabel: 'ADDED')
          : const Text('ADD'),
    );
  }
}

class _MyAppBar extends StatelessWidget {
  const _MyAppBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Catalog', style: Theme.of(context).textTheme.headline1),
      floating: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }
}

class _MyListItem extends StatelessWidget {
  const _MyListItem(
    this.index, {
    Key key,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final item = context.watch(
      // Here, we are only interested in the item at [index]. We don't care
      // about any other change.
      catalogRef.select((catalog) => catalog.getByPosition(index)),
    );
    final textTheme = Theme.of(context).textTheme.headline6;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LimitedBox(
        maxHeight: 48,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: item.color,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(item.name, style: textTheme),
            ),
            const SizedBox(width: 24),
            _AddButton(item: item),
          ],
        ),
      ),
    );
  }
}
