import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[]);

class AuthService extends ChangeNotifier {
  FirebaseUser _user;

  FirebaseUser get user => _user;

  Future<FirebaseUser> tryLogin(GoogleSignInAccount gUser) async {
    var auth = await gUser.authentication;

    var cred = GoogleAuthProvider.getCredential(
        idToken: auth.idToken, accessToken: auth.accessToken);

    return (await _auth.signInWithCredential(cred)).user;
  }

  Future<FirebaseUser> init() async {
    return null;
    var gUser = await _googleSignIn.signInSilently();
    if (gUser != null)
      return tryLogin(gUser);
    else
      return null;
  }

  Future<FirebaseUser> login(GoogleSignInAccount gUser) async {
    _user = await tryLogin(gUser);
    notifyListeners();

    /*
    _messaging.requestNotificationPermissions(IosNotificationSettings());
    _messaging.getToken().then((token) {
      _db
          .collection("users")
          .document(fireUser.uid)
          .collection("tokens")
          .document(token)
          .setData({}, merge: true);
    });
     */

    notifyListeners();

    return _user;
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}