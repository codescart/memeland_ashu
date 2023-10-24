import 'dart:convert';
import 'package:memeland/layouts/chat/chat_list.dart';
import 'package:memeland/layouts/homefeeds.dart';
import 'package:memeland/layouts/post/add_post/photo.dart';
import 'package:memeland/layouts/search/search_new.dart';
import 'package:memeland/layouts/user/profile.dart';
import 'package:memeland/layouts/widgets/DrawerWidget.dart';
import 'package:memeland/models/followersModal.dart';
import 'package:memeland/models/followingModal.dart';
import 'package:memeland/models/loginModal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memeland/global/global.dart';
import 'package:memeland/trending.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:memeland/shared_preferences/preferencesKey.dart';

// ignore: must_be_immutable
class BottomTabbar extends StatefulWidget {
  Widget currentPage = ImagesVideosFeeds();
  var currentTab;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  BottomTabbar({Key key, this.currentTab}) {
    currentTab = currentTab != null ? currentTab : 0;
  }
  @override
  _BottomTabbarState createState() {
    return _BottomTabbarState();
  }
}

class _BottomTabbarState extends State<BottomTabbar> {
  @override
  void didUpdateWidget(BottomTabbar oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  FollowersModal followersModal;
  FollwingModal follwingModal;
  // ignore: unused_field
  static double _height, _width, _fixedPadding;
  int currentPage = 0;
  LoginModal model;

  // List pages = [
  //   ImagesVideosFeeds(),
  //   SerchFeed(),
  //   // SearchRestaurent(),
  //   PhotoScreen(),
  //   FireChatList(),
  //   Profile()
  //   //  Profile()
  // ];

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage =
              ImagesVideosFeeds(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 1:
          //widget.currentPage = Trending(parentScaffoldKey: widget.scaffoldKey);
          widget.currentPage = SerchFeed(parentScaffoldKey: widget.scaffoldKey);
          break;

        case 2:
          widget.currentPage =
              PhotoScreen(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 3:
          widget.currentPage = ChatList(parentScaffoldKey: widget.scaffoldKey);
          break;

        case 4:
          widget.currentPage = Profile(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }

  @override
  void initState() {
    globleFollowers = [];
    globleFollowing = [];
    _selectTab(widget.currentTab);
    getUserDataFromPrefs();

    super.initState();
  }

  getUserDataFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String userDataStr =
        preferences.getString(SharedPreferencesKey.LOGGED_IN_USERRDATA);
    Map<String, dynamic> userData = json.decode(userDataStr);
    model = LoginModal.fromJson(userData);

    setState(() {
      userID = model.user.id;
      userImage = model.user.profilePic;
      userName = model.user.username;
      userfullname = model.user.fullname;
      userEmail = model.user.email;
      userBio = model.user.bio;
      userPhone = model.user.phone;
      userGender = model.user.gender;
      intrestarray = model.user.interestsId;

      _getFollowers(model.user.id);
      _getFollowing(model.user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.025;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        body: widget.currentPage,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          // ignore: deprecated_member_use
          selectedItemColor: appColor,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 22,
          elevation: 0,

          backgroundColor: Colors.transparent,
          selectedIconTheme: IconThemeData(size: 28),
          unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
          currentIndex: widget.currentTab,

          onTap: (int i) {
            this._selectTab(i);
          },
          // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house), label: ''),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.bolt_fill), label: ''),
            BottomNavigationBarItem(
                icon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: appColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //       color: Theme.of(context).accentColor.withOpacity(0.4),
                    //       blurRadius: 40,
                    //       offset: Offset(0, 15)),
                    //   BoxShadow(
                    //       color: Theme.of(context).accentColor.withOpacity(0.4),
                    //       blurRadius: 40,
                    //       offset: Offset(0, 3))
                    // ],
                  ),
                  child: new Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                label: ''),
            BottomNavigationBarItem(
                icon: new Icon(CupertinoIcons.chat_bubble), label: ''),
            BottomNavigationBarItem(
                icon: new Icon(CupertinoIcons.person), label: ''),
          ],
        ),
      ),
    );
  }

  _getFollowers(id) async {
    var uri = Uri.parse('${baseUrl()}/my_followers');
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
}
