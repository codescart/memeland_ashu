import 'dart:async';

import 'dart:io';

import 'package:memeland/global/global.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:memeland/layouts/tabbar/new_tabbar.dart';

import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';


class InstaUploadVideoScreen extends StatefulWidget {
  File video;

  InstaUploadVideoScreen({this.video});

  @override
  _InstaUploadVideoScreenState createState() => _InstaUploadVideoScreenState();
}

class _InstaUploadVideoScreenState extends State<InstaUploadVideoScreen> {
  var _locationController;
  var _captionController;
  VideoPlayerController _videoPlayerController;

  final dio = new Dio();

  @override
  void initState() {
    print('^^^^^^^^^^');
    print(widget.video);
    _pickVideo();
    super.initState();
    _locationController = TextEditingController();
    _captionController = TextEditingController();
  }

  _pickVideo() async {
    // File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    //  widget.video = video;
    _videoPlayerController = VideoPlayerController.file(widget.video)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
      });
  }

  @override
  void dispose() {
    super.dispose();
    _locationController?.dispose();
    _captionController?.dispose();
  }

  bool _visibility = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Post',
          style: TextStyle(
              fontSize: 16, color: appColorBlack, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: new Color(0xfff8faf8),
        elevation: 1.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 20.0),
            child: GestureDetector(
              child: Text('Share',
                  style: TextStyle(color: Colors.blue, fontSize: 16.0)),
              onTap: () {
                uploadData();
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    child: widget.video != null
                        ? _videoPlayerController.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoPlayerController.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController),
                              )
                            : Container(child: Text("Null"))
                        : GestureDetector(
                            onTap: () {
                              _pickVideo();
                            },
                            child: CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    AssetImage('assets/images/ic_add.png'),
                                backgroundColor: Colors.transparent),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                    child: TextField(
                      controller: _captionController,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Write a caption...',
                      ),
                      // onChanged: ((value) {
                      //   _captionController.text = value;
                      // }),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Add location',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: FutureBuilder(
                  future: locateUser(),
                  builder: ((context, AsyncSnapshot<List<Address>> snapshot) {
                    //  if (snapshot.hasData) {
                    if (snapshot.hasData) {
                      return Row(
                        // alignment: WrapAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            child: Chip(
                              label: Text(snapshot.data.first.locality),
                            ),
                            onTap: () {
                              setState(() {
                                _locationController.text =
                                    snapshot.data.first.locality;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: GestureDetector(
                              child: Chip(
                                label: Text(snapshot.data.first.subAdminArea +
                                    ", " +
                                    snapshot.data.first.subLocality),
                              ),
                              onTap: () {
                                setState(() {
                                  _locationController.text =
                                      snapshot.data.first.subAdminArea +
                                          ", " +
                                          snapshot.data.first.subLocality;
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      print("Connection State : ${snapshot.connectionState}");
                      return CircularProgressIndicator();
                    }
                  })),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Offstage(
                child: CircularProgressIndicator(),
                offstage: _visibility,
              ),
            )
          ],
        ),
      ),
    );
  }



  Future<List<Address>> locateUser() async {
    LocationData currentLocation;
    Future<List<Address>> addresses;

    var location = new Location();

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();

      print(
          'LATITUDE : ${currentLocation.latitude} && LONGITUDE : ${currentLocation.longitude}');

      // From coordinates
      final coordinates =
          new Coordinates(currentLocation.latitude, currentLocation.longitude);

      addresses = Geocoder.local.findAddressesFromCoordinates(coordinates);
    } on PlatformException catch (e) {
      print('ERROR : $e');
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
      currentLocation = null;
    }
    return addresses;
  }

  uploadData() {
    VideoThumbnail.thumbnailFile(
      video: widget.video.absolute.path,
      // thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    ).then((value) => apiCall(value));
  }

  apiCall(String value) async {
    print('###########################');
    print(widget.video);
    print(value);
    setState(() {
      _videoPlayerController.setVolume(0);
      _videoPlayerController.pause();
    });
    LoaderDialog().showIndicator(context);
    var url = '${baseUrl()}/add_post';

    print(url);
    String name = DateTime.now().millisecondsSinceEpoch.toString();

    FormData formData = new FormData();

    formData = FormData.fromMap({
      'user_id': userID,
      'text': _captionController.text,
      'location': _locationController.text,
      'video': MultipartFile.fromFileSync(widget.video.absolute.path,
          filename: name + ".mp4"),
      'video_thumbnail': MultipartFile.fromFileSync(
        value,
      ),
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
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => TabbarScreen()),
    // );
  }
}
