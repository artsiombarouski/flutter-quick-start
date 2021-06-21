
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterQuickStart {
  static const MethodChannel _channel =
      const MethodChannel('flutter_quick_start');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
