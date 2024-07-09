import 'package:flutter/material.dart';
import 'package:boot_chat_fe/component/current_user.dart';
import 'package:boot_chat_fe/component/dialog_util.dart';
import 'package:boot_chat_fe/component/my_http_client.dart';
import 'package:boot_chat_fe/component/image_captcha.dart';
import 'package:boot_chat_fe/component/local_storage.dart';
import 'package:boot_chat_fe/page/chat_page/chat_page.dart';
import 'package:boot_chat_fe/page/register/RegisterPage.dart';

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // TextEditingController _codeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _captchaController = TextEditingController();
  final GlobalKey<ImageCaptchaState> _imageCaptchaKey =
      GlobalKey<ImageCaptchaState>();

  @override
  void initState() {
    super.initState();
    CurrentUser.updateUser().then((value) {
      print("user.....${value}");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatPage()),
      );
    }).catchError((err) {
      print("用户没有登录...$err");
    });
  }

  void loginHandler() {
    if (_formKey.currentState?.validate() ?? true) {
      _imageCaptchaKey.currentState!.captchaKey;
      MyHttpClient.postNoToken("/api/auth/by_pwd", {
        "email": _emailController.text,
        "password": _passwordController.text,
        "captchaCode": _captchaController.text,
        "captchaKey": _imageCaptchaKey.currentState!.captchaKey
      }).then((value) {
        final token = value["token"];
        print("token:${token},登录成功12");
        MyLocalStorage.putData("token", token).then((value1) {
          CurrentUser.updateUser().then((value) {
            print("user:${value}");
            // 执行登录逻辑
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage()),
            );
          });
        });
      }).catchError((error) {
        DialogUtil.showError(context, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '账号',
                hintText: '请输入账号',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '账号不能为空';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '密码不能为空';
                }
                return null;
              },
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _captchaController,
                    decoration: InputDecoration(
                      labelText: '图形验证码',
                      hintText: '请输入图形验证码',
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return '验证码不能为空';
                      }
                      // 在此处添加验证码验证逻辑
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.0),
                ImageCaptcha(key: _imageCaptchaKey)
              ],
            ),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: loginHandler,
                  child: Text('登录'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 在此处添加注册逻辑
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text('注册'),
                ),
              ],
            ),
          ],
        ));
  }
}
