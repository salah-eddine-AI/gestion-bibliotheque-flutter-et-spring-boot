import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'UserPage.dart';
import 'Adminpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/userPage': (context) {
          final int userId = ModalRoute.of(context)!.settings.arguments as int;
          return UserPage(userId: userId);
        },
        '/adminPage': (context) {
          final int userId = ModalRoute.of(context)!.settings.arguments as int;
          return AdminPage(userId: userId);
        },
      },
    );
  }
}
