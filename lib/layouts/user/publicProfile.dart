import 'dart:convert';
import 'package:memeland/global/global.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:http/http.dart' as http;
import 'package:memeland/layouts/chat/chat.dart';
import 'package:memeland/layouts/post/viewPublicPost.dart';
import 'package:memeland/layouts/user/myFollowers.dart';
import 'package:memeland/layouts/user/myFollowing.dart';
import 'package:memeland/models/postFollowModal.dart';
import 'package:memeland/models/postModal.dart';
import 'package:memeland/models/unFollowModal.dart';
import 'package:memeland/models/userdata_model.dart';

class PublicProfile extends StatefulWidget {
  final String peerId;
  final String peerUrl;
  final String peerName;

  PublicProfile({this.peerId, this.peerUrl, this.peerName});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<PublicProfile> {
  bool isInView = false;

  bool isLoading = false;
  UserDataModel modal;
  PostModal postModal;
  FollowModal followModal;
  UnfollowModal unfollowModal;

  @override
  void initState() {
    print(widget.peerId + ">>>>>>>>>>");
    print(widget.peerId + ">>>>>>>>>>");
    print(userID + ' User Id');
    _getUser();
    super.initState();
  }

  _getUser() async {
    setState(() {
      isLoading = true;
    });
    var uri = Uri.parse('${baseUrl()}/user_data');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['user_id'] = widget.peerId;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    modal = UserDataModel.fromJson(userData);
    print(responseData);
    _getPost();
  }

  _getPost() async {
    var uri = Uri.parse('${baseUrl()}/post_by_user');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields["user_id"] = widget.peerId;
    request.fields['to_user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    postModal = PostModal.fromJson(userData);
    print(responseData);
    print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    // print(modal.user.profilePic);
    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.5,
          title: Text(
            modal != null && modal.user.fullname != ''
                ? modal.user.fullname
                : '',
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColorLight,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: isLoading
            ? Center(
                child: loader(context),
              )
            : modal != null
                ? Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 40, top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey[600], width: 1),
                                      shape: BoxShape.circle),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: CircleAvatar(
                                      backgroundImage: modal.user.profilePic !=
                                                  null &&
                                              modal.user.profilePic.length > 0
                                          ? NetworkImage(modal.user.profilePic)
                                          : NetworkImage(
                                              "${"https://www.nicepng.com/png/detail/136-1366211_group-of-10-guys-login-user-icon-png.png"}"),
                                      radius: 45,
                                    ),
                                  ),
                                ),
                                _buildCategory("Posts", modal.userPost),
                                InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FollowingScreen(
                                                    id: modal.user.id)),
                                      );
                                    },
                                    child: _buildCategory(
                                        "Following", modal.following)),
                                InkWell(
                                  onTap: () {
                                    print(modal.user.id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FollowersScreen(
                                              id: modal.user.id)),
                                    );
                                  },
                                  child: _buildCategory(
                                      "Followers", modal.followers),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              modal.user.username ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColorLight),
                            ),
                          ),
                          modal.user.bio != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 3),
                                  child: Column(
                                    children: [
                                      Text(
                                        modal.user.bio,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .primaryColorLight),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10),
                            child: widget.peerId != userID
                                ? Row(
                                    children: [
                                      globleFollowing.contains(modal.user.id)
                                          ? Expanded(
                                              child: Container(
                                                // width: 100,
                                                // ignore: deprecated_member_use
                                                child: FlatButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      side: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.5)),
                                                  child: Text(
                                                    "Following",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[700]),
                                                  ),
                                                  color: Colors.transparent,
                                                  onPressed: () {
                                                    unfollowApiCall();
                                                  },
                                                ),
                                              ),
                                            )
                                          : Expanded(
                                              child: Container(
                                                // width: 100,
                                                // ignore: deprecated_member_use
                                                child: FlatButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                    "Follow",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  color: buttonColorBlue,
                                                  onPressed: () {
                                                    followApiCall();
                                                  },
                                                ),
                                              ),
                                            ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: Container(
                                        // width: 100,
                                        // ignore: deprecated_member_use
                                        child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              side: BorderSide(
                                                  color: Colors.grey,
                                                  width: 1.5)),
                                          child: Text(
                                            "Message",
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                          color: Colors.transparent,
                                          onPressed: () {
                                            if (userName != '')
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Chat(
                                                          peerID: widget.peerId,
                                                          peerUrl:
                                                              widget.peerUrl,
                                                          peerName:
                                                              widget.peerName,
                                                          // currentusername:
                                                          //     userName,
                                                          // currentuserimage:
                                                          //     userImage,
                                                          // currentuser: userID,
                                                          //  peerToken: widget.peerToken,
                                                        )),
                                              );
                                          },
                                        ),
                                      ))
                                    ],
                                  )
                                : globleFollowing.contains(modal.user.id)
                                    ? Expanded(
                                        child: Container(
                                          // width: 100,
                                          // ignore: deprecated_member_use
                                          child: FlatButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                side: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1.5)),
                                            child: Text(
                                              "Following",
                                              style: TextStyle(
                                                  color: Colors.grey[700]),
                                            ),
                                            color: Colors.transparent,
                                            onPressed: () {
                                              unfollowApiCall();
                                            },
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: Container(
                                          // width: 100,
                                          // ignore: deprecated_member_use
                                          child: FlatButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              "Follow",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            color:
                                                // ignore: deprecated_member_use
                                                buttonColorBlue,
                                            onPressed: () {
                                              followApiCall();
                                            },
                                          ),
                                        ),
                                      ),
                          ),
                        ],
                      ),
                      Expanded(child: _userPost()),
                    ],
                  )
                : Container());
  }

  Widget _userPost() {
    return myPost();
  }

  Widget myPost() {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: postModal.follower.length > 0
            ? GridView.builder(
                shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                primary: false,
                padding: EdgeInsets.all(5),
                itemCount: postModal.follower.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 200 / 200,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                      padding: EdgeInsets.all(5.0),
                      child: postModal.follower[index].allImage.length > 0
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewPublicPost(
                                          id: postModal
                                              .follower[index].postId)),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      postModal.follower[index].allImage[0],
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
                            )

                          // Image.network(
                          //     postModal
                          //         .follower[index].allImage[0],
                          //     fit: BoxFit.cover,
                          //   )
                          : postModal.follower[index].video.length > 0 &&
                                  postModal.follower[index].thumbnail != ''
                              ? InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewPublicPost(
                                              id: postModal
                                                  .follower[index].postId)),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(0),
                                        child: CachedNetworkImage(
                                          imageUrl: postModal
                                              .follower[index].thumbnail,
                                          imageBuilder:
                                              (context, imageProvider) =>
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
                                                child:
                                                    CircularProgressIndicator()),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, top: 5),
                                          child: Icon(
                                            CupertinoIcons.play_circle_fill,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image,
                                    size: 120,
                                  )));
                },
              )
            : Container(
                height: SizeConfig.blockSizeVertical * 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Share photos and videos",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 5,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 2,
                    ),
                    Text(
                      "When you share photos and videos, they'll appear\non your profile",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3,
                          color:  Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ));
  }

  Widget _buildCategory(String title, data) {
    return Column(
      children: <Widget>[
        Text(
          data,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(),
        ),
      ],
    );
  }

  followApiCall() async {
    var uri = Uri.parse('${baseUrl()}/follow_user');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['from_user'] = userID;
    request.fields['to_user'] = widget.peerId;
    var response = await request.send();
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    followModal = FollowModal.fromJson(userData);
    if (followModal.responseCode == "1") {
      setState(() {
        globleFollowing.add(widget.peerId);
      });
    }
  }

  unfollowApiCall() async {
    var uri = Uri.parse('${baseUrl()}/unfollow_user');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['from_user'] = userID;
    request.fields['to_user'] = widget.peerId;
    var response = await request.send();
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    unfollowModal = UnfollowModal.fromJson(userData);
    if (unfollowModal.responseCode == "1") {
      setState(() {
        globleFollowing.remove(widget.peerId);
      });
    }
  }
}
