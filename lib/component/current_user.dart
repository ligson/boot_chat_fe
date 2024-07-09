import 'dart:convert';

import 'package:synchronized/synchronized.dart';
import 'package:boot_chat_fe/component/my_http_client.dart';
import 'package:boot_chat_fe/component/local_storage.dart';
import 'package:boot_chat_fe/models/user.dart';

class CurrentUser {
  static User? _currentUser = null;
  static final _lock = Lock();

  static Future<User> updateUser() async {
    return MyHttpClient.post("/api/user/me", {}).then((value) {
      var user = value["user"];
      _lock.synchronized(() {
        MyLocalStorage.putData("user", jsonEncode(user));
        _currentUser = User(
            id: user["id"],
            name: user["name"],
            code: user["code"],
            email: user["email"]);
      });
      return Future.value(_currentUser);
    });
  }

  static User? currentUser() {
    return _currentUser;
  }
}
