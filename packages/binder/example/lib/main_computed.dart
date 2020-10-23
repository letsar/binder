import 'package:binder/binder.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BinderScope(child: MaterialApp(home: HomeView()));
  }
}

final productsRef = StateRef(const [
  Product('Apple', 5),
  Product('Avocado', 2.5),
  Product('Banana', 1),
  Product('Cherry', 1.5),
  Product('Orange', 3),
  Product('Peach', 9),
  Product('Tomato', 2),
]);

const min = 0.0;
const max = 10.0;
final minPriceRef = StateRef(min);
final maxPriceRef = StateRef(max);

final filteredProductsRef = Computed((watch) {
  final products = watch(productsRef);
  final minPrice = watch(minPriceRef);
  final maxPrice = watch(maxPriceRef);

  return products
      .where((p) => p.price >= minPrice && p.price <= maxPrice)
      .toList();
});

class HomeView extends StatelessWidget {
  const HomeView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Column(
        children: const [
          FilterView(),
          Expanded(child: ProductListView()),
        ],
      ),
    );
  }
}

final filterViewLogicRef = LogicRef((scope) => FilterViewLogic(scope));

class FilterViewLogic with Logic {
  const FilterViewLogic(this.scope);

  @override
  final Scope scope;

  void filter(double min, double max) {
    write(minPriceRef, min);
    write(maxPriceRef, max);
  }
}

class FilterView extends StatelessWidget {
  const FilterView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minPrice = context.watch(minPriceRef);
    final maxPrice = context.watch(maxPriceRef);
    return RangeSlider(
      values: RangeValues(minPrice, maxPrice),
      min: minPriceRef.initialState,
      max: maxPriceRef.initialState,
      divisions: 20,
      labels: RangeLabels('$minPrice', '$maxPrice'),
      onChanged: (values) => context.use(filterViewLogicRef).filter(
            values.start,
            values.end,
          ),
    );
  }
}

class ProductListView extends StatelessWidget {
  const ProductListView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredProducts = context.watch(filteredProductsRef);

    return ListView(
      children: [
        ...filteredProducts.map(
          (p) => Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                p.name,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Product {
  const Product(this.name, this.price);

  final String name;
  final double price;
}
