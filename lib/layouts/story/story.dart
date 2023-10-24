import 'dart:convert';

import 'package:memeland/Helper/sizeConfig.dart';
import 'package:memeland/global/global.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dashed_circle/dashed_circle.dart';
import 'package:memeland/layouts/story/store_page_view.dart';
import 'package:memeland/models/getStoryModal.dart';

class Product {
  int id;
  String title;
  String image;
  String description;

  Product({this.id, this.title, this.image, this.description});
}

class InstaStories extends StatefulWidget {
  @override
  _InstaStoriesState createState() => _InstaStoriesState();
}

class _InstaStoriesState extends State<InstaStories>
    with SingleTickerProviderStateMixin {
  Animation gap;
  Animation base;
  Animation reverse;
  AnimationController controller;

  GetStoryModal modal;
  bool isLoading = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getPost();

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    base = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    reverse = Tween<double>(begin: .0, end: -1.0).animate(base);
    gap = Tween<double>(begin: 5, end: 1.0).animate(base)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  _getPost() async {
    setState(() {
      isLoading = true;
    });
    var uri = Uri.parse('${baseUrl()}/get_story_by_user');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    modal = GetStoryModal.fromJson(userData);
    print(responseData);
    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  // List<Product> products = [
  //   Product(
  //       id: 1,
  //       title: 'Item 1',
  //       image:
  //           'https://images.unsplash.com/photo-1511447333015-45b65e60f6d5?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2023&q=80',
  //       description: 'some text'),
  //   Product(
  //       id: 2,
  //       title: 'Item 2',
  //       image:
  //           'https://images.unsplash.com/photo-1511447333015-45b65e60f6d5?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2023&q=80',
  //       description: 'some text'),
  //   Product(
  //       id: 3,
  //       title: 'Item 3',
  //       image:
  //           'https://images.unsplash.com/photo-1511447333015-45b65e60f6d5?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2023&q=80',
  //       description: 'some text'),
  //   Product(
  //       id: 4,
  //       title: 'Item 4',
  //       image:
  //           'https://images.unsplash.com/photo-1511447333015-45b65e60f6d5?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2023&q=80',
  //       description: 'some text'),
  // ];

  // var images = [
  //   "https://images.unsplash.com/photo-1511447333015-45b65e60f6d5?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2023&q=80",
  //   "https://images.unsplash.com/photo-1511447333015-45b65e60f6d5?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2023&q=80",
  //   "https://images.unsplash.com/photo-1511447333015-45b65e60f6d5?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2023&q=80"
  // ].toString();

  @override
  Widget build(BuildContext context) {
    return _userInfo();
  }

  Widget _userInfo() {
    return isLoading
        ? Container(
            // width: SizeConfig.screenWidth,
            // child: Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Padding(
            //       padding: EdgeInsets.only(
            //         bottom: getProportionateScreenWidth(20),
            //       ),
            //       child: CircularProgressIndicator(),
            //     ),
            //   ],
            // )
            )
        : Container(
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 0),
                scrollDirection: Axis.horizontal,
                itemCount: modal.post.length,
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  // String orderId = images[index].key;
                  String name = modal.post[index].username;
                  // List storyImage = [];
                  // storyImage.add(modal.post[index].allImage);
                  // String time = _orderList[index].time;

                  return Stack(
                    children: <Widget>[
                      // timeInfo(orderId, index, time),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              List listImage = [];
                              for (var i = 0;
                                  i < modal.post[index].storyImage.length;
                                  i++) {
                                listImage.add(modal.post[index].storyImage[i]);
                              }
                              print(json.encode(listImage));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StoryPageView(images: listImage)),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  child: RotationTransition(
                                    turns: base,
                                    child: DashedCircle(
                                      gapSize: 3,
                                      strokeWidth: 10,
                                      dashes:
                                          modal.post[index].storyImage.length,
                                      color: appColor,
                                      child: RotationTransition(
                                        turns: reverse,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: CircleAvatar(
                                            radius: 26.0,
                                            backgroundImage: NetworkImage(modal
                                                        .post[index]
                                                        .storyImage
                                                        .length >
                                                    0
                                                ? modal.post[index].profilePic
                                                : "https://www.nicepng.com/png/detail/136-1366211_group-of-10-guys-login-user-icon-png.png"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 7,
                                ),
                                Container(
                                  width: 65,
                                  padding: const EdgeInsets.only(top: 0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          );
  }

  Widget timeInfo(String orderId, int index, String time) {
    var startTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    var currentTime = DateTime.now();
    int diff = currentTime.difference(startTime).inDays;

    // if (diff >= 1) {
    //   deleteOrder(orderId, index);
    // }

    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + diff.toString());

    return Text("");
  }
}
