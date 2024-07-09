import 'package:flutter/material.dart';
import 'package:boot_chat_fe/component/dialog_util.dart';
import 'package:boot_chat_fe/component/my_http_client.dart';
import 'package:boot_chat_fe/component/image_captcha.dart';

class RegisterForm extends StatefulWidget {
  @override
  RegisterFormState createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  TextEditingController _codeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _captchaController = TextEditingController();
  final GlobalKey<ImageCaptchaState> _imageCaptchaKey =
      GlobalKey<ImageCaptchaState>();
  // String? _selectedGender = '男'; // 默认选中男性

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void registerHandler() {
    if (_formKey.currentState?.validate() ?? true) {
      //FEMALE, MALE, THIRD
      // String sexValue = "FEMALE";
      // if (_selectedGender == "男") {
      //   sexValue = "FEMALE";
      // } else if (_selectedGender == "女") {
      //   sexValue = "MALE";
      // } else {
      //   sexValue = "THIRD";
      // }

      MyHttpClient.postNoToken("/api/register/by_pwd", {
        "code": _codeController.text,
        "name": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "captchaCode": _captchaController.text,
        "captchaKey": _imageCaptchaKey.currentState!.captchaKey
      }).then((value) {
        print("success:${value}");
        _formKey.currentState?.reset();
        DialogUtil.showMessage(context, "注册成功，请返回登录...");
      }).catchError((err) {
        DialogUtil.showError(context, err);
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
            controller: _codeController,
            decoration: InputDecoration(
              labelText: '用户名',
              hintText: '请输入用户名',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return '用户名不能为空';
              } else if (!RegExp(r'^[a-zA-Z0-9]{6,}$').hasMatch(value!)) {
                return '用户名必须由英文和数字组成，且最少6位';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: '昵称',
              hintText: '请输入昵称',
            ),
            // validator: (value) {
            //   if (value?.isEmpty ?? true) {
            //     return '邮箱不能为空';
            //   }
            //   return null;
            // },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: '邮箱',
              hintText: '请输入邮箱',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return '邮箱不能为空';
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
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return '密码不能为空';
              } else if (value == null || value.length < 8) {
                return '密码最少8位';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: '确认密码',
              hintText: '请再次输入密码',
            ),
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return '确认密码不能为空';
              } else if (value != _passwordController.text) {
                return '两次输入的密码不一致';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _captchaController,
                  decoration: InputDecoration(
                    labelText: '验证码',
                    hintText: '请输入验证码',
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
              ImageCaptcha(
                key: _imageCaptchaKey,
              ), // 这里可以替换成验证码图片
            ],
          ),
          // SizedBox(height: 16.0),
          // TextFormField(
          //   controller: _introductionController,
          //   maxLines: null,
          //   keyboardType: TextInputType.multiline,
          //   decoration: InputDecoration(
          //     labelText: '介绍',
          //     hintText: '请输入介绍',
          //   ),
          // ),
          SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: registerHandler,
            child: Text('注册'),
          ),
        ],
      ),
    );
  }
}
