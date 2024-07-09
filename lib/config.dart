import 'package:flutter/foundation.dart' show kDebugMode;

import 'config/config_dev.dart' if (kDebugMode) 'config/config_prod.dart';

class ChatConfig {
  static const String baseUrl = Config.baseUrl;
  //static const String wsBaseUrl = Config.wsBaseUrl;
}
