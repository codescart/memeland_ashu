import 'package:flutter/material.dart';
import 'package:memeland/layouts/chat/chat_list.dart';
import 'package:memeland/layouts/homefeeds.dart';
import 'package:memeland/layouts/post/add_post/photo.dart';
import 'package:memeland/layouts/search/search_new.dart';
import 'package:memeland/layouts/tabbar/new_tabbar.dart';
import 'package:memeland/layouts/user/profile.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      // case '/Debug':
      //   return MaterialPageRoute(
      //       builder: (_) => DebugWidget(routeArgument: args as RouteArgument));
      case '/Home':
        return MaterialPageRoute(builder: (_) => ImagesVideosFeeds());
      case '/Pages':
        return MaterialPageRoute(
            builder: (_) => BottomTabbar(currentTab: args));

      case '/Search':
        return MaterialPageRoute(builder: (_) => SerchFeed());
      case '/Uploadpost':
        return MaterialPageRoute(builder: (_) => PhotoScreen());
      case '/Chat':
        return MaterialPageRoute(builder: (_) => ChatList());
      case '/Profile':
        return MaterialPageRoute(builder: (_) => Profile());

      default:
        // If there is no such named route in the switch statement, e.g. /third
        return MaterialPageRoute(builder: (_) => ImagesVideosFeeds());
    }
  }

  // ignore: unused_element
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
