import 'package:flutter/cupertino.dart';

Widget sliverBox(Widget child) {
  return SliverToBoxAdapter(child: child);
}
