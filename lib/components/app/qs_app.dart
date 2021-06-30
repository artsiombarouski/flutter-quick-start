import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QsAppParams {
  final Key? key;

  /// {@macro flutter.widgets.widgetsApp.home}
  final Widget? home;

  final ThemeData? theme;

  /// {@macro flutter.widgets.widgetsApp.initialRoute}
  final String? initialRoute;

  /// {@macro flutter.widgets.widgetsApp.onGenerateRoute}
  final RouteFactory? onGenerateRoute;

  /// {@macro flutter.widgets.widgetsApp.navigatorObservers}
  final List<NavigatorObserver>? navigatorObservers;

  QsAppParams({
    this.key,
    this.home,
    this.theme,
    this.initialRoute,
    this.onGenerateRoute,
    this.navigatorObservers,
  });
}

class QsApp extends StatefulWidget {
  final QsAppParams params;

  const QsApp({Key? key, required this.params}) : super(key: key);

  @override
  QsAppState createState() => QsAppState();

  static QsAppState of(BuildContext context) {
    QsAppState? appState = context.findRootAncestorStateOfType<QsAppState>();

    assert(() {
      if (appState == null) {
        throw FlutterError('QsApp not found');
      }
      return true;
    }());
    return appState!;
  }

  static NavigatorState navigator(BuildContext context, {bool root = true}) {
    if (root) {
      return of(context).navigatorKey.currentState!;
    } else {
      return Navigator.of(context);
    }
  }
}

class QsAppState extends State<QsApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: widget.params.key,
      home: widget.params.home,
      theme: widget.params.theme,
      navigatorKey: navigatorKey,
      initialRoute: widget.params.initialRoute,
      onGenerateRoute: widget.params.onGenerateRoute,
      navigatorObservers: [
        if(widget.params.navigatorObservers != null)
          ...widget.params.navigatorObservers!,
      ],
    );
  }
}
