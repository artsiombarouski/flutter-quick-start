import 'package:flutter/widgets.dart';
import 'package:flutter_quick_start/components/navigation/qs_navigation.dart';

typedef Widget QsPageBuilder(
  QsNavigationBuilderParams params,
  RouteSettings settings,
);

class QsNavigationPage {
  final String path;
  final QsPageBuilder? builder;
  final String? title;
  final Widget? icon;
  final String? name;

  QsNavigationPage(this.path, {this.builder, this.title, this.icon, this.name});
}
