import 'package:flutter/material.dart';
import 'package:boot_chat_fe/page/register/regsiter_form.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('注册')),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16.0), child: RegisterForm()),
      ),
    );
  }
}
