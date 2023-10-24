import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:memeland/global/global.dart';
import 'package:memeland/models/addCommentModal.dart';
import 'package:memeland/models/getCommentModal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timeago/timeago.dart';

// ignore: must_be_immutable
class CommentsScreen extends StatefulWidget {
  String postID;
  CommentsScreen({this.postID});

  @override
  _LoginPage1State createState() => _LoginPage1State(postID: postID);
}

class _LoginPage1State extends State<CommentsScreen> {
  String postID;
  _LoginPage1State({this.postID});
  GetCommentModal modal;
  AddCommentModal addCommentModal;
  bool isLoading = false;
  final myController = TextEditingController();

  @override
  void initState() {
    _getComment();
    super.initState();
  }

  _getComment() async {
    setState(() {
      isLoading = true;
    });
    var uri = Uri.parse('${baseUrl()}/comments_by_post');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['post_id'] = postID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    modal = GetCommentModal.fromJson(userData);
    print(responseData);

    setState(() {
      isLoading = false;
    });
  }

  _addComment() async {
    setState(() {
      isLoading = true;
    });
    var uri = Uri.parse('${baseUrl()}/add_comments');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['post_id'] = postID;
    request.fields['user_id'] = userID;
    request.fields['text'] = myController.text;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    addCommentModal = AddCommentModal.fromJson(userData);
    print(responseData);

    if (addCommentModal.responseCode == "1") {
      _getComment();
      myController.clear();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isLoading
          ? Center(
              child: loader(context),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Container(
                    width: ScreenUtil.screenWidth,
                    child: Stack(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Comments",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "Poppins-Medium",
                                        color: Theme.of(context).primaryColorLight,
                                        fontSize:
                                            ScreenUtil.getInstance().setSp(40),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: IconButton(
                            icon: Icon(CupertinoIcons.back),
                            color: Theme.of(context).primaryColorLight,
                            iconSize: 30,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Expanded(
                  child: commentList(),
                ),
                Center(
                  child: Container(
                    margin: safeQueries(context)
                        ? EdgeInsets.only(bottom: 25)
                        : null,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 10,
                        ),
                        // // Button send image
                        // Material(
                        //   child: new Container(
                        //     margin: new EdgeInsets.symmetric(horizontal: 1.0),
                        //     child: new IconButton(
                        //       icon: Icon(Icons.attachment),
                        //       onPressed: () {
                        //         // getImage();
                        //       },
                        //       // color: primaryColor,
                        //     ),
                        //   ),
                        //   color: Colors.white,
                        // ),

                        // Edit text
                        Flexible(
                          child: Container(
                            child: TextField(
                              style: TextStyle(
                                  color: Colors.black, fontSize: 15.0),
                              controller: myController,

                              autofocus: true,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Add a comment...',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              // focusNode: focusNode,
                            ),
                          ),
                        ),

                        // Button send message
                        Material(
                          child: new Container(
                            margin: new EdgeInsets.symmetric(horizontal: 8.0),
                            child: new IconButton(
                              icon: new Icon(
                                Icons.send,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _addComment();
                              },
                              // color: primaryColor,
                            ),
                          ),
                          color: Colors.white,
                        ),
                      ],
                    ),
                    width: double.infinity,
                    height: 50.0,
                    decoration: new BoxDecoration(
                        border: new Border(
                            top:
                                new BorderSide(color: Colors.grey, width: 0.7)),
                        color: Colors.white),
                  ),
                )
              ],
            ),
    );
  }

  Widget commentList() {
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: modal.likes.length,
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: Container(
              child: Container(
                decoration: BoxDecoration(
                  //color: Colors.grey,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Material(
                            child:
                                // peerUrl != null
                                //     ?
                                CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CupertinoActivityIndicator(),
                                width: 35.0,
                                height: 35.0,
                                padding: EdgeInsets.all(10.0),
                              ),
                              errorWidget: (context, url, error) => Material(
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: modal.likes[index].profilePic,
                              width: 45.0,
                              height: 45.0,
                              fit: BoxFit.cover,
                            ),
                            // : Padding(
                            //     padding: const EdgeInsets.all(10.0),
                            //     child: Icon(
                            //       Icons.person,
                            //       size: 25,
                            //     ),
                            //   ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(120.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          Container(width: 15.0),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(height: 10.0),
                                    Expanded(
                                      child: RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                            fontSize: 14.0,
                                          ),
                                          children: <TextSpan>[
                                            new TextSpan(
                                                text:
                                                    modal.likes[index].username,
                                                style: TextStyle(
                                                    fontStyle: FontStyle.normal,
                                                    color: Theme.of(context).primaryColorLight,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text: "  " +
                                                    modal.likes[index].text,
                                                style: TextStyle(
                                                    fontSize: SizeConfig
                                                            .safeBlockHorizontal *
                                                        3.5,
                                                    color: Theme.of(context).primaryColorLight,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    Text(
                                      format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(modal.likes[index].date)),
                                      ),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.normal),
                                    ),
                                  ],
                                ),
                                // Padding(
                                //   padding:
                                //       const EdgeInsets.only(top: 4, left: 0),
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.start,
                                //     children: <Widget>[
                                //       Padding(
                                //         padding: const EdgeInsets.only(
                                //             left: 0, bottom: 00),
                                //         child: Text(
                                //           format(
                                //               DateTime
                                //                   .fromMillisecondsSinceEpoch(
                                //                       int.parse(modal
                                //                           .likes[index].date)),
                                //               locale: 'en_short'),
                                //           style: TextStyle(
                                //               color: Colors.grey,
                                //               fontWeight: FontWeight.normal,
                                //               fontStyle: FontStyle.normal),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[],
          );
        });
  }
}
