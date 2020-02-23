import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:heart/services/auth.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Consumer<AuthService>(
                      builder: (ctx, AuthService auth, _) =>
                          Text("Welcome, ${auth.user.displayName}!"))
                ])));
  }
}
