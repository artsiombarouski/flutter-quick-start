import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quick_start/components/navigation/qs_navigation_page.dart';
import 'package:flutter_quick_start/components/navigation/qs_navigation_type.dart';
import 'package:flutter_quick_start/qs.dart';
import 'package:page_transition/page_transition.dart';

/// Builders

abstract class QsNavigationAppBarBuilder {
  Widget? build(QsNavigationBuilderParams params);

  void initState() {}

  void dispose() {}
}

abstract class QsNavigationBarBuilder {
  Widget? build(
    QsNavigationBuilderParams params,
    ValueChanged<String> callback,
  );

  void initState() {}

  void dispose() {}
}

abstract class QsNavigationDrawerBuilder {
  Widget? build(
    QsNavigationBuilderParams params,
    ValueChanged<String> callback,
  );

  void initState() {}

  void dispose() {}
}

abstract class QsOverflowChildrenBuilder {
  List<Widget>? build(QsNavigationBuilderParams params);

  void initState() {}

  void dispose() {}
}

typedef Widget? QsNavigationPageBuilder(
  QsNavigationBuilderParams params,
  RouteSettings settings,
);

/// Params

class QsNavigationLayoutParams {
  final List<QsNavigationPage> pages;
  final String? initialPage;
  final QsNavigationType? type;
  final QsNavigationAppBarBuilder? appBarBuilder;
  final QsNavigationBarBuilder? navigationBarBuilder;
  final QsNavigationDrawerBuilder? navigationDrawerBuilder;
  final QsNavigationPageBuilder? navigationPageBuilder;
  final QsOverflowChildrenBuilder? overflowChildrenBuilder;

  QsNavigationLayoutParams({
    required this.pages,
    this.initialPage,
    this.type,
    this.appBarBuilder,
    this.navigationBarBuilder,
    this.navigationPageBuilder,
    this.navigationDrawerBuilder,
    this.overflowChildrenBuilder,
  });
}

class QsNavigationBuilderParams {
  final BuildContext context;
  final Size screenSize;
  final QsNavigationType type;
  final String? currentPage;
  final QsNavigationLayoutParams? layoutParams;

  QsNavigationBuilderParams({
    required this.context,
    required this.screenSize,
    required this.type,
    this.currentPage,
    this.layoutParams,
  });
}

class QsNavigationLayout extends StatefulWidget {
  final QsNavigationLayoutParams? params;

  const QsNavigationLayout({Key? key, this.params}) : super(key: key);

  @override
  _QsNavigationLayoutState createState() => _QsNavigationLayoutState();
}

class QsNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> _routeStack = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    _routeStack.add(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _routeStack.removeLast();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _routeStack.removeLast();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _routeStack.removeLast();
      _routeStack.add(newRoute);
    }
  }
}

class _QsNavigationLayoutState extends State<QsNavigationLayout> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  final QsNavigatorObserver _navigatorObserver = QsNavigatorObserver();
  String? _currentPage;

  @override
  void initState() {
    _currentPage = widget.params?.initialPage ?? widget.params?.pages[0].path;
    widget.params?.appBarBuilder?.initState();
    widget.params?.navigationBarBuilder?.initState();
    widget.params?.navigationDrawerBuilder?.initState();
    widget.params?.overflowChildrenBuilder?.initState();
    super.initState();
  }

  @override
  void dispose() {
    widget.params?.appBarBuilder?.dispose();
    widget.params?.navigationBarBuilder?.dispose();
    widget.params?.navigationDrawerBuilder?.dispose();
    widget.params?.overflowChildrenBuilder?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant QsNavigationLayout oldWidget) {
    if (widget.params?.initialPage != null &&
        widget.params?.initialPage != _currentPage) {
      _updatePage(widget.params!.initialPage!);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updatePage(String path) {
    setState(() {
      _currentPage = path;
      _navigatorKey.currentState?.pushReplacementNamed(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final type =
        widget.params?.type ?? resolveNavigationType(context, screenSize);
    final builderParams = QsNavigationBuilderParams(
      context: context,
      screenSize: screenSize,
      type: type,
      currentPage: _currentPage,
      layoutParams: widget.params,
    );

    final appBar = widget.params?.appBarBuilder?.build(
      builderParams,
    );
    final navigationBar = widget.params?.navigationBarBuilder?.build(
      builderParams,
      _updatePage,
    );
    final overflow = widget.params?.overflowChildrenBuilder?.build(
      builderParams,
    );

    final content = NestedScrollView(
      body: Navigator(
        key: _navigatorKey,
        initialRoute: _currentPage,
        observers: [_navigatorObserver],
        onGenerateRoute: (RouteSettings settings) {
          Widget? targetPage = widget.params?.pages
              .firstWhereOrNull((element) => settings.name == element.path)
              ?.builder
              ?.call(builderParams, settings);
          final isRootNavigationPage = targetPage != null;
          if (targetPage == null) {
            targetPage = widget.params?.navigationPageBuilder
                ?.call(builderParams, settings);
          }
          if (targetPage != null) {
            if (kIsMobile && !isRootNavigationPage) {
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => targetPage!,
              );
            }
            return PageTransition(
              settings: settings,
              type: PageTransitionType.fade,
              child: targetPage,
            );
          }
          return null;
        },
      ),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          if (appBar != null) appBar,
        ];
      },
    );

    final Widget body;
    if (type == QsNavigationType.Desktop) {
      final drawerNavigation = widget.params?.navigationDrawerBuilder?.build(
        builderParams,
        _updatePage,
      );
      body = Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 1200),
          child: Row(
            children: [
              if (drawerNavigation != null)
                Expanded(
                  flex: 1,
                  child: drawerNavigation,
                ),
              Expanded(
                flex: 2,
                child: content,
              ),
            ],
          ),
        ),
      );
    } else {
      body = content;
    }

    return Stack(
      children: [
        body,
        if (overflow != null)
          Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: 1200),
              child: Stack(
                children: overflow,
              ),
            ),
          ),
        if (navigationBar != null && type == QsNavigationType.Mobile)
          Align(
            alignment: Alignment.bottomCenter,
            child: navigationBar,
          ),
      ],
    );
  }
}
