import 'package:flutter/widgets.dart';

class SliverPinnedHeader extends StatelessWidget {
  const SliverPinnedHeader({
    Key key,
    @required this.height,
    @required this.child,
  })  : assert(height != null),
        assert(child != null),
        super(key: key);

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverPinnedHeaderDelegate(
        height: height,
        child: child,
      ),
      pinned: true,
    );
  }
}

class _SliverPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SliverPinnedHeaderDelegate({
    @required this.height,
    @required this.child,
  });

  final double height;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_SliverPinnedHeaderDelegate oldDelegate) {
    return false;
  }
}
