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

  QsAppParams({
    this.key,
    this.home,
    this.theme,
    this.initialRoute,
    this.onGenerateRoute,
  });
}

class QsApp extends StatefulWidget {
  final QsAppParams params;

  const QsApp({Key? key, required this.params}) : super(key: key);

  @override
  _QsAppState createState() => _QsAppState();

  static NavigatorState rootNavigator(BuildContext context) {
    _QsAppState? appState = context.findRootAncestorStateOfType<_QsAppState>();

    assert(() {
      if (appState == null) {
        throw FlutterError('QsApp not found');
      }
      return true;
    }());
    return appState!.navigatorKey.currentState!;
  }
}

class _QsAppState extends State<QsApp> {
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
    );
  }
}
