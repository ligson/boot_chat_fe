import 'dart:async';
import 'dart:convert';

import 'package:boot_chat_fe/config.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class MyHttpClient {
  static final Dio _dio = _init();

  static Dio _init() {
    Dio dio = Dio();
    return dio;
  }

  static Future<dynamic> request(String method, String url, bool containToken,
      {dynamic data}) async {
    String reqUrl = ChatConfig.baseUrl + url;
    if (url.startsWith("http")) {
      reqUrl = url;
    }
    print("访问 URL:" + reqUrl);
    Map<String, String> headers = {};
    if (containToken) {
      //String? token = await MyLocalStorage.getData("token");
      //print("token:${token}");
      //if (token != null) {
      headers["Authorization"] = "ok";
      //}
    }
    return _dio
        .request(reqUrl,
            data: data, options: Options(method: method, headers: headers))
        .then((Response<dynamic> value) {
      dynamic returnData = value.data;
      if (returnData["success"]) {
        //print("biz success:${value}");
        return Future.value(returnData["data"]);
      } else {
        print("biz error:${value}");
        if (returnData["errorType"] == "Business") {
          return Future.error(returnData["errorMsg"]);
        } else {
          return Future.error("内部错误");
        }
      }
    }).catchError((error) {
      print("network error:${error}");
      if (!(error is String)) {
        dynamic returnData;
        if (error.response != null) {
          returnData = error.response.data;
        } else {
          returnData = error.data;
        }

        if (!returnData['success']) {
          if (returnData["errorType"] == "Business") {
            return Future.error(returnData["errorMsg"]);
          } else {
            return Future.error("内部错误");
          }
        }
      }
      //return Future.error("内部错误");
      return Future.error(error);
    });
  }

  static Future<dynamic> get(String url) async {
    return request('GET', url, true);
  }

  static Future<dynamic> getNoToken(String url) async {
    return request('GET', url, false);
  }

  static Future<dynamic> post(String url, dynamic data) async {
    return request('POST', url, true, data: data);
  }

  static Future<dynamic> postNoToken(String url, dynamic data) async {
    return request('POST', url, false, data: data);
  }

  static Future<dynamic> uploadFile(http.MultipartFile file, String url) async {
    String reqUrl = ChatConfig.baseUrl + url;
    if (url.startsWith("http")) {
      reqUrl = url;
    }
    print("访问 URL:" + reqUrl);
    Map<String, String> headers = {};
    //String? token = await MyLocalStorage.getData("token");
    //print("token:${token}");
    //if (token != null) {
    //headers["Authorization"] = token;
    //}
    var request = http.MultipartRequest('POST', Uri.parse(reqUrl));
    request.headers.addAll(headers);
    request.files.add(file);
    Completer<dynamic> completer = Completer<dynamic>();

    request.send().then((value) {
      value.stream.transform(utf8.decoder).listen((event) {
        var jsonData = json.decode(event);
        print(value);
        if (jsonData["success"]) {
          //print("biz success:${value}");
          completer.complete(jsonData["data"]);
        } else {
          print("biz error:${value}");
          if (jsonData["errorType"] == "Business") {
            completer.completeError(jsonData["errorMsg"]);
          } else {
            completer.completeError("内部错误");
          }
        }
      });
    }).catchError((err) {
      print(err);
      completer.completeError(err);
    });
    return completer.future;
  }
}
