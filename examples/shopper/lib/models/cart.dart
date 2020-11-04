import 'package:binder/binder.dart';
import 'package:shopper/models/catalog.dart';

final catalogRef = StateRef(CatalogModel());

final cartLogicRef = LogicRef((scope) => CartLogic(scope));

// Private reference to the state of the cart. Stores the ids of each item.
final _itemIdsRef = StateRef(const <int>[]);

/// Reference to the list of items in the cart.
final itemsRef = Computed((watch) {
  final catalog = watch(catalogRef);
  final itemIds = watch(_itemIdsRef);

  return itemIds.map((id) => catalog.getById(id)).toList();
});

/// Reference to the current total price of all items.
final totalPriceRef = Computed((watch) {
  final items = watch(itemsRef);
  return items.fold<int>(0, (total, current) => total + current.price);
});

class CartLogic with Logic {
  const CartLogic(this.scope);

  @override
  final Scope scope;

  /// Adds [item] to cart. This is the only way to modify the cart from outside.
  void add(Item item) {
    write(_itemIdsRef, [...read(_itemIdsRef), item.id]);
  }

  /// Removes [item] from the cart.
  void remove(Item item) {
    write(_itemIdsRef, read(_itemIdsRef).toList()..remove(item.id));
  }
}
