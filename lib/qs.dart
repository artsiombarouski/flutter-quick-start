import 'package:flutter/foundation.dart';

import 'configs/qs_config.dart'
    if (dart.library.html) 'configs/qs_config.web.dart';

class Qs {
  static Future<void> init() async {
    configureApp();
  }
}

final kIsMobile = defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android;
