import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_quick_start/theme/qs_context_ext.dart';

class Dimensions {
  static const defRadius = 16.0;
  static const cardRadius = Radius.circular(defRadius);
  static const headerRadius = Radius.circular(36);

  static const defPadding = 16.0;
  static const defPaddingHalf = defPadding / 2;
  static const defLargePadding = 24.0;
  static const musicBarHeight = 64.0;
  static const musicCoverRadiusSmall = 4.0;
  static const musicCoverRadiusBig = 24.0;

  static const upNextHeight = 48.0;
  static const upNextMinHeight = 56.0;

  static const settingsRowHeight = 64.0;

  static const roundedHeaderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      bottomLeft: headerRadius,
      bottomRight: headerRadius,
    ),
  );

  static double headerHeight(BuildContext context) {
    return 120.0;
  }

  static double headerWithImageHeight(BuildContext context) {
    return 400.0;
  }

  static double getUpNexHeight(BuildContext context) {
    return max(upNextMinHeight, upNextHeight + context.bottomInset);
  }
}
