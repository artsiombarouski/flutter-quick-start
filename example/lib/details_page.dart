import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("details")),
      body: Center(
        child: Text("Test"),
      ),
    );
  }
}
