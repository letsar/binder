import 'package:architecture/core/logics/busy.dart';
import 'package:architecture/core/widgets/busy_listener.dart';
import 'package:architecture/core/widgets/logic_loader.dart';
import 'package:architecture/modules/home/logic.dart';
import 'package:architecture/modules/user/view.dart';
import 'package:architecture/refs.dart';
import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

final userCountRef = Computed((watch) {
  return watch(usersRef).length;
});

class HomeView extends StatelessWidget {
  const HomeView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BinderScope(
      overrides: [
        busyRef.overrideWith(false),
        homeViewLogicRef.overrideWithSelf(),
      ],
      child: LogicLoader(
        loader: (context) => context.use(homeViewLogicRef).load(),
        child: BusyListener(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
            ),
            body: const UserGridView(),
          ),
        ),
      ),
    );
  }
}

class UserGridView extends StatelessWidget {
  const UserGridView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: context.watch(userCountRef),
        itemBuilder: (context, index) {
          final user = context.watch(usersRef.select((users) => users[index]));
          return BinderScope(
            overrides: [currentUserRef.overrideWith(user)],
            child: const UserCellView(),
          );
        },
      ),
    );
  }
}

class UserCellView extends StatelessWidget {
  const UserCellView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = context.watch(currentUserRef.select((user) => user.name));
    final initials = name.initials;
    return Card(
      child: InkWell(
        onTap: () {
          final user = context.read(currentUserRef);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) {
                return BinderScope(
                  overrides: [currentUserRef.overrideWith(user)],
                  child: const UserView(),
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primaryVariant,
                child: Text(initials),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringX on String {
  String get initials {
    final words = split(' ');
    return words.map((word) => word.characters.first.toUpperCase()).join();
  }
}
