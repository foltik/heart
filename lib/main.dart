import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'services/auth.dart';
import 'views/login.dart';
import 'views/home.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[]);
final CloudFunctions _fns = CloudFunctions.instance;
final Firestore _db = Firestore.instance;
final FirebaseMessaging _messaging = FirebaseMessaging();

void main() => runApp(
    ChangeNotifierProvider(create: (ctx) => AuthService(), child: App()));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
        title: 'Heart',
        theme: new ThemeData(primarySwatch: Colors.red),
        home: FutureBuilder<FirebaseUser>(
            future: Provider.of<AuthService>(ctx).init(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.done)
                return snap.hasData ? Home() : Login();
              else
                return CircularProgressIndicator();
            }));
  }
}

/*
class AppState extends State<App> {
  FirebaseUser _user;

  @override
  void initState() {
    super.initState();
    _firebaseAuth.onAuthStateChanged.listen((FirebaseUser u) {
      setState(() => _user = u);
    });
  }

        home: Login(onLogin: () {
          Navigator.push(
              ctx, new MaterialPageRoute(builder: (_) => new HomePage()));
        }));
  }
}
 */
