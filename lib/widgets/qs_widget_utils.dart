import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

LinearGradient imageCardGradientOverlay(Color primaryColor) {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.3, 0.6, 0.9],
    colors: [
      Colors.transparent,
      primaryColor.withOpacity(0.6),
      primaryColor.withOpacity(0.9),
      primaryColor,
    ],
  );
}
