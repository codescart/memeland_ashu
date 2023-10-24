import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memeland/global/global.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:memeland/layouts/filter/filterview.dart';
import 'package:memeland/layouts/notifications.dart';
import 'package:memeland/layouts/post/comments.dart';
import 'package:memeland/layouts/story/previewStory.dart';
import 'package:memeland/layouts/story/sendVideoStory.dart';
import 'package:memeland/layouts/story/story.dart';
import 'package:memeland/layouts/user/profile.dart';
import 'package:memeland/layouts/user/publicProfile.dart';
import 'package:memeland/layouts/videoview/videoViewFix.dart';
import 'package:memeland/layouts/zoom/zoomOverlay.dart';
import 'package:memeland/models/deleteStoryModal.dart';
import 'package:memeland/models/followerPostModal.dart';
import 'package:memeland/models/followersModal.dart';
import 'package:memeland/models/followingModal.dart';
import 'package:memeland/models/latest_model.dart';
import 'package:memeland/models/likeModal.dart';
import 'package:memeland/models/loginModal.dart';
import 'package:memeland/models/unlikeModal.dart';
import 'package:memeland/shared_preferences/preferencesKey.dart';

import 'package:timeago/timeago.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class ImagesVideosFeeds extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  ImagesVideosFeeds({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ImagesVideosFeedsState createState() => _ImagesVideosFeedsState();
}

