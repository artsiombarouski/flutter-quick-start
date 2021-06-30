import 'package:flutter/material.dart';
import 'package:flutter_quick_start/components/app/qs_app.dart';
import 'package:flutter_quick_start/components/navigation/qs_navigation.dart';
import 'package:flutter_quick_start/qs.dart';
import 'package:flutter_quick_start/services/audio_player/audio_player_service.dart';
import 'package:flutter_quick_start/services/audio_player/just_audio_service.dart';
import 'package:flutter_quick_start/widgets/qs_sliver.dart';
import 'package:flutter_quick_start/widgets/qs_svg.dart';
import 'package:flutter_quick_start_example/player_example.dart';

final audioService = AudioPlayerService(provider: JustAudioProvider());

void main() async {
  await Qs.init();
  await audioService.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return QsApp(
      params: QsAppParams(
        onGenerateRoute: (settings) {
          if (settings.name == '/test') {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => TestRootNavigationPage(),
            );
          }
          if (settings.name == '/player') {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => PlayerExample(),
            );
          }
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => RootPage(),
          );
        },
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QsNavigationLayout(
        params: QsNavigationLayoutParams(
          pages: [
            QsNavigationPage(
              '/home',
              builder: (params, settings) => TempListPage(),
              title: 'Home',
              icon: Icon(Icons.home),
            ),
            QsNavigationPage(
              '/deals',
              builder: (params, settings) => IndexedPage(index: 1),
              title: 'Deals',
              icon: Icon(Icons.home),
            ),
            QsNavigationPage(
              '/favorites',
              builder: (params, settings) => IndexedPage(index: 2),
              title: 'Favourites',
              icon: Icon(Icons.home),
            ),
            QsNavigationPage(
              '/profile',
              builder: (params, settings) => IndexedPage(index: 3),
              title: 'Profile',
              icon: Icon(Icons.home),
            ),
          ],
          appBarBuilder: SimpleQsNavigationAppBarBuilder(),
          navigationBarBuilder: SimpleQsNavigationBarBuilder(),
          navigationDrawerBuilder: SimpleQsNavigationDrawerBuilder(),
          overflowChildrenBuilder: AppOverflowElementsBuilder(),
          navigationPageBuilder: (params, settings) {
            if (settings.name?.startsWith('/details') == true) {
              var uri = Uri.parse(settings.name!);
              return InnerPage(index: int.parse(uri.queryParameters['id']!));
            }
            return null;
          },
        ),
      ),
    );
  }
}

class AppOverflowElementsBuilder extends QsOverflowChildrenBuilder {
  @override
  List<Widget>? build(QsNavigationBuilderParams params) {
    return [
      Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {},
        ),
      ),
    ];
  }
}

class TempListPage extends StatelessWidget {
  const TempListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        sliverBox(
          TextButton(
            onPressed: () => QsApp.navigator(context).pushNamed("/player"),
            child: Text('Player'),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/details?id=$index');
              },
              child: Container(
                height: 200,
                child: assetSvg('assets/test_svg.svg'),
              ),
            ),
            childCount: 20,
          ),
        )
      ],
    );
  }
}

class IndexedPage extends StatelessWidget {
  final int index;

  const IndexedPage({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        child: Text("Page #$index"),
        onTap: () {
          QsApp.navigator(context).pushNamed('/test');
        },
      ),
    );
  }
}

class InnerPage extends StatelessWidget {
  final int index;

  const InnerPage({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Center(
        child: InkWell(
          child: Text("Page #$index"),
          onTap: () {
            QsApp.navigator(context).pushNamed('/test');
          },
        ),
      ),
    );
  }
}

class TestRootNavigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Center(
          child: Text("Test page"),
        ),
      ),
    );
  }
}
