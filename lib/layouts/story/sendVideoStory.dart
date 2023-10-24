import 'dart:io';
import 'package:memeland/global/global.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:memeland/layouts/tabbar/new_tabbar.dart';
import 'package:memeland/models/addPostModal.dart';
import 'package:video_player/video_player.dart';

class SendVideoStory extends StatefulWidget {
  final File videoFile;

  SendVideoStory({this.videoFile});

  @override
  ChatBgState createState() => ChatBgState(videoFile: videoFile);
}

class ChatBgState extends State<SendVideoStory> {
  File videoFile;
  ChatBgState({this.videoFile});
  String userId = '';
  var videoSize = '';
  // ignore: unused_field
  double _progress = 0;
  double percentage = 0;
  bool videoloader = false;
  String videoStatus = '';
  final TextEditingController textEditingController = TextEditingController();
  VideoPlayerController _videoPlayerController;
  bool isLoading = false;

  AddPostModal modal;

  @override
  void initState() {
    _pickVideo();

    super.initState();
  }

  _pickVideo() async {
    // File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    //  widget.video = video;
    _videoPlayerController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
      });
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
              color: Colors.black,
            )),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    videoFile != null
                        ? _videoPlayerController.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoPlayerController.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController),
                              )
                            : Center(
                                child: Text(
                                  "Select video",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              )
                        : Container(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
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
                        addPost(context);
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
            ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Container(height: 80, child: buildInput()),
            // ),
            Center(
              child: videoloader == true ? loader(context) : Container(),
            )
          ],
        ),
      ),
    );
  }

  // Widget buildInput() {
  //   SizeConfig().init(context);
  //   final deviceHeight = MediaQuery.of(context).size.height;
  //   final deviceWidth = MediaQuery.of(context).size.width;
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 0, bottom: 10, top: 10),
  //     child: Container(
  //       width: deviceHeight,
  //       decoration: BoxDecoration(color: Colors.transparent),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: <Widget>[
  //           Container(width: 15),
  //           Expanded(
  //             child: Container(
  //               padding: EdgeInsets.only(
  //                 left: 20.0,
  //               ),
  //               height: 47.0,
  //               width: deviceWidth * 0.6,
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(25.0),
  //                 color: Colors.grey[300],
  //               ),
  //               child: TextField(
  //                 controller: textEditingController,
  //                 decoration: InputDecoration(
  //                   border: InputBorder.none,
  //                   hintText: 'Type something about story..',
  //                   hintStyle: TextStyle(
  //                       color: Colors.grey.withOpacity(0.6),
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 13),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           IconButton(
  //             onPressed: () {
  //               addPost(context);
  //             },
  //             icon: Icon(
  //               Icons.send,
  //               color: Colors.white,
  //             ),
  //             iconSize: 32.0,
  //           ),
  //           Container(width: 15),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  addPost(BuildContext context) async {
    final dio = new Dio();
    setState(() {
      _videoPlayerController.setVolume(0);
      _videoPlayerController.pause();
    });

    LoaderDialog().showIndicator(context);
    var url = '${baseUrl()}/add_story';

    print(url);
    String name = DateTime.now().millisecondsSinceEpoch.toString();

    FormData formData = new FormData();
    formData = FormData.fromMap({
      'user_id': userID,
      'url':
          MultipartFile.fromFileSync(videoFile.path, filename: name + ".mp4"),
      'type': 'video'
    });

    // dio.options.headers['accept'] = 'application/json';
    dio.options.contentType = Headers.jsonContentType;

    final response = await dio.post(url,
        data: formData,
        options: Options(method: 'POST', responseType: ResponseType.json));
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Response");
    print(response.data.toString());

    LoaderDialog().hideIndicator(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BottomTabbar()),
      (Route<dynamic> route) => false,
    );
    // if (videoFile != null) {
    //   var files = [];
    //   files.add(videoFile);
    //   setState(() {
    //     videoloader = true;
    //   });
    //   // var timeKey = new DateTime.now();

    //   var uri = Uri.parse('${baseUrl()}/add_story');
    //   var request = new http.MultipartRequest("POST", uri);
    //   Map<String, String> headers = {
    //     "Accept": "application/json",
    //   };
    //   request.headers.addAll(headers);
    //   request.fields['user_id'] = userID;

    //   request.files
    //       .add(await http.MultipartFile.fromPath('video', videoFile.path));

    //   // for (var file in files) {
    //   //   String fileName = file.path.split("/").last;
    //   //   var stream =
    //   //       new http.ByteStream(DelegatingStream.typed(file.openRead()));
    //   //   var length = await file.length(); //imageFile is your image file
    //   //   var multipartFileSign =
    //   //       new http.MultipartFile('image', stream, length, filename: fileName);

    //   //   request.files.add(multipartFileSign);
    //   // }

    //   var response = await request.send();
    //   print(response.statusCode);
    //   String responseData =
    //       await response.stream.transform(utf8.decoder).join();
    //   var userData = json.decode(responseData);
    //   modal = AddPostModal.fromJson(userData);
    //   print(responseData);

    //   if (modal.responseCode == "1") {
    //     Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(builder: (context) => BottomTabbar()),
    //       (Route<dynamic> route) => false,
    //     );
    //     // Navigator.push(
    //     //   context,
    //     //   MaterialPageRoute(builder: (context) => BottomTabbar()),
    //     // );

    //     // Navigator.pushAndRemoveUntil(
    //     //   context,
    //     //   MaterialPageRoute(builder: (context) => Status()),
    //     //   (Route<dynamic> route) => false,
    //     // );
    //   }

    //   setState(() {
    //     videoloader = false;
    //     // Navigator.pop(context);
    //   });
    // } else {
    //   setState(() {
    //     videoloader = false;
    //   });

    //   Fluttertoast.showToast(
    //       msg: "Select Video",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIos: 1,
    //       backgroundColor: Colors.white,
    //       textColor: Colors.black,
    //       fontSize: 16.0);
    // }
  }

  // sendVideo(BuildContext context, String name, String image) async {
  //   //File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

  //   if (widget.videoFile != null) {
  //     setState(() {
  //       _videoPlayerController.pause();
  //       videoloader = true;
  //     });

  //     var timeKey = new DateTime.now();

  //     final StorageReference postImageRef =
  //         FirebaseStorage.instance.ref().child("Story Video");
  //     final StorageUploadTask uploadTask = postImageRef
  //         .child(timeKey.toString() + ".mp4")
  //         .putFile(widget.videoFile);
  //     // ignore: non_constant_identifier_names
  //     var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

  //     Firestore.instance.collection('storyUser').document(userId).setData({
  //       "userId": userId,
  //       "userName": name,
  //       "userImage": image,
  //       "image": ImageUrl,
  //       "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
  //       "mobile": mobNo,
  //       "story": FieldValue.arrayUnion([
  //         {
  //           "image": ImageUrl,
  //           "time": DateTime.now().millisecondsSinceEpoch.toString(),
  //           "type": "video",
  //           "text": textEditingController.text.isEmpty
  //               ? ""
  //               : textEditingController.text
  //         }
  //       ])
  //     }, merge: true).then((value) {
  //       setState(() {
  //         videoloader = false;
  //       });
  //       Navigator.pop(context);
  //     });
  //   }
  // }
}
