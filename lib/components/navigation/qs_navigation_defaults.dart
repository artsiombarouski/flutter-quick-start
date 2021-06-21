import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quick_start/components/navigation/qs_navigation.dart';

class SimpleQsNavigationAppBarBuilder extends QsNavigationAppBarBuilder {
  @override
  Widget? build(QsNavigationBuilderParams params) {
    return SliverAppBar(
      title: Text("Test"),
    );
  }
}

class SimpleQsNavigationBarBuilder extends QsNavigationBarBuilder {
  @override
  Widget? build(
    QsNavigationBuilderParams params,
    ValueChanged<String> callback,
  ) {
    final pages = params.layoutParams?.pages;
    return BottomNavigationBar(
      currentIndex:
          pages?.indexWhere((element) => element.path == params.currentPage) ??
              0,
      onTap: (index) => callback(pages![index].path),
      items: [
        if (pages != null)
          ...pages.map((e) => BottomNavigationBarItem(
                icon: e.icon!,
                label: e.title,
              )),
      ],
    );
  }
}

class SimpleQsNavigationDrawerBuilder extends QsNavigationDrawerBuilder {
  @override
  Widget? build(
    QsNavigationBuilderParams params,
    ValueChanged<String> callback,
  ) {
    final pages = params.layoutParams?.pages;
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Drawer Header'),
        ),
        if (pages != null)
          ...pages.map(
            (e) => ListTile(
              leading: e.icon,
              title: Text(e.title ?? ''),
              selected: e.path == params.currentPage,
              onTap: () {
                callback(e.path);
              },
            ),
          ),
      ],
    );
  }
}
