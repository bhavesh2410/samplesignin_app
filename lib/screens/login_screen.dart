
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../auth.dart';
import 'home_screen.dart';


final _authProvider = ChangeNotifierProvider<Auth>((ref) {
  return Auth();
});

class LoginScreen extends ConsumerWidget {

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    print(watch(_authProvider).isLoading);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Center(
            child: watch(_authProvider).isLoading
                ? CircularProgressIndicator()
                : RaisedButton(
              onPressed: () async {
                print('22');
                await Auth().signInWithGoogle().then((value) {
                  if (value == 'Error') {
                    print('33');
                    showDialog(
                        context: context,
                        child: AlertDialog(
                          actions: [
                            RaisedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Ok'),
                            ),
                          ],
                          content: Text('An Error Occured'),
                        ));
                  } else if (value.endsWith('iiitsurat.ac.in')) {
                    Navigator.of(context)
                        .pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => HomeScreen()));
                  } else {
                    showDialog(
                        context: context,
                        child: AlertDialog(
                          actions: [
                            RaisedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Ok'),
                            ),
                          ],
                          title: Text('Error'),
                          content: Text('Not a valid email id'),
                        ));
                  }
                });
              },
              child: Text(
                  'Google Sign in'
              ),
            ),
          ),
        ));
  }
}