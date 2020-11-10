import 'package:curricula/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      ProviderScope(
          child: MyApp()
      )
  );
}


final _authProvider = ChangeNotifierProvider<Auth>((ref) {
  return Auth();
});

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Consumer(builder: (consumer, watch, child) {
      final auth = watch(_authProvider);
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sample',
        theme: ThemeData(primarySwatch: Colors.red),
        home: auth.isAuth
            ? HomeScreen()
            : LoginScreen()
      );});
  }
}
