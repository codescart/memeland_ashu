import 'dart:convert';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:memeland/global/global.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:memeland/layouts/user/publicProfile.dart';
import 'package:memeland/models/followersModal.dart';

class FollowersScreen extends StatefulWidget {
  final String id;
  FollowersScreen({this.id});

  @override
  _Discover1State createState() => _Discover1State(id: id);
}

class _Discover1State extends State<FollowersScreen> {
  final String id;
  _Discover1State({this.id});
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  final dio = new Dio();
  FollowersModal modal;

  @override
  void initState() {
    print(id);
    _getFollowers();

    super.initState();
  }

  _getFollowers() async {
    setState(() {
      isLoading = true;
    });
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
    modal = FollowersModal.fromJson(userData);
    print(modal.status);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor:Theme.of(context).scaffoldBackgroundColor,
            elevation: 0.5,
            title: Text(
              "Followers",
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
          body: LayoutBuilder(
            builder: (context, constraint) {
              return _designPage();
            },
          )),
    );
  }

  Widget _designPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 20),
      child: Container(
          child: isLoading
              ? Center(
                  child: loader(context),
                )
              : modal != null && modal.follower.length > 0
                  ? new ListView.separated(
                      itemCount: modal.follower.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PublicProfile(
                                        peerId:
                                            modal.follower[index].followUserId,
                                        peerUrl:
                                            modal.follower[index].profilePic,
                                        peerName:
                                            modal.follower[index].username,
                                      )),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, bottom: 5, left: 22),
                                child: Container(
                                  child: Container(
                                    width: SizeConfig.screenWidth,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                              child:
                                                  CupertinoActivityIndicator(),
                                              width: 35.0,
                                              height: 35.0,
                                              padding: EdgeInsets.all(10.0),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Material(
                                              color: Colors.grey[300],
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(0.0),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 35,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                              clipBehavior: Clip.hardEdge,
                                            ),
                                            imageUrl: modal
                                                .follower[index].profilePic,
                                            width: 50.0,
                                            height: 50.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(120.0),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                        SizedBox(
                                            width:
                                                SizeConfig.blockSizeHorizontal *
                                                    2),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, top: 15),
                                            child: Text(
                                              modal.follower[index].username,
                                              style: TextStyle(
                                                color: Theme.of(context).primaryColorLight,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                SizeConfig.blockSizeHorizontal *
                                                    3),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Container(
                                              child: IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.arrow_forward_ios),
                                            color:Theme.of(context).primaryColorLight,
                                            iconSize: 25,
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 30,
                          color: Theme.of(context).hintColor.withOpacity(0.1),
                        );
                      })
                  : Center(
                      child: Text(
                        "User list is empty",
                        style: TextStyle(color: Theme.of(context).primaryColorLight),
                      ),
                    )),
    );
  }
}
