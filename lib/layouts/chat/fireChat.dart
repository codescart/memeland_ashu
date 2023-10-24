import 'dart:async';
import 'dart:io';
import 'package:memeland/global/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class FireChat extends StatefulWidget {
  final String peerID;
  final String peerUrl;
  final String peerName;
  // final String peerToken;

  final String currentusername;
  final String currentuserimage;
  final String currentuser;

  FireChat({
    @required this.peerID,
    this.peerUrl,
    @required this.peerName,
    this.currentusername,
    this.currentuserimage,
    this.currentuser,
    //this.peerToken
  });

  @override
  _ChatState createState() => _ChatState(
        peerID: peerID,
        peerUrl: peerUrl,
        peerName: peerName,
        //peerToken: peerToken
      );
}

class _ChatState extends State<FireChat> {
  final String peerID;
  final String peerUrl;
  final String peerName;

  String groupChatId;
  var listMessage;
  File imageFile;
  bool isLoading;
  String imageUrl;
  int limit = 20;
  // String peerToken;
  String peerCode;

  _ChatState({
    @required this.peerID,
    this.peerUrl,
    @required this.peerName,
    //@required this.peerToken
  });

  final TextEditingController textEditingController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  TextEditingController reviewCode = TextEditingController();
  TextEditingController reviewText = TextEditingController();
  double _rating = 5.0;
  Firestore _db = Firestore.instance;

  DatabaseReference _messagesRef;

  String _messageText = "Hello Message";

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String peerToken;

  @override
  void initState() {
    getPeerToken();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        //peerToken = "Push Messaging token: $token";
      });
      // print(peerToken);
    });

    // _callUserDataFromSharedPrefs();
    // getPeerToken();
    super.initState();

    groupChatId = '';
    isLoading = false;

    imageUrl = '';

    readLocal();
    removeBadge();
    setState(() {});
  }