class _ImagesVideosFeedsState extends State<ImagesVideosFeeds>
    with SingleTickerProviderStateMixin {
  Animation base;
  AnimationController controller;

  DeleteStoryModal deleteStoryModal;
  // @override
  // void dispose() {
  //   controller1.dispose();
  //   super.dispose();
  // }
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  FollowersModal followersModal;

  FollwingModal follwingModal;
  Animation gap;
  bool isLoading = false;
  LatestPostModel latestPostModel;
  LikeModal likeModal;
  LoginModal loginModal;
  FollowerPostModal modal;
  Animation reverse;
  int page = 1;
  bool show = false;
  // bool tap = true;
  UnlikeModal unlikeModal;
  bool pageloader = false;
  // ignore: unused_field
  double _height, _width, _fixedPadding;
  // ignore: unused_field
  int _current = 0;
  LoginModal loginModel;
  @override
  void initState() {
    print(userID);
    // _getRecentPost();
    globleFollowers = [];
    globleFollowing = [];
    getUserDataFromPrefs().then((value) => this._getPost(page));

    // this._getPost(page);
    initialiZeController();

    _getFollowers(userID);
    _getFollowing(userID);
    // getUserDataFromPrefs();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    base = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    reverse = Tween<double>(begin: .0, end: -1.0).animate(base);
    gap = Tween<double>(begin: 5, end: 1.0).animate(base)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
    _deleteStory();
    // if (userImage != '')
    //   print(userImage + ">>>>>>>>>>>>>>>>>>userImage>>>>>>>>");

    super.initState();
  }

  Future getUserDataFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String userDataStr =
        preferences.getString(SharedPreferencesKey.LOGGED_IN_USERRDATA);
    Map<String, dynamic> userData = json.decode(userDataStr);
    loginModel = LoginModal.fromJson(userData);

    setState(() {
      userID = loginModel.user.id;
      userImage = loginModel.user.profilePic;
      userName = loginModel.user.username;
      userfullname = loginModel.user.fullname;
      userEmail = loginModel.user.email;
      userBio = loginModel.user.bio;
      userPhone = loginModel.user.phone;
      userGender = loginModel.user.gender;
      intrestarray = loginModel.user.interestsId;

      _getFollowers(loginModel.user.id);
      _getFollowing(loginModel.user.id);
    });
  }

  List<Post> allPost = [];

  _getPost(int index) async {
    setState(() {
      isLoading = true;
    });
    print('!!!!!!!!!!!');
    print(index);
    print('!!!!!!!!!!!');

    // var uri = Uri.parse('${baseUrl()}/all_post_by_user');
    var uri = Uri.parse(
        '${baseUrl()}/all_post_by_user_pagination?per_page=10&page=${index.toString()}&user_id=$userID');
    var request = new http.MultipartRequest("GET", uri);
    print(uri.toString());
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    request.headers.addAll(headers);
    // request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    if (mounted)
      setState(() {
        // allPost.clear();
        modal = FollowerPostModal.fromJson(userData);

        var contain =
            modal.post.where((element) => element.postReport == "true");

        if (contain.isEmpty) {
          func(page);
          print('if page : $page');
        } else {
          // _getPost(page + 1);
          funcCheck(page);
          print('else page : $page');
        }
      });
    print(responseData);

    for (int i = 0; i < modal.post.length; i++) {
      allPost.add(modal.post[i]);
    }
    // allPost.sort((a, b) => b.createDate.compareTo(a.createDate));
    print('APIIIIIResponse>>>>>>>');
    print(json.encode(allPost));

    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  ScrollController sc = new ScrollController();

  initialiZeController() {
    sc.addListener(() {
      if (sc.position.pixels == sc.position.maxScrollExtent) {
        Future.delayed(Duration(seconds: 2)).whenComplete(() async {
          await _getPost(page);
        });
        print(page);
      }
    });
  }

  void func(page1) async {
    int value = page1 + 10;
    int noValue = page1;
    if (modal.responseCode != '0') {
      print('if');
      setState(() {
        page = value;
        pageloader = true;
      });
    } else {
      print('else>>>>>>>>>');
      setState(() {
        page = noValue;
        pageloader = false;
      });
      // setState(() {
      //   page++;
      // });
    }

    // Await on your future.
  }

  void funcCheck(page1) async {
    int value = page1 + 10;
    int noValue = page1;
    if (modal.responseCode != '0') {
      print('if');

      setState(() {
        page = value;
        pageloader = true;
        _getPost(value);
      });
    } else {
      print('else>>>>>>>>>');
      setState(() {
        page = noValue;
        pageloader = false;
      });
      // setState(() {
      //   page++;
      // });
    }

    // Await on your future.
  }

  _getFollowers(id) async {
    var uri = Uri.parse('${baseUrl()}/my_followers');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    request.headers.addAll(headers);
    request.fields['user_id'] = id;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    Map<String, dynamic> userData = json.decode(responseData);
    print(userData);
    followersModal = FollowersModal.fromJson(userData);
    if (followersModal != null) {
      print(followersModal.follower.length);

      followersModal.follower.forEach((userDetail) {
        globleFollowers.add(userDetail.fromUser);
      });
    }

    print("Followers" + globleFollowers.toString());
  }

  _getFollowing(id) async {
    var uri = Uri.parse('${baseUrl()}/my_following');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['user_id'] = id;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    Map<String, dynamic> userData = json.decode(responseData);
    follwingModal = FollwingModal.fromJson(userData);
    print(userData);

    follwingModal.follower.forEach((userDetail) {
      globleFollowing.add(userDetail.toUser);
    });
    print("Following" + globleFollowing.toString());
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

  _addBookmark(String postid) async {
    // setState(() {
    //   isLoading = true;
    // });
    var uri = Uri.parse('${baseUrl()}/bookmark_post');
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
        addedBookmarks.add(postid);
      });
      // _getPost();
    }

    // setState(() {
    //   isLoading = false;
    // });
  }

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
      });
      // _getPost();
    }

    // setState(() {
    //   isLoading = false;
    // });
  }

  _deleteStory() async {
    setState(() {
      isLoading = true;
    });
    var uri = Uri.parse('${baseUrl()}/delete_story');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    // request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    print(">>>>>>>>>>>>>>>>>>>>>>>>>");
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    deleteStoryModal = DeleteStoryModal.fromJson(userData);
    print(responseData);

    setState(() {
      isLoading = false;
    });
  }

  bool stackLoader = false;
  var reportPostData;
  TextEditingController _textFieldController = TextEditingController();

  _reportPost(postId, status, reportTxt) async {
    print('*******');
    print(status);
    print('*******');
    setState(() {
      stackLoader = true;
    });

    var uri = Uri.parse('${baseUrl()}/posts_report');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['blockedByUserId'] = userID;
    request.fields['blockedPostsId'] = postId;
    request.fields['status'] = status;
    request.fields['report_text'] = reportTxt;
    var response = await request.send();
    print(response.statusCode);
    print(">>>>>>>>>>>>>>>>>>>>>>>>>");
    String responseData = await response.stream.transform(utf8.decoder).join();
    reportPostData = json.decode(responseData);
    if (reportPostData['response_code'] == '1') {
      setState(() {
        stackLoader = false;
        _textFieldController.clear();
      });

      allPost.removeWhere((item) => item.postId == postId);
    } else {
      allPost.removeWhere((item) => item.postId == postId);
      setState(() {
        stackLoader = false;
      });

      print('REPORT RESPONSE FAIL');
      debugPrint('${reportPostData['response_code']}');
    }
    openHideSheet(context, status);
    // deleteStoryModal = DeleteStoryModal.fromJson(userData);
    print(responseData);

    setState(() {
      stackLoader = false;
    });
  }

  _blockUser(blockedUserId) async {
    print('*******');
    print(blockedUserId);
    print('*******');
    setState(() {
      stackLoader = true;
    });

    var uri = Uri.parse('${baseUrl()}/profile_block');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['blockedByUserId'] = userID;
    request.fields['blockedUserId'] = blockedUserId;

    var response = await request.send();
    print(response.statusCode);
    print(">>>>>>>>>>>>>>>>>>>>>>>>>");
    String responseData = await response.stream.transform(utf8.decoder).join();
    var reportPostData = json.decode(responseData);
    if (reportPostData['response_code'] == '1') {
      setState(() {
        stackLoader = false;
      });
      allPost.removeWhere((item) => item.userId == blockedUserId);

      Fluttertoast.showToast(
          msg: 'User Blocked', toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(msg: 'Fail to block');
    }

    // deleteStoryModal = DeleteStoryModal.fromJson(userData);
    print(responseData);

    setState(() {
      stackLoader = false;
    });
  }

  startTime(data) async {
    var _duration = new Duration(milliseconds: 500);
    return new Timer(_duration, navigationPage(data));
  }

  navigationPage(data) {
    setState(() {
      data = false;
    });
  }

  @override
  void dispose() {
    sc.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.015;
    return RefreshIndicator(
      child: Container(
        // height: SizeConfig.screenHeight,
        // width: SizeConfig.screenWidth,
        child: modal != null
            ? SingleChildScrollView(
                controller: sc,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 05,
                      ),
                      storyWidget(),
                      SizedBox(
                        height: 5,
                      ),
                      allPost.length > 0
                          ? new ListView.builder(
                              itemCount: allPost.length,
                              scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              // initialInViewIds: ['0'],
                              // isInViewPortCondition: (double deltaTop,
                              //     double deltaBottom,
                              //     double viewPortDimension) {
                              //   // tap = true;
                              //   return deltaTop < (0.5 * viewPortDimension) &&
                              //       deltaBottom > (0.5 * viewPortDimension);
                              // },
                              // reverse: true,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return _bodyData(allPost[index]);
                              },
                            )
                          : modal.post.length > 0
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height - 300,
                                  child: Center(
                                      child: CircularProgressIndicator()))
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height - 300,
                                  child: Center(
                                      child: Text('No Post Found',
                                          style:
                                              TextStyle(color: Colors.black)))),
                      isLoading
                          ? Container()
                          : pageloader
                              ? Container(
                                  height: _height * 1 / 10,
                                  width: _width,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(7.0),
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                appColor),
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                    ],
                  ),
                ),
              )
            : Center(
                child: loader(context),
              ),
      ),
      onRefresh: _getData,
      // builder:
      //     (BuildContext context, Widget child, IndicatorController controller) {
      //   return AnimatedBuilder(
      //     animation: controller,
      //     builder: (BuildContext context, _) {
      //       return Stack(
      //         alignment: Alignment.topCenter,
      //         children: <Widget>[
      //           if (!controller.isIdle)
      //             Column(
      //               children: [
      //                 Padding(
      //                   padding: const EdgeInsets.all(15.0),
      //                   child: Container(child: CircularProgressIndicator()),
      //                 )
      //               ],
      //             ),
      //           Transform.translate(
      //             offset: Offset(0, 100.0 * controller.value),
      //             child: child,
      //           ),
      //         ],
      //       );
      //     },
      //   );
      // },
    );
  }

  Widget _bodyData(Post post) {
    return post.postReport != 'true' && post.profileBlock != 'true'
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
              onTap: () {
                if (userID == post.userId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile(back: true)),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PublicProfile(
                              peerId: post.userId,
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
                                title: post.username == ""
                                    ? "No name"
                                    : post.username,
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
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.dark
                                                ? appColorWhite.withOpacity(0.5)
                                                : Colors.black45,
                                          ),
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
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            reportPostData = null;
                            reportSheet(
                              context,
                              post.postId,
                              post.userId,
                            );
                          },
                          icon: Icon(Icons.more_horiz),
                        ),
                      ],
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
                                child: ZoomOverlay(
                                  twoTouchOnly: true,
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
                            showIndicator:
                                post.allImage.length > 1 ? true : false,
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
                    ? VideoViewFix(
                        url: post.video,
                        play: true,
                        id: post.postId,
                        mute: false)
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
                            fontFamily: 'Lato'),
                        children: <TextSpan>[
                          TextSpan(
                              text: '  ${post.text}',
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? appColorWhite.withOpacity(0.5)
                                      : Colors.black45,
                                  fontWeight: FontWeight.normal,
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
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? appColorWhite.withOpacity(0.5)
                                    : Colors.black45,
                          ),
                          onPressed: () {
                            // setState(() {
                            //   tap = false;
                            //   _body(context);
                            // });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CommentsScreen(postID: post.postId)),
                            );
                          }),
                    ],
                  ),
                  post.bookmark == "true"
                      ? IconButton(
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
                      : IconButton(
                          onPressed: () {
                            print("Like Post");
                            setState(() {
                              post.bookmark = "true";
                              _addBookmark(post.postId);
                            });
                          },
                          icon: Icon(
                            CupertinoIcons.bookmark,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? appColorWhite.withOpacity(0.5)
                                    : Colors.black45,
                          ))
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            post.comment != null &&
                    post.comment.text != null &&
                    post.comment.username != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 5),
                    child: RichText(
                      text: TextSpan(
                        text: '${post.comment.username} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorLight,
                          fontFamily: 'Lato',
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: post.comment.text,
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? appColorWhite.withOpacity(0.5)
                                      : Colors.black54,
                                  fontWeight: FontWeight.normal)),
                        ],
                      ),
                    )

                    //  CustomTextStyle1(
                    //   title: post.comment.username + ' ' + post.comment.text,
                    //   color: Colors.black,
                    //   weight: FontWeight.w700,
                    // ),
                    )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      // setState(() {
                      //   tap = false;
                      //   _body(context);
                      // });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CommentsScreen(postID: post.postId)),
                      );
                    },
                    child: CustomTextStyle1(
                      title: "View all " +
                          post.totalComments.toString() +
                          " comments..",
                      color: Theme.of(context).brightness == Brightness.dark
                          ? appColorWhite.withOpacity(0.5)
                          : Colors.black38,
                      weight: FontWeight.w500,
                    ),
                  ),
                  Text(
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
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25,
            )
          ])
        : Container();
  }

  // Widget _bodyRecentData(RescentPost post, bool isInView) {
  //   return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //     InkWell(
  //       onTap: () {
  //         if (userID == post.userId) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => Profile(back: true)),
  //           );
  //         } else {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => PublicProfile(
  //                       peerId: post.userId,
  //                       peerUrl: post.profilePic,
  //                       peerName: post.username,
  //                     )),
  //           );
  //         }
  //       },
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: <Widget>[
  //           Row(
  //             children: [
  //               post.profilePic == ""
  //                   ? Image.asset(
  //                       "assets/images/user.png",
  //                       height: 45,
  //                     )
  //                   : CircleAvatar(
  //                       backgroundImage: NetworkImage(post.profilePic),
  //                       radius: 25,
  //                     ),
  //               SizedBox(
  //                 width: SizeConfig.blockSizeHorizontal * 2,
  //               ),
  //               Row(
  //                 children: [
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       CustomTextStyle1(
  //                         title:
  //                             post.username == "" ? "No name" : post.username,
  //                         color: Colors.black,
  //                         fontsize: 16,
  //                         weight: FontWeight.w500,
  //                       ),
  //                       post.location != ''
  //                           ? Column(
  //                               children: [
  //                                 SizedBox(
  //                                   height: 02,
  //                                 ),
  //                                 Text(
  //                                   post.location,
  //                                   style: TextStyle(
  //                                       letterSpacing: 1,
  //                                       fontSize: 12,
  //                                       color: Colors.black45),
  //                                 ),
  //                               ],
  //                             )
  //                           : Container()
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.only(right: 05),
  //             child: Text(
  //               format(
  //                   DateTime.fromMillisecondsSinceEpoch(
  //                       int.parse(post.createDate)),
  //                   locale: 'en_short'),
  //               maxLines: 2,
  //               overflow: TextOverflow.ellipsis,
  //               style: TextStyle(
  //                 color: Colors.black45,
  //                 fontSize: 10,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     SizedBox(
  //       height: 10,
  //     ),
  //     SizedBox(
  //       height: 10,
  //     ),
  //     post.allImage.length > 0
  //         ? InkWell(
  //             onDoubleTap: () {
  //               if (post.isLikes == "false") {
  //                 setState(() {
  //                   post.dataV = true;
  //                   post.isLikes = "true";
  //                   post.totalLikes = post.totalLikes + 1;
  //                   _likePost(post.postId);
  //                 });
  //                 var _duration = new Duration(milliseconds: 500);
  //                 Timer(_duration, () {
  //                   post.dataV = false;
  //                 });
  //                 print('dataV : ${post.dataV}');
  //               }
  //             },
  //             child: Stack(
  //               children: [
  //                 Container(
  //                   height: SizeConfig.blockSizeVertical * 40,
  //                   width: SizeConfig.screenWidth,
  //                   child: Carousel(
  //                     images: post.allImage.map((it) {
  //                       return ClipRRect(
  //                         borderRadius: BorderRadius.circular(15),
  //                         child: Container(
  //                           child: CachedNetworkImage(
  //                             imageUrl: it,
  //                             imageBuilder: (context, imageProvider) =>
  //                                 Container(
  //                               decoration: BoxDecoration(
  //                                 image: DecorationImage(
  //                                   image: imageProvider,
  //                                   fit: BoxFit.cover,
  //                                 ),
  //                               ),
  //                             ),
  //                             placeholder: (context, url) => Center(
  //                               child: Container(
  //                                 // height: 40,
  //                                 // width: 40,
  //                                 child: CircularProgressIndicator(),
  //                               ),
  //                             ),
  //                             errorWidget: (context, url, error) =>
  //                                 Icon(Icons.error),
  //                             fit: BoxFit.cover,
  //                           ),
  //                         ),
  //                       );
  //                     }).toList(),
  //                     showIndicator: true,
  //                     dotBgColor: Colors.transparent,
  //                     borderRadius: false,
  //                     autoplay: false,
  //                     dotSize: 5.0,
  //                     dotSpacing: 15.0,
  //                   ),
  //                 ),
  //                 post.dataV == true
  //                     ? Positioned.fill(
  //                         child: AnimatedOpacity(
  //                             opacity: post.dataV ? 1.0 : 0.0,
  //                             duration: Duration(milliseconds: 700),
  //                             child: Icon(
  //                               CupertinoIcons.heart_fill,
  //                               color: Colors.red,
  //                               size: 100,
  //                             )))
  //                     : Container(),
  //               ],
  //             ),
  //           )
  //         : post.video != ""
  //             ? tap == false
  //                 ? Stack(
  //                     children: [
  //                       VideoView(
  //                         url: post.video,
  //                         play: false,
  //                       ),
  //                       show == true
  //                           ? Positioned.fill(
  //                               child: AnimatedOpacity(
  //                                   opacity: show ? 1.0 : 0.0,
  //                                   duration: Duration(milliseconds: 700),
  //                                   child: Icon(
  //                                     CupertinoIcons.heart_fill,
  //                                     color: Colors.red,
  //                                     size: 100,
  //                                   )))
  //                           : Container(),
  //                     ],
  //                   )
  //                 : Stack(
  //                     children: [
  //                       VideoView(
  //                         url: post.video,
  //                         play: isInView,
  //                       ),
  //                       show == true
  //                           ? Positioned.fill(
  //                               child: AnimatedOpacity(
  //                                   opacity: show ? 1.0 : 0.0,
  //                                   duration: Duration(milliseconds: 700),
  //                                   child: Icon(
  //                                     CupertinoIcons.heart_fill,
  //                                     color: Colors.red,
  //                                     size: 100,
  //                                   )))
  //                           : Container(),
  //                     ],
  //                   )
  //             : Container(
  //                 height: 230,
  //                 width: double.infinity,
  //                 color: Colors.grey[200],
  //                 child: Icon(
  //                   Icons.image,
  //                   size: 200,
  //                   color: Colors.grey[600],
  //                 )),
  //     SizedBox(
  //       height: 10,
  //     ),
  //     post.text != ""
  //         ? Padding(
  //             padding: const EdgeInsets.only(left: 5),
  //             child: RichText(
  //               text: TextSpan(
  //                 text: post.username == "" ? "No name" : post.username,
  //                 style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black,
  //                     fontSize: 15,
  //                     fontFamily: 'Lato'),
  //                 children: <TextSpan>[
  //                   TextSpan(
  //                       text: '  ${post.text}',
  //                       style: TextStyle(
  //                           fontSize: 12,
  //                           color: Colors.black,
  //                           fontFamily: 'Lato')),
  //                 ],
  //               ),
  //             ))
  //         : Container(),
  //     Padding(
  //       padding: const EdgeInsets.only(left: 5, top: 0),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               // likedPost.contains(modal.post[index].postId)
  //               post.isLikes == "true"
  //                   ? InkWell(
  //                       onTap: () {
  //                         setState(() {
  //                           post.isLikes = "false";
  //                           post.totalLikes = post.totalLikes - 1;
  //                           _unlikePost(post.postId);
  //                         });
  //                         print("Unlike Post");
  //                       },
  //                       child: Icon(
  //                         CupertinoIcons.heart_fill,
  //                         size: 30,
  //                         color: Colors.red,
  //                       ),
  //                     )
  //                   : InkWell(
  //                       onTap: () {
  //                         print("Like Post");
  //                         setState(() {
  //                           post.totalLikes = post.totalLikes + 1;
  //                           post.isLikes = "true";
  //                           _likePost(post.postId);
  //                         });
  //                       },
  //                       child: Icon(
  //                         CupertinoIcons.heart,
  //                         color: Colors.black45,
  //                         size: 30,
  //                       ),
  //                     ),
  //               SizedBox(
  //                 width: 5,
  //               ),
  //               CustomTextStyle1(
  //                 title: '${post.totalLikes.toString()} Likes',
  //                 weight: FontWeight.w500,
  //                 color: Colors.black54,
  //               ),
  //               IconButton(
  //                   icon: Icon(
  //                     CupertinoIcons.chat_bubble_text,
  //                     size: 25,
  //                     color: Colors.black45,
  //                   ),
  //                   onPressed: () {
  //                     setState(() {
  //                       tap = false;
  //                       _body(context);
  //                     });

  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                           builder: (context) =>
  //                               CommentsScreen(postID: post.postId)),
  //                     );
  //                   }),
  //             ],
  //           ),
  //           post.bookmark == "true"
  //               ? IconButton(
  //                   onPressed: () {
  //                     setState(() {
  //                       post.bookmark = "false";
  //                       // post.totalLikes = post.totalLikes - 1;
  //                       _removeBookmark(post.postId);
  //                     });
  //                     print("Unlike Post");
  //                   },
  //                   icon: Icon(
  //                     CupertinoIcons.bookmark_fill,
  //                     color: Colors.amber,
  //                   ))
  //               : IconButton(
  //                   onPressed: () {
  //                     print("Like Post");
  //                     setState(() {
  //                       post.bookmark = "true";
  //                       _addBookmark(post.postId);
  //                     });
  //                   },
  //                   icon: Icon(
  //                     CupertinoIcons.bookmark,
  //                     color: Colors.black45,
  //                   ))
  //         ],
  //       ),
  //     ),
  //     SizedBox(
  //       height: 5,
  //     ),
  //     post.comment.text != ''
  //         ? Padding(
  //             padding: const EdgeInsets.only(left: 5),
  //             child: CustomTextStyle1(
  //               title: post.comment.username + ' ' + post.comment.text,
  //               color: Colors.black,
  //               weight: FontWeight.w500,
  //             ),
  //           )
  //         : Container(),
  //     Padding(
  //       padding: const EdgeInsets.only(left: 5),
  //       child: CustomTextStyle1(
  //         title: "Viw all " + post.totalComments.toString() + " comment...",
  //         color: Colors.black38,
  //         weight: FontWeight.w500,
  //       ),
  //     ),
  //     SizedBox(
  //       height: 25,
  //     )
  //   ]);
  // }

  Future<void> _getData() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      allPost.clear();
      _getPost(1);
    });
  }

  Widget storyWidget() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: InkWell(
            onTap: () {
              openDeleteDialog(context);
            },
            child: Container(
              height: SizeConfig.blockSizeVertical * 12,
              child: Stack(
                // alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    // height: SizeConfig.blockSizeVertical * 14,
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: RotationTransition(
                            turns: base,
                            child: DashedCircle(
                              gapSize: gap.value,
                              dashes: 1,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? appColorWhite
                                  : Colors.black45,
                              child: RotationTransition(
                                turns: reverse,
                                child: Padding(
                                    padding: const EdgeInsets.all(9.4),
                                    child: CircleAvatar(
                                      radius: 19.0,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: userImage != '' &&
                                              userImage != null
                                          ? NetworkImage(userImage)
                                          : NetworkImage(
                                              "${"https://www.nicepng.com/png/detail/136-1366211_group-of-10-guys-login-user-icon-png.png"}"),
                                    )),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 7,
                        ),
                        Container(
                          // width: 50,
                          padding: const EdgeInsets.only(top: 0),
                          alignment: Alignment.center,
                          child: Text(
                            "Create Story",
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 3,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? appColorWhite
                                    : Colors.black45),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: Container(
              height: SizeConfig.blockSizeVertical * 12,
              // color: Colors.white,
              child: InstaStories()),
        ),
      ],
    );
  }

  openDeleteDialog(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Video",
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 16,
                  fontFamily: "Lato"),
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("Discard");

              _pickVideo();
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Camera",
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 16,
                  fontFamily: "Lato"),
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("Discard");

              File _image;
              final picker = ImagePicker();
              final imageFile =
                  await picker.getImage(source: ImageSource.camera);

              if (imageFile != null) {
                setState(() {
                  if (imageFile != null) {
                    _image = File(imageFile.path);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PreviewStory(imageFile: _image)),
                    );
                  } else {
                    print('No image selected.');
                  }
                });
              }
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Gallery",
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 16,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("Discard");

              File _image;
              final picker = ImagePicker();
              final imageFile =
                  await picker.getImage(source: ImageSource.gallery);

              if (imageFile != null) {
                setState(() {
                  if (imageFile != null) {
                    _image = File(imageFile.path);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PreviewStory(imageFile: _image)),
                    );
                  } else {
                    print('No image selected.');
                  }
                });
              }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: Theme.of(context).primaryColorLight, fontFamily: "Lato"),
          ),
          isDefaultAction: true,
          onPressed: () {
            // Navigator.pop(context, 'Cancel');
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  // ignore: unused_field
  VideoPlayerController _videoPlayerController;

  _pickVideo() async {
    var video = await ImagePicker().getVideo(source: ImageSource.gallery);

    if (video != null) {
      indicatorDialog(context);
      await VideoCompress.setLogLevel(0);

      final compressedVideo = await VideoCompress.compressVideo(
        video.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (compressedVideo != null) {
        // _video = File(compressedVideo.path);
        _videoPlayerController =
            VideoPlayerController.file(File(compressedVideo.path))
              ..initialize().then((_) {
                setState(() {
                  Navigator.pop(context);

                  if (video != null) {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) =>
                    //           SendVideoStory(videoFile: video)),
                    // );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SendVideoStory(
                              videoFile: File(compressedVideo.path))),
                    );
                  } else {
                    print('issue with compressing video in story');
                  }
                });
                // _videoPlayerController.play();
              });
      } else {
        Navigator.pop(context);
      }
    }
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        key: _scaffoldkey,
        // drawer: DrawerWidget(),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Memeland",
            style: TextStyle(
              fontSize: 30,
              fontFamily: 'BrushScript',
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notifications()),
                );
              },
                icon: Icon(Icons.notifications_none, size: 28,color: Theme.of(context).primaryColorLight,)
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FilterView()),
                );
              },
              icon: Icon(Icons.search_rounded, size: 28,color: Theme.of(context).primaryColorLight,)
              // Image.asset(
              //   'assets/images/filter.png',
              //   height: 28,
              //   width: 28,
              //   color: Theme.of(context).primaryColorLight,
              // ),
            ),
          ],
          leading: IconButton(
            icon: Image.asset(
              'assets/images/menu.png',
              height: 35,
              width: 35,
              color: Theme.of(context).primaryColorLight,
            ),
            onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.5,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _body(context));
  }

  reportSheet(BuildContext context, postId, postUserId) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: Text(
              "Report",
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 16,
                  fontFamily: "Lato"),
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("Discard");
              openBottmSheet(context, 'report', postId);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Hide",
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 16,
                  fontFamily: "Lato"),
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("Discard");
              // setState(() {
              //   reoportLoader = true;
              // });
              _reportPost(postId, 'hide', '');
            },
          ),
          postUserId != userID
              ? CupertinoActionSheetAction(
                  child: Text(
                    "Block User",
                    style: TextStyle(
                        color: Colors.red, fontSize: 16, fontFamily: "Lato"),
                  ),
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop("Discard");
                    _blockUser(postUserId);
                  },
                )
              : Container()
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(fontFamily: "Lato"),
          ),
          isDefaultAction: true,
          onPressed: () {
            // Navigator.pop(context, 'Cancel');
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  openBottmSheet(BuildContext context, String reportType, String postId) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                  height: 700,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                          child: Text(
                        'Report',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(fontWeight: FontWeight.bold),
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'Why are you reporting this post?',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop("Discard");
                                _reportPost(postId, reportType,
                                    'Nudity or sexual activity');
                              },
                              title: new Text(
                                "Nudity or sexual activity",
                                style: new TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop("Discard");
                                _reportPost(postId, reportType,
                                    'I just don\'t like it');
                              },
                              title: new Text(
                                "I just don\'t like it",
                                style: new TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop("Discard");
                                _reportPost(postId, reportType,
                                    'Hate speech or symbol');
                              },
                              title: new Text(
                                "Hate speech or symbol",
                                style: new TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop("Discard");
                                _reportPost(postId, reportType,
                                    'Bullying or harassment');
                              },
                              title: new Text(
                                "Bullying or harassment",
                                style: new TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop("Discard");
                                _reportPost(postId, reportType,
                                    'Violence or dangerous organisation');
                              },
                              title: new Text(
                                "Violence or dangerous organisation",
                                style: new TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop("Discard");
                                _displayTextInputDialog(
                                    context, postId, reportType);
                              },
                              title: new Text(
                                "Something else",
                                style: new TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          );
        });
      },
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context, id, type) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // title: Text('Something else'),
            content: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: TextField(
                    onChanged: (value) {},
                    maxLines: 5,
                    controller: _textFieldController,
                    decoration: InputDecoration.collapsed(
                        hintText: "Enter your text here")),
              ),
            ),
            actions: <Widget>[
              TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop("Discard");
                    print('Pressed');
                  }),
              TextButton(
                  child: Text('Submit'),
                  onPressed: () {
                    print('Pressed');
                    if (_textFieldController.text.isNotEmpty) {
                      Navigator.of(context, rootNavigator: true).pop("Discard");
                      _reportPost(id, type, _textFieldController.text);
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Please enter text to continue..');
                    }
                  })
            ],
          );
        });
  }

  openHideSheet(BuildContext context, String reportType) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                  height: 700,
                  child: Container(
                      child: reportPostData != null &&
                              reportPostData['response_code'] == '1'
                          ? Container(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/Done-pana.png',
                                    height: 300,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  reportType == 'hide'
                                      ? Column(
                                          children: [
                                            Text(
                                              'Post Hidden successfully',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  reportType == 'report'
                                      ? Column(
                                          children: [
                                            Text(
                                              'Thanks for letting us know',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                                'Your feedback is important in helping us keep the community safe.',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .copyWith(fontSize: 15)),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      // background color
                                      primary: appColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 10),
                                      textStyle: const TextStyle(fontSize: 15),
                                    ),
                                    child: const Text('Continue'),
                                    onPressed: () {
                                      debugPrint('Button clicked!');
                                      Navigator.of(context, rootNavigator: true)
                                          .pop("Discard");
                                    },
                                  ),
                                ],
                              ),
                            )
                          : reportPostData != null &&
                                  reportPostData['response_code'] == '0'
                              ? Container(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/Done-pana.png',
                                        height: 300,
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                      reportPostData['status'] != 'fail'
                                          ? Text(
                                              'This post is already reorted',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            )
                                          : Text(
                                              'Fail to submit',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Fail to submit your report please try again',
                                        textAlign: TextAlign.center,
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          // background color
                                          primary: appColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 10),
                                          textStyle:
                                              const TextStyle(fontSize: 15),
                                        ),
                                        child: const Text('Continue'),
                                        onPressed: () {
                                          debugPrint('Button clicked!');
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop("Discard");
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : Container())),
            ),
          );
        });
      },
    );
  }
}
