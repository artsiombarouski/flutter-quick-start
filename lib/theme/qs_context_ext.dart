import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension BuildContextExt on BuildContext {
  Color get canvasColor => Theme.of(this).canvasColor;

  Color get primaryColor => Theme.of(this).primaryColor;

  Color get backgroundColor => Theme.of(this).backgroundColor;

  Color get bottomAppBarColor => Theme.of(this).bottomAppBarColor;

  TextStyle get headline1 => Theme.of(this).textTheme.headline1!;

  TextStyle get headline2 => Theme.of(this).textTheme.headline2!;

  TextStyle get headline3 => Theme.of(this).textTheme.headline3!;

  TextStyle get headline4 => Theme.of(this).textTheme.headline4!;

  TextStyle get headline5 => Theme.of(this).textTheme.headline5!;

  TextStyle get headline6 => Theme.of(this).textTheme.headline6!;

  TextStyle get caption => Theme.of(this).textTheme.caption!;

  TextStyle get overline => Theme.of(this).textTheme.overline!;

  TextStyle get bodyText1 => Theme.of(this).textTheme.bodyText1!;

  TextStyle get bodyText2 => Theme.of(this).textTheme.bodyText2!;

  double get bottomInset => MediaQuery.of(this).padding.bottom;
}
