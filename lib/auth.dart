import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

ChangeNotifierProvider authProvider = ChangeNotifierProvider<Auth>((ref) {
  return Auth();
});

final GoogleSignIn googleSignIn = GoogleSignIn();

FirebaseAuth auth = FirebaseAuth.instance;

class Auth extends ChangeNotifier {

  String _error;
  String _token;
  bool _loading = false;
  GoogleSignInAccount googleUser;
  GoogleSignInAuthentication googleAuth;

  String get error => _error;
  bool get isLoading => _loading;
  bool get isAuth {
    return _token != null;
  }

  Future<String> signInWithGoogle() async {
    try {
      _loading = true;
      notifyListeners();
      googleUser = await _googleSignIn.signIn();
      googleAuth = await googleUser.authentication;
      print(googleUser.email);
      if(googleUser.email.endsWith('iiitsurat.ac.in')) {
        final GoogleAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        _token = credential.idToken;
        final UserCredential authResult = await auth.signInWithCredential(credential);

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'accessToken': googleAuth.accessToken,
          'idToken': googleAuth.idToken
        });
        prefs.setString('userData', userData);
        _loading = false;
        notifyListeners();
        return googleUser.email;
      }
      else{
        print(googleUser.email);
        _googleSignIn.signOut();
        _loading = false;
        notifyListeners();
        return googleUser.email;
      }

    } catch (e) {
      print('Error-->${e.toString()}');
     _loading = true;
      return 'Error';
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedData = json.decode(
        prefs.getString('userData')) as Map<String, Object>;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: extractedData['accessToken'],
      idToken: extractedData['idToken'],
    );

    _token = credential.idToken;
    final UserCredential authResult = await auth.signInWithCredential(credential);

    notifyListeners();
    return true;
  }

  Future<bool> signOut() async {
    _loading = true;
    notifyListeners();
    await auth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    _loading = false;
    notifyListeners();
    return true;
  }

}
