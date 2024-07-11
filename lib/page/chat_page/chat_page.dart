import 'dart:convert';
import 'dart:io';

import 'package:boot_chat_fe/component/my_http_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> _chatHistory = [];

  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '38c16ab22ecb4f97b6cbf5908b57233a',
  );
  late var _lastAnswer = "";

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    _addMessage(textMessage);
    print("message: $textMessage");
    final chatmsg = {"lastAnswer": _lastAnswer, "problem": message.text};
    final response =
        await MyHttpClient.postStream("/qianfan/ai/generateStream", chatmsg);

    final stream =
        response.stream.transform(utf8.decoder).transform(LineSplitter());
    List<String> eventDataList = [];
    stream.listen(
      (event) {
        if (event.startsWith('data:')) {
          final data = event.substring(5); // 解析 SSE 数据
          print('Received event: $data');
          eventDataList.add(data); // 将数据添加到缓冲区
        }
      },
      onDone: () {
        // 处理最终结果
        print('Stream is done');
        try {
          var userId = '';
          StringBuffer buffer = StringBuffer();
          for (var data in eventDataList) {
            var jsonData = jsonDecode(data);
            var resultContent = jsonData['result']['output'];
            userId = resultContent['metadata']['id'];
            print('Result content: $resultContent');
            buffer.write(resultContent["content"]);
          }

          // 保存AI回复到聊天记录
          _chatHistory.add({"role": "assistant", "content": buffer.toString()});

          final resultMessage = types.TextMessage(
            author: types.User(
              id: userId,
            ),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: buffer.toString(),
          );
          _addMessage(resultMessage);
        } catch (e) {
          print('Error parsing JSON: $e');
        }
      },
      onError: (error) {
        print('Stream error: $error');
      },
    );
  }

  void _loadMessages() async {
    MyHttpClient.post("/api/msg/findByUserId", {}).then((value) {
      for (int i = 0; i < value["data"].length; i++) {
        final msg = value["data"][i];
        print("msg:: " + i.toString() + "     " + msg["createTime"]);
        DateFormat inputForma = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");

        if (msg["role"] == "user") {
          final textMessage = types.TextMessage(
            author: _user,
            createdAt:
                inputForma.parse(msg["createTime"]).millisecondsSinceEpoch,
            id: msg["id"],
            text: msg["msg"],
          );
          _addMessage(textMessage);
        } else {
          _lastAnswer = msg["msg"];
          final textMessage = types.TextMessage(
            author: types.User(
                id: "4c2307ba-3d40-442f-b1ff-b271f63904ca", firstName: "Ai"),
            createdAt:
                inputForma.parse(msg["createTime"]).millisecondsSinceEpoch,
            id: msg["id"],
            text: msg["msg"],
          );
          _addMessage(textMessage);
        }
      }
    });
    // final response = await rootBundle.loadString('assets/messages.json');
    // final messages = (jsonDecode(response) as List)
    //     .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
    //     .toList();

    setState(() {
      // _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          onAttachmentPressed: _handleAttachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
        ),
      );
}
