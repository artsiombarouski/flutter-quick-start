import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

enum QsNavigationType { Mobile, Desktop }

QsNavigationType resolveNavigationType(BuildContext context, Size screenSize) {
  if (kIsWeb && screenSize.width > 700) {
    return QsNavigationType.Desktop;
  }
  return QsNavigationType.Mobile;
}

EdgeInsets resolveAdaptivePadding(BuildContext context, Size screenSize) {
  if (kIsWeb && screenSize.width > 1200) {
    return EdgeInsets.symmetric(horizontal: 48);
  }
  return EdgeInsets.zero;
}
