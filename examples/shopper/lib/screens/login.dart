import 'package:flutter/material.dart';

class MyLogin extends StatelessWidget {
  const MyLogin({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome',
                style: Theme.of(context).textTheme.headline1,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Username',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              RaisedButton(
                color: Colors.yellow,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/catalog');
                },
                child: const Text('ENTER'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
