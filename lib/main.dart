import 'package:boot_chat_fe/page/chat_page/chat_page.dart';
import 'package:boot_chat_fe/page/login/LoginPage.dart';
import 'package:boot_chat_fe/page/login/login_form.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: Colors.blue,
          secondary: Colors.yellow, // 设置为你想要的颜色
        ),
      ),
      home: Scaffold(
        body: LoginPage(),
      ),
    );
  }
  //   return const MaterialApp(
  //     home: Directionality(
  //       textDirection: TextDirection.ltr,
  //       //child: const ChatPage(),
  //       child: LoginForm(),
  //     ),
  //   );
  // }
}
