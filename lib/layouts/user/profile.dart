import 'dart:convert';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:memeland/global/global.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:memeland/layouts/post/viewPublicPost.dart';
import 'package:memeland/layouts/user/editprofile1.dart';
import 'package:memeland/layouts/user/myFollowers.dart';
import 'package:memeland/layouts/user/myFollowing.dart';
import 'package:memeland/layouts/user/saved_bookmars.dart';
import 'package:memeland/models/postModal.dart';
import 'package:memeland/models/userdata_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  Profile({Key key, this.parentScaffoldKey, this.back}) : super(key: key);
  bool back;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  bool isInView = false;

  bool isLoading = false;
  UserDataModel modal;
  PostModal postModal;
  String totalPost = '0';

  @override
  void initState() {
    // print('USER WEB >>>>> $userWeb');
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
    request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    modal = UserDataModel.fromJson(userData);
    print(responseData);
    if (modal.responseCode == "1") {
      userfullname = modal.user.fullname;

      userGender = modal.user.gender;
      userPhone = modal.user.phone;
      userEmail = modal.user.email;
      userName = modal.user.username;
      userImage = modal.user.profilePic;

      userBio = modal.user.bio;
      intrestarray = modal.user.interestsId;
      if (userImage != '') print(userImage);
    }
    _getPost();
  }

  _getPost() async {
    var uri = Uri.parse('${baseUrl()}/post_by_user');
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
    postModal = PostModal.fromJson(userData);
    print(responseData);
    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getRequests() async {
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.5,
          title: userName != ''
              ? Text(
                  "$userName",
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold),
                )
              : Container(),
          centerTitle: true,
          leading: widget.back != null
              ? IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: appColorBlack,
                  ))
              : Container(),
        ),
        body: isLoading
            ? Center(
                child: loader(context),
              )
            : Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 40, top: 10),
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
                                  child: userImage != '' &&
                                          userImage != null &&
                                          userImage != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(userImage),
                                          radius: 45,
                                        )
                                      : CircleAvatar(
                                          // backgroundColor: Colors.white,
                                          radius: 45,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Image.asset(
                                              'assets/images/user.png',
                                              color: Colors.white,
                                            ),
                                          ))),
                            ),
                            _buildCategory("Posts", modal.userPost),
                            InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FollowingScreen(id: userID)),
                                  );
                                },
                                child: _buildCategory(
                                    "Following", modal.following)),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FollowersScreen(id: userID)),
                                );
                              },
                              child:
                                  _buildCategory("Followers", modal.followers),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          userfullname,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).primaryColorLight),
                        ),
                      ),
                      SizedBox(height: 3),
                      userBio.length != 0
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                userBio,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColorLight),
                              ),
                            )
                          : Container(),
                      // userWeb != null
                      //     ? Padding(
                      //         padding:
                      //             const EdgeInsets.only(left: 20, right: 20),
                      //         child: Linkable(
                      //           style: TextStyle(
                      //               fontWeight: FontWeight.bold,
                      //               color: Colors.blue,
                      //               fontSize: 16),
                      //           text: userWeb,
                      //         ),
                      //       )
                      //     : Container(),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(new MaterialPageRoute(
                                          builder: (_) => new EditProfile()))
                                      .then(
                                          (val) => val ? _getRequests() : null);
                                },
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      border:
                                          Border.all(color: Colors.grey[600]),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: Center(
                                    child: Text(
                                      "Edit Profile",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColorLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          fontFamily: "Poppins-Medium"),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(new MaterialPageRoute(
                                          builder: (_) => new SavedBookmarks()))
                                      .then(
                                          (val) => val ? _getRequests() : null);
                                },
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      border:
                                          Border.all(color: Colors.grey[600]),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: Center(
                                    child: Text(
                                      "Saved Bookmarks",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColorLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          fontFamily: "Poppins-Medium"),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: _userInfo()),
                ],
              ));
  }

  Widget _userInfo() {
    return myPost();
  }

  Widget _buildCategory(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColorLight),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
              color: Theme.of(context).primaryColorLight, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  createThumb(String url) async {
    final uint8list = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight:
          64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );

    return uint8list;
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
                          color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? appColorWhite.withOpacity(0.5)
                                    : Colors.black54,),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ));
  }
}
