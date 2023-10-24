import 'dart:convert';

import 'package:memeland/storyPlugin/story_view.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class StoryPageView extends StatelessWidget {
  List images;

  StoryPageView({this.images});

  @override
  Widget build(BuildContext context) {
    print('******************STORY LIST********************');
    print(json.encode(images));
    final controller = StoryController();
    List<StoryItem> stories = [];

    // for (var value in images) {
    //   stories.add(
    //     StoryItem.pageImage(
    //         shown: true,
    //         controller: controller,
    //         url: value,
    //         imageFit: BoxFit.contain
    //         //caption: "",
    //         ),
    //   );
    // }

    for (var value in images) {
      if (value.type == "image") {
        stories.add(
          StoryItem.pageImage(
            controller: controller,
            url: value.url,
            duration: Duration(seconds: 5),
            shown: true,
            imageFit: BoxFit.contain,
          ),
        );
      } else {
        stories.add(StoryItem.pageVideo(value.url,
            controller: controller,
            shown: true,
            duration: Duration(seconds: 10)));
      }
    }

    // stories.add(
    //   StoryItem.pageImage(
    //     controller: null, url: images,
    //     //caption: "",
    //   ),
    // );

    // final List<StoryItem> storyItems = [

    //   StoryItem.pageImage(NetworkImage(images)),

    // ];

    return Material(
      child: Stack(
        children: <Widget>[
          StoryView(
              storyItems: stories,
              controller: controller,
              inline: false,
              repeat: false,
              onComplete: () {
                controller.pause();
                Navigator.pop(context);
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  controller.pause();
                  Navigator.pop(context);
                }
              }),
          // Padding(
          //   padding: const EdgeInsets.only(top: 35),
          //   child: IconButton(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     icon: Icon(
          //       Icons.close,
          //       color: Colors.white,
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  // _back(Build) {
  //   Navigator.pop(context);
  // }
}
