import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:boot_chat_fe/component/my_http_client.dart';

class ImageCaptcha extends StatefulWidget {
  const ImageCaptcha({super.key});

  @override
  ImageCaptchaState createState() => ImageCaptchaState();
}

class ImageCaptchaState extends State<ImageCaptcha> {
  late Future<String> _imageFuture;
  final _random = Random();
  String captchaKey = '';

  @override
  void initState() {
    super.initState();
    refreshImage();
  }

  void refreshImage() {
    setState(() {
      _imageFuture = _fetchImage();
    });
  }

  Future<String> _fetchImage() async {
    final response = await MyHttpClient.getNoToken(
        "/api/captcha/img?r=" + _random.nextDouble().toString());
    final img = response['img'] as String;
    captchaKey = response['verKey'];
    return img;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        refreshImage();
      },
      child: FutureBuilder<String>(
        future: _imageFuture,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final imageData =
                snapshot.data!.substring(snapshot.data!.indexOf(',') + 1);
            return Image.memory(
              base64Decode(imageData),
              fit: BoxFit.cover,
            );
          } else {
            return Text('No image data');
          }
        },
      ),
    );
  }
}
