import 'dart:async';
import 'dart:convert';

import 'package:memeland/global/global.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:http/http.dart' as http;

import 'package:inview_notifier_list/inview_notifier_list.dart';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:memeland/layouts/post/comments.dart';
import 'package:memeland/layouts/user/profile.dart';
import 'package:memeland/layouts/user/publicProfile.dart';
import 'package:memeland/layouts/videoview/videoViewFix.dart';
import 'package:memeland/layouts/widgets/DrawerWidget.dart';
import 'package:memeland/models/get_bookmarks_model.dart';
import 'package:memeland/models/likeModal.dart';
import 'package:memeland/models/unlikeModal.dart';

import 'package:timeago/timeago.dart';
import 'package:video_player/video_player.dart';

class SavedBookmarks extends StatefulWidget {
  @override
  _SavedBookmarksState createState() => _SavedBookmarksState();
}

class _SavedBookmarksState extends State<SavedBookmarks>
    with SingleTickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;

  UnlikeModal unlikeModal;

  bool refresh = false;

  LikeModal likeModal;
  VideoPlayerController controller1;
  bool tap = false;
  GetBookMarksModel getBookMarksModel;

  @override
  void initState() {
    _getPost();

    super.initState();
  }

  // @override
  // void dispose() {
  //   controller1.dispose();
  //   super.dispose();
  // }

  _getPost() async {
    if (refresh != true) {
      setState(() {
        isLoading = true;
      });
    }

    var uri = Uri.parse('${baseUrl()}/get_user_bookmark_post');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userDataRecent = json.decode(responseData);

    print("RESPONSE OF RECENT POST : $responseData");

    setState(() {
      getBookMarksModel = GetBookMarksModel.fromJson(userDataRecent);
      isLoading = false;
    });
  }

  _unlikePost(String postid) async {
    // setState(() {
    //   isLoading = true;
    // });
    var uri = Uri.parse('${baseUrl()}/unlike_post');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['post_id'] = postid;
    request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    unlikeModal = UnlikeModal.fromJson(userData);
    print(responseData);

    if (unlikeModal.responseCode == "1") {
      likedPost = [];
      setState(() {
        likedPost.add(postid);
      });
      // _getPost();
    }

    // setState(() {
    //   isLoading = false;
    // });
  }

  _likePost(String postid) async {
    // setState(() {
    //   isLoading = true;
    // });
    var uri = Uri.parse('${baseUrl()}/like_post');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['post_id'] = postid;
    request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    likeModal = LikeModal.fromJson(userData);
    print(responseData);

    if (likeModal.responseCode == "1") {
      likedPost = [];
      setState(() {
        likedPost.add(postid);
      });
      // _getPost();
    }

    // setState(() {
    //   isLoading = false;
    // });
  }

  // _addBookmark(String postid) async {
  //   // setState(() {
  //   //   isLoading = true;
  //   // });
  //   var uri = Uri.parse('${baseUrl()}/bookmark_post');
  //   var request = new http.MultipartRequest("POST", uri);
  //   Map<String, String> headers = {
  //     "Accept": "application/json",
  //   };
  //   request.headers.addAll(headers);
  //   request.fields['post_id'] = postid;
  //   request.fields['user_id'] = userID;
  //   var response = await request.send();
  //   print(response.statusCode);
  //   String responseData = await response.stream.transform(utf8.decoder).join();
  //   var userData = json.decode(responseData);

  //   print(responseData);

  //   if (userData['response_code'] == "1") {
  //     addedBookmarks = [];
  //     setState(() {
  //       addedBookmarks.add(postid);
  //     });
  //     // _getPost();
  //   }

  //   // setState(() {
  //   //   isLoading = false;
  //   // });
  // }

  _removeBookmark(String postid) async {
    // setState(() {
    //   isLoading = true;
    // });
    var uri = Uri.parse('${baseUrl()}/delete_bookmark_post');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['post_id'] = postid;
    request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    print(responseData);

    if (userData['response_code'] == "1") {
      addedBookmarks = [];
      setState(() {
        addedBookmarks.remove(postid);
        refresh = true;
        _getData();
      });
      // _getPost();
    }

    // setState(() {
    //   isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        key: scaffoldKey,
        drawer: DrawerWidget(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.5,
          title: Text(
            "Bookmarks",
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColorLight,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).primaryColorLight,
              )),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _body(context));
  }

  Widget _body(BuildContext context) {
    return CustomRefreshIndicator(
      child: Container(
        // height: SizeConfig.screenHeight,
        // width: SizeConfig.screenWidth,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: isLoading
              ? Center(
                  child: loader(context),
                )
              : getBookMarksModel != null && getBookMarksModel.post.length > 0
                  ? new InViewNotifierList(
                      itemCount: getBookMarksModel.post.length,
                      scrollDirection: Axis.vertical,

                      initialInViewIds: ['0'],
                      isInViewPortCondition: (double deltaTop,
                          double deltaBottom, double viewPortDimension) {
                        tap = true;
                        return deltaTop < (0.5 * viewPortDimension) &&
                            deltaBottom > (0.5 * viewPortDimension);
                      },
                      // reverse: true,
                      shrinkWrap: true,
                      builder: (context, index) {
                        return LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return InViewNotifierWidget(
                            id: '$index',
                            builder: (BuildContext context, bool isInView,
                                Widget child) {
                              return _bodyData(
                                  getBookMarksModel.post[index], isInView);
                            },
                          );
                        });
                      },
                    )
                  : Container(
                      width: SizeConfig.screenWidth,
                      height: MediaQuery.of(context).size.height * 8 / 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No Saved Bookmarks found!",
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 5,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2,
                          ),
                          Text(
                            "When you add bookmarks, they'll appear here",
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 3,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? appColorWhite.withOpacity(0.5)
                                    : Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
          //  Column(
          //   children: [
          //     post(),
          //   ],
          // ),
        ),
      ),
      onRefresh: _getData,
      builder:
          (BuildContext context, Widget child, IndicatorController controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, _) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                if (!controller.isIdle)
                  Column(
                    children: [
                      Container(
                          height: 40,
                          width: 40,
                          child: CupertinoActivityIndicator(
                            radius: 15,
                          ))
                    ],
                  ),
                Transform.translate(
                  offset: Offset(0, 100.0 * controller.value),
                  child: child,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _bodyData(Post post, bool isInView) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        onTap: () {
          if (userID == post.postUserId) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile(back: true)),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PublicProfile(
                        peerId: post.postUserId,
                        peerUrl: post.profilePic,
                        peerName: post.username,
                      )),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                post.profilePic == ""
                    ? Image.asset(
                        "assets/images/user.png",
                        height: 45,
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(post.profilePic),
                        radius: 25,
                      ),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal * 2,
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextStyle1(
                          title:
                              post.username == "" ? "No name" : post.username,
                          color: Theme.of(context).primaryColorLight,
                          fontsize: 16,
                          weight: FontWeight.w500,
                        ),
                        post.location != ''
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 02,
                                  ),
                                  Text(
                                    post.location,
                                    style: TextStyle(
                                        letterSpacing: 1,
                                        fontSize: 12,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? appColorWhite.withOpacity(0.5)
                                            : Colors.black45),
                                  ),
                                ],
                              )
                            : Container()
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 05),
              child: Text(
                format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(post.createDate)),
                    locale: 'en_short'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? appColorWhite.withOpacity(0.5)
                      : Colors.black45,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 10,
      ),
      SizedBox(
        height: 10,
      ),
      post.allImage.length > 0
          ? InkWell(
              onDoubleTap: () {
                if (post.isLikes == "false") {
                  setState(() {
                    post.dataV = true;
                    post.isLikes = "true";
                    post.totalLikes = post.totalLikes + 1;
                    _likePost(post.postId);
                  });
                  var _duration = new Duration(milliseconds: 500);
                  Timer(_duration, () {
                    post.dataV = false;
                  });
                  print('dataV : ${post.dataV}');
                }
              },
              child: Stack(
                children: [
                  Container(
                    height: SizeConfig.blockSizeVertical * 40,
                    width: SizeConfig.screenWidth,
                    child: Carousel(
                      images: post.allImage.map((it) {
                        return ClipRRect(
                          child: Container(
                            child: CachedNetworkImage(
                              imageUrl: it,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Center(
                                child: Container(
                                    // height: 40,
                                    // width: 40,
                                    child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                      showIndicator: post.allImage.length > 1 ? true : false,
                      dotBgColor: Colors.transparent,
                      borderRadius: false,
                      autoplay: false,
                      dotSize: 5.0,
                      dotSpacing: 15.0,
                    ),
                  ),
                  post.dataV == true
                      ? Positioned.fill(
                          child: AnimatedOpacity(
                              opacity: post.dataV ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 700),
                              child: Icon(
                                CupertinoIcons.heart_fill,
                                color: Colors.red,
                                size: 100,
                              )))
                      : Container(),
                ],
              ),
            )
          : post.video != ""
              ? post.dataV == false
                  ? Stack(
                      children: [
                        VideoViewFix(url: post.video, play: false, mute: false),
                        post.dataV == true
                            ? Positioned.fill(
                                child: AnimatedOpacity(
                                    opacity: post.dataV ? 1.0 : 0.0,
                                    duration: Duration(milliseconds: 700),
                                    child: Icon(
                                      CupertinoIcons.heart_fill,
                                      color: Colors.red,
                                      size: 100,
                                    )))
                            : Container(),
                      ],
                    )
                  : Stack(
                      children: [
                        VideoViewFix(
                            url: post.video, play: isInView, mute: false),
                        post.dataV == true
                            ? Positioned.fill(
                                child: AnimatedOpacity(
                                    opacity: post.dataV ? 1.0 : 0.0,
                                    duration: Duration(milliseconds: 700),
                                    child: Icon(
                                      CupertinoIcons.heart_fill,
                                      color: Colors.red,
                                      size: 100,
                                    )))
                            : Container(),
                      ],
                    )
              : Container(
                  height: 230,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image,
                    size: 200,
                    color: Colors.grey[600],
                  )),
      SizedBox(
        height: 10,
      ),
      post.text != ""
          ? Padding(
              padding: const EdgeInsets.only(left: 5),
              child: RichText(
                text: TextSpan(
                  text: post.username == "" ? "No name" : post.username,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 15,
                      fontFamily: 'Lato'),
                  children: <TextSpan>[
                    TextSpan(
                        text: '  ${post.text}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColorLight,
                            fontFamily: 'Lato')),
                  ],
                ),
              ))
          : Container(),
      Padding(
        padding: const EdgeInsets.only(left: 5, top: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // likedPost.contains(modal.post[index].postId)
                post.isLikes == "true"
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            post.isLikes = "false";
                            post.totalLikes = post.totalLikes - 1;
                            _unlikePost(post.postId);
                          });
                          print("Unlike Post");
                        },
                        child: Icon(
                          CupertinoIcons.heart_fill,
                          size: 30,
                          color: Colors.red,
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          print("Like Post");
                          setState(() {
                            post.totalLikes = post.totalLikes + 1;
                            post.isLikes = "true";
                            _likePost(post.postId);
                          });
                        },
                        child: Icon(
                          CupertinoIcons.heart,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? appColorWhite.withOpacity(0.5)
                              : Colors.black45,
                          size: 30,
                        ),
                      ),
                SizedBox(
                  width: 5,
                ),
                CustomTextStyle1(
                  title: '${post.totalLikes.toString()} Likes',
                  weight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? appColorWhite.withOpacity(0.5)
                      : Colors.black45,
                ),
                IconButton(
                    icon: Icon(
                      CupertinoIcons.chat_bubble_text,
                      size: 25,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? appColorWhite.withOpacity(0.5)
                          : Colors.black45,
                    ),
                    onPressed: () {
                      setState(() {
                        tap = false;
                        _body(context);
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CommentsScreen(postID: post.postId)),
                      );
                    }),
              ],
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    post.bookmark = "false";
                    // post.totalLikes = post.totalLikes - 1;
                    _removeBookmark(post.postId);
                  });
                  print("Unlike Post");
                },
                icon: Icon(
                  CupertinoIcons.bookmark_fill,
                  color: Colors.amber,
                ))
          ],
        ),
      ),
      SizedBox(
        height: 5,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 5),
        child: InkWell(
          onTap: () {
            setState(() {
              tap = false;
              _body(context);
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CommentsScreen(postID: post.postId)),
            );
          },
          child: CustomTextStyle1(
            title: "View all " + post.totalComments.toString() + " comments..",
            color: Theme.of(context).brightness == Brightness.dark
                ? appColorWhite.withOpacity(0.5)
                : Colors.black38,
            weight: FontWeight.w500,
          ),
        ),
      ),
      SizedBox(
        height: 25,
      )
    ]);
  }

  Future<void> _getData() async {
    setState(() {
      _getPost();
    });
  }
}