//  Future _callUserDataFromSharedPrefs() async {
//    FutureBuilder(
//      future: FirebaseAuth.instance.currentUser(),
//      builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
//        if (snapshot.hasData) {
//          userData = snapshot.data.uid.toString();
//          return Text("");
//        } else {
//          return Text('Loading...');
//        }
//      },
//    );
//  }

  removeBadge() async {
    await Firestore.instance
        .collection("chatList")
        .document(widget.currentuser)
        .collection(widget.currentuser)
        .document(peerID)
        .updateData({'badge': '0'});
  }

  void _scrollListener() {
    if (listScrollController.position.pixels ==
        listScrollController.position.maxScrollExtent) {
      startLoader();
    }
  }

  void startLoader() {
    setState(() {
      isLoading = true;
      fetchData();
    });
  }

  fetchData() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, onResponse);
  }

  void onResponse() {
    setState(() {
      isLoading = false;
      limit = limit + 20;
    });
  }

  readLocal() {
    if (widget.currentuser.hashCode <= peerID.hashCode) {
      groupChatId = '${widget.currentuser}-$peerID';
    } else {
      groupChatId = '$peerID-${widget.currentuser}';
    }
  }

  @override
  Widget build(BuildContext context) {
    listScrollController = new ScrollController()..addListener(_scrollListener);
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          title: Text(
            widget.peerName,
            style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          // actions: <Widget>[
          //   FlatButton(
          //     textColor: Colors.black,
          //     onPressed: () {
          //       // Navigator.pop(context);
          //     },
          //     child: Text(
          //       "",
          //       style: TextStyle(
          //           color: Colors.black,
          //           fontSize: 17,
          //           fontWeight: FontWeight.bold),
          //     ),
          //     shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          //   ),
          // ],
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(40),
                      topLeft: Radius.circular(40)),
                ),
                child: Column(
                  children: <Widget>[
                    buildListMessage(),

                    // Input content
                    buildInput(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: isLoading
                  ? Container(
                      padding: EdgeInsets.all(5),
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey[200])))
                  : Container(),
            ),
          ],
        ));
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appColor)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(appColor)));
                } else {
                  listMessage = snapshot.data.documents;
                  return Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 1.0), //(x,y)
                            blurRadius: 1.0,
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildItem(index, snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                        reverse: true,
                        controller: listScrollController,
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference =
        FirebaseStorage.instance.ref().child("ChatMedia").child(fileName);

    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      // Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == widget.currentuser) {
      // Right (my message)
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              document['type'] == 0
                  // Text
                  ? Container(
                      child: Text(
                        document['content'],
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 13),
                      ),
                      padding: EdgeInsets.fromLTRB(20.0, 13.0, 10.0, 13.0),
                      width: 200.0,
                      decoration: BoxDecoration(
                          color: Color(0xFFe1cbe7),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 10.0 : 10.0,
                          right: 10.0),
                    )
                  : Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(appColor),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: Color(0xffE8E8E8),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Text("Not Avilable"),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document['content'],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          imagePreview(
                            document['content'],
                          );
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
          isLastMessageRight(index)
              ? Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document['timestamp']))),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                        fontStyle: FontStyle.normal),
                  ),
                  margin: EdgeInsets.only(right: 10.0),
                )
              : Container()
        ],
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: peerUrl != null
                            ? CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(appColor),
                                  ),
                                  width: 35.0,
                                  height: 35.0,
                                  padding: EdgeInsets.all(10.0),
                                ),
                                imageUrl: peerUrl,
                                width: 35.0,
                                height: 35.0,
                                fit: BoxFit.cover,
                              )
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.person,
                                  size: 25,
                                ),
                              ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                document['type'] == 0
                    ? Container(
                        child: Text(
                          document['content'],
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 13),
                        ),
                        padding: EdgeInsets.fromLTRB(20.0, 13.0, 10.0, 13.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Color(0xFFc4d1ec),
                            // border: Border.all(color: Color(0xffE8E8E8)),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : Container(
                        child: FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(appColor),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Material(
                                child: Text("Not Avilable"),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: document['content'],
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
                            imagePreview(document['content']);
                          },
                          padding: EdgeInsets.all(0),
                        ),
                        margin: EdgeInsets.only(left: 10.0),
                      ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                          fontStyle: FontStyle.normal),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == widget.currentuser) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != widget.currentuser) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> onSendMessage(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker
    int badgeCount = 0;
    print(content);
    print(content.trim());
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': widget.currentuser,
            'idTo': peerID,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      }).then((onValue) async {
        await Firestore.instance
            .collection("chatList")
            .document(widget.currentuser)
            .collection(widget.currentuser)
            .document(peerID)
            .setData({
          'id': peerID,
          'name': peerName,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'badge': '0',
          'profileImage': peerUrl,
        }).then((onValue) async {
          try {
            await Firestore.instance
                .collection("chatList")
                .document(peerID)
                .collection(peerID)
                .document(widget.currentuser)
                .get()
                .then((doc) async {
              debugPrint(doc.data["badge"]);
              if (doc.data["badge"] != null) {
                badgeCount = int.parse(doc.data["badge"]);
                await Firestore.instance
                    .collection("chatList")
                    .document(peerID)
                    .collection(peerID)
                    .document(widget.currentuser)
                    .setData({
                  'id': widget.currentuser,
                  'name': "${widget.currentusername}",
                  'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                  'content': content,
                  'badge': '${badgeCount + 1}',
                  'profileImage': widget.currentuserimage,
                });
              }
            });
          } catch (e) {
            await Firestore.instance
                .collection("chatList")
                .document(peerID)
                .collection(peerID)
                .document(widget.currentuser)
                .setData({
              'id': widget.currentuser,
              'name': "${widget.currentusername}",
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
              'content': content,
              'badge': '${badgeCount + 1}',
              'profileImage': widget.currentuserimage,
            });
            print(e);
          }
        });
      });

      print("peerToken>>>>>>>>>>>>>" + peerToken.toString());
      print("CImage>>>>>>>>>>>>>" + widget.currentuserimage.toString());

      String notificationPayload =
          "{\"to\":\"${peerToken}\",\"priority\":\"high\",\"data\":{\"type\":\"100\",\"user_id\":\"${widget.currentuser}\",\"user_name\":\"${widget.currentusername}\",\"user_pic\":\"${widget.currentuserimage}\",\"user_device_type\":\"android\",\"msg\":\"${content}\",\"time\":\"${DateTime.now().millisecondsSinceEpoch}\"},\"notification\":{\"title\":\"${widget.currentusername}\",\"body\":\"$content\",\"user_id\":\"${widget.currentuser}\",\"user_pic\":\"${widget.currentuserimage}\",\"user_device_type\":\"android\",\"sound\":\"default\"},\"priority\":\"high\"}";
      createNotification(notificationPayload);

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      print('Nothing to send');
      // Fluttertoast.showToast(
      //     msg: 'Nothing to send', backgroundColor: Colors.red);
    }
  }

  Widget buildInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Container(
        margin: safeQueries(context) ? EdgeInsets.only(bottom: 25) : null,
        child: Row(
          children: <Widget>[
            // Button send image
            Material(
              child: new Container(
                margin: new EdgeInsets.symmetric(horizontal: 1.0),
                child: new IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    getImage();
                  },
                  // color: primaryColor,
                ),
              ),
              color: Colors.white,
            ),

            // Edit text
            Flexible(
              child: Container(
                child: TextField(
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type your message...',
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
                    color: Colors.grey[700],
                  ),
                  onPressed: () {
                    onSendMessage(textEditingController.text, 0);
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
            border:
                new Border(top: new BorderSide(color: Colors.grey, width: 0.7)),
            color: Colors.white),
      ),
    );
  }

  imagePreview(String url) {
    return showDialog(
      context: context,
      builder: (_) => Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 10, right: 10, bottom: 100),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                child: PhotoView(
                  imageProvider: NetworkImage(url),
                ),
              ),
            ),
          ),
          //buildFilterCloseButton(context),
        ],
      ),
    );
  }

  Widget buildFilterCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.black.withOpacity(0.0),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<http.Response> createNotification(String sendNotification) async {
    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            "key=AAAAv8_cZvc:APA91bFSSJArNzIaOV7CTLvo_lfEEjs_-wFvwR2WaSuZn7sV2RX8Cu2jsliXGbgimOjqod2pntfRvnIsijyhp2iDt8XJCGQEj0f8vvBLuQSsDrs-pFMJ0OXaoMRAHtqQe-m1sihHl-Cm"
//          HttpHeaders.authorizationHeader:
//              "key=AAAAdlUezOQ:APA91bH9mRwxoUQujG3NGnkAmV0XFGW8zYGseKjPmLQOZqX9pcl4Zzm32qoNgBacwPvVPkRrH7auS6VGEDti558GpYAmiksVI0mPZf9N-ltZrKQQlh6TnTL5_tz3HdtRCso1hK1dqH2v"
      },
      body: sendNotification,
    );
    return response;
  }

  getPeerToken() async {
    final FirebaseDatabase database = new FirebaseDatabase();

    database
        .reference()
        .child('user')
        .child(peerID)
        .orderByChild("token")
        .once()
        .then((peerData) {
      print('Connected to the database and read ${peerData.value["token"]}');

      peerToken = peerData.value['token'];
    });

//    Firestore.instance
//        .collection('users')
//        .document(peerID)
//        .get()
//        .then((peerData) {
//      peerToken = peerData.data['deviceToken'];
//      peerCode = peerData.data['code'];
//    });
  }
}
