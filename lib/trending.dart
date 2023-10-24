import 'package:flutter/material.dart';


class Trending extends StatelessWidget {

  final GlobalKey<ScaffoldState> parentScaffoldKey;
  Trending({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Image.network("https://memberpress.com/wp-content/uploads/2020/12/coming-soon-page.jpg")
      ),
    );
  }
}
