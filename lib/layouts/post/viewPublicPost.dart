import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:memeland/global/global.dart';
import 'package:memeland/layouts/post/comments.dart';
import 'package:memeland/layouts/user/profile.dart';
import 'package:memeland/layouts/user/publicProfile.dart';
import 'package:memeland/layouts/videoview/videoViewFix.dart';

import 'package:memeland/models/likeModal.dart';
import 'package:memeland/models/unlikeModal.dart';
import 'package:memeland/models/view_publicpost_model.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:timeago/timeago.dart';

// ignore: must_be_immutable
class ViewPublicPost extends StatefulWidget {
  String id;
  ViewPublicPost({this.id});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ViewPublicPost> {
  bool isLoading = false;

  bool tap = true;

  bool isInView = false;
  @override
  void initState() {
    print(widget.id);
    _getPost();
    super.initState();
  }

  PublicPostModel publicPost;
  UnlikeModal unlikeModal;

  LikeModal likeModal;

  _getPost() async {
    setState(() {
      isLoading = true;
    });
    var uri = Uri.parse('${baseUrl()}/get_post_details');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['user_id'] = userID;
    request.fields['post_id'] = widget.id;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    publicPost = PublicPostModel.fromJson(userData);
    print(responseData);

    setState(() {
      isLoading = false;
    });
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
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
                  color: Theme.of(context).primaryColorLight, fontSize: 16, fontFamily: "Lato"),
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
                  color: Theme.of(context).primaryColorLight, fontSize: 16, fontFamily: "Lato"),
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

  TextEditingController _textFieldController = TextEditingController();
  bool stackLoader = false;
  var reportPostData;

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
      // Navigator.pop(context, true);
    } else {
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
                                      Navigator.of(context)
                                          .pushReplacementNamed('/Pages',
                                              arguments: 0);
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0.5,
              title: isLoading
                  ? Container()
                  : Text(
                      publicPost.post.username != ''
                          ? publicPost.post.username
                          : '',
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
            body: isLoading
                ? Center(
                    child: loader(context),
                  )
                : SingleChildScrollView(
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: postDetails(publicPost.post),
                  ))),
      ),
    );
  }

  Widget postDetails(Post post) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        onTap: () {
          if (userID == post.userId) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile(back: true)),
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
                    icon: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  Text(
                    format(
                        DateTime.fromMillisecondsSinceEpoch(int.parse(
                          post.createDate,
                        )),
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
              ? tap == false
                  ? VideoViewFix(url: post.video, play: false, mute: false)
                  : VideoViewFix(url: post.video, play: isInView, mute: false)
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
        padding: const EdgeInsets.only(left: 5, top: 5),
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
                      : Colors.black54,
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
                        // _body(context);
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? appColorWhite.withOpacity(0.5)
                          : Colors.black45,
                    ))
          ],
        ),
      ),
      SizedBox(
        height: 5,
      ),
      publicPost.comment != null && publicPost.comment.text != ''
          ? Padding(
              padding: const EdgeInsets.only(left: 5),
              child: CustomTextStyle1(
                title:
                    publicPost.comment.username + ' ' + publicPost.comment.text,
                color: Theme.of(context).primaryColorLight,
                weight: FontWeight.w500,
              ),
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
                title:
                    "View all " + post.totalComments.toString() + " comments..",
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
    ]);
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
}
