import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String? hexColor, {Color fallback = Colors.red}) {
    if (hexColor == null) {
      return fallback.value;
    }
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String? hexColor, {Color fallback = Colors.red})
      : super(_getColorFromHex(hexColor, fallback: fallback));
}
