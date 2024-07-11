import 'package:boot_chat_fe/component/page_navigator.dart';
import 'package:flutter/material.dart';

import '../component/local_storage.dart';
import '../component/my_http_client.dart';
import 'chat_page/chat_page.dart';
import 'login/LoginPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              leading: null,
              title: Center(
                child: Text("Ai智能运维客服"),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (String value) {
                    // 根据选择的值执行操作
                    switch (value) {
                      case 'logout':
                        MyHttpClient.post("/api/login/logout", {})
                            .then((value) {
                          print(value);
                          MyLocalStorage.removeData("token").then((value) {
                            PageNavigator.naviateToPage(context, LoginPage());
                          });
                        }).catchError((error) {
                          print(error);
                        });
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'logout',
                      // icon: Icon(Icons.logout),
                      child: Text('退出登录'),
                    ),
                  ],
                )
                // IconButton(
                //   icon: Icon(Icons.add_circle_outline),
                //   onPressed: () {
                //     MyHttpClient.post("/api/login/logout", {}).then((value) {
                //       print(value);
                //       MyLocalStorage.removeData("token").then((value) {
                //         PageNavigator.naviateToPage(context, LoginPage());
                //       });
                //     }).catchError((error) {
                //       print(error);
                //     });
                //   },
                // )
              ],
            ),
            body: ChatPage()));
  }
}
