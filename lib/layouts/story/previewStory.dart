import 'dart:convert';
import 'dart:io';
import 'package:memeland/global/global.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:memeland/layouts/tabbar/new_tabbar.dart';
import 'package:memeland/models/addPostModal.dart';

// ignore: must_be_immutable
class PreviewStory extends StatefulWidget {
  File imageFile;
  PreviewStory({this.imageFile});
  @override
  ChatBgState createState() {
    return new ChatBgState();
  }
}

class ChatBgState extends State<PreviewStory> {
  String userId = '';
  bool isLoading = false;

  AddPostModal modal;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Preview",
          style: TextStyle(
              fontSize: 16, color: appColorBlack, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.blue,
            )),
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: widget.imageFile != null
                      ? SizedBox(
                          child: Image.file(
                          widget.imageFile,
                          fit: BoxFit.contain,
                        ))
                      : Center(
                          child: Text(
                            "Select photo",
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Poppins-Medium",
                            ),
                          ),
                        ),
                ),
                Container(
                  height: 45,
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      )),
                      Container(
                          height: double.infinity,
                          width: 0.8,
                          color: Colors.black),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          addPost(context, widget.imageFile);
                        },
                        child: Text("Send",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ))
                    ],
                  ),
                ),
              ],
            ),
            Center(child: isLoading == true ? loader(context) : Container())
          ],
        ),
      ),
    );
  }

  // _uploadPost(String postid) async {
  //   // setState(() {
  //   //   isLoading = true;
  //   // });

  //   // setState(() {
  //   //   isLoading = false;
  //   // });
  // }

  addPost(BuildContext context, File image) async {
    if (widget.imageFile != null) {
      var files = [];
      files.add(image);
      setState(() {
        isLoading = true;
      });
      // var timeKey = new DateTime.now();

      var uri = Uri.parse('${baseUrl()}/add_story');
      var request = new http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        "Accept": "application/json",
      };
      request.headers.addAll(headers);
      request.fields['user_id'] = userID;

      request.files
          .add(await http.MultipartFile.fromPath('url', widget.imageFile.path));
      request.fields['type'] = 'image';

      // for (var file in files) {
      //   String fileName = file.path.split("/").last;
      //   var stream =
      //       new http.ByteStream(DelegatingStream.typed(file.openRead()));
      //   var length = await file.length(); //imageFile is your image file
      //   var multipartFileSign =
      //       new http.MultipartFile('image', stream, length, filename: fileName);

      //   request.files.add(multipartFileSign);
      // }

      var response = await request.send();
      print(response.statusCode);
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      modal = AddPostModal.fromJson(userData);
      print(responseData);

      if (modal.responseCode == "1") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BottomTabbar()),
        );

        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => Status()),
        //   (Route<dynamic> route) => false,
        // );
      }

      setState(() {
        isLoading = false;
        // Navigator.pop(context);
      });
    } else {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
          msg: "Select Image",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          // timeInSecForIos: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  // getData() async {
  //   final FirebaseDatabase database = new FirebaseDatabase();

  //   database
  //       .reference()
  //       .child('user')
  //       .child(userId)
  //       .orderByChild("token")
  //       .once()
  //       .then((peerData) {
  //     // peerToken = peerData.value['token'];
  //   });
  // }
}
