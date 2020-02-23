import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:heart/services/auth.dart';
import 'home.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[]);

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    _tryCachedSignIn();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(children: <Widget>[
                    const Text('Sign in to Heart.'),
                    const SizedBox(height: 20),
                    GoogleSignInButton(onPressed: () => _handleGoogleLogin(ctx))
                  ])
                ])));
  }

  Future<void> _handleGoogleLogin(BuildContext ctx) async {
    var auth = Provider.of<AuthService>(ctx, listen: false);

    var user = await _googleSignIn.signIn();
    await auth.login(user);

    Navigator.push(ctx, MaterialPageRoute(builder: (ctx) => Home()));
  }

  Future<void> _tryCachedSignIn() async {
    //var gUser = await _googleSignIn.signInSilently();
    //if (gUser != null)
    //  _login(gUser);
  }

/*
  Future<void> _handleTest(BuildContext ctx) async {
    var self = await _db.collection("users").document(_user.uid).get();
    var code = self["code"];

    final HttpsCallable test = _fns.getHttpsCallable(functionName: "heart");
    await test.call(<String, dynamic>{"code": "SDTLX"});

    //final HttpsCallable add = _fns.getHttpsCallable(functionName: "sendFriendRequest");
    //await add.call(<String, dynamic>{"code": "SDTLX"});

    //final HttpsCallable accept = _fns.getHttpsCallable(functionName: "acceptFriendRequest");
    //await accept.call(<String, dynamic>{"code": "HDGKM"});

    await showDialog(
        context: ctx,
        child:
        AlertDialog(title: const Text("Invite Code"), content: Text(code)));
  }
   */
}
