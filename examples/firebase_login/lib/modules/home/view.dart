import 'package:binder/binder.dart';
import 'package:firebase_login/modules/authentication/logic.dart';
import 'package:firebase_login/modules/home/logic.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    Key key,
  }) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomeView());
  }

  @override
  Widget build(BuildContext context) {
    return BinderScope(
      overrides: [homeViewLogicRef.overrideWithSelf()],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: <Widget>[
            IconButton(
              key: const Key('homePage_logout_iconButton'),
              icon: const Icon(Icons.exit_to_app),
              onPressed: () => context.use(homeViewLogicRef).signOut(),
            )
          ],
        ),
        body: const Align(
          alignment: Alignment(0, -1 / 3),
          child: UserView(),
        ),
      ),
    );
  }
}

class UserView extends StatelessWidget {
  const UserView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.watch(currentUserRef);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Avatar(photo: user.photo),
        const Gap(4),
        Text(user.email, style: textTheme.headline6),
        const Gap(4),
        Text(user.name ?? '', style: textTheme.headline5),
      ],
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({
    Key key,
    this.photo,
  }) : super(key: key);

  final String photo;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundImage: photo != null ? NetworkImage(photo) : null,
      child: photo == null ? const Icon(Icons.person_outline, size: 48) : null,
    );
  }
}
