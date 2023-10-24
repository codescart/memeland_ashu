import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:memeland/global/global.dart';

import 'package:async/async.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'package:memeland/layouts/tabbar/new_tabbar.dart';

// ignore: must_be_immutable
class InstaUploadPhotoScreen extends StatefulWidget {
  List image;

  InstaUploadPhotoScreen({this.image});

  @override
  _InstaUploadPhotoScreenState createState() => _InstaUploadPhotoScreenState();
}

class _InstaUploadPhotoScreenState extends State<InstaUploadPhotoScreen> {
  var _locationController;
  var _captionController;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _locationController = TextEditingController();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _locationController?.dispose();
    _captionController?.dispose();
  }

  bool _visibility = true;

  // void _changeVisibility(bool visibility) {
  //   setState(() {
  //     _visibility = visibility;
  //   });
  // }

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
                apiCall(widget.image);
              },
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(widget.image[0]))),
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
              // onChanged: ((value) {
              //   setState(() {
              //     _locationController.text = value;
              //   });
              // }),
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
    );
  }

  // void compressImage() async {
  //   print('starting compression');
  //   final tempDir = await getTemporaryDirectory();
  //   final path = tempDir.path;
  //   int rand = Random().nextInt(10000);

  //   Im.Image image = Im.decodeImage(widget.imageFile.readAsBytesSync());
  //   Im.copyResize(image, 500);

  //   var newim2 = new File('$path/img_$rand.jpg')
  //     ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

  //   setState(() {
  //     widget.imageFile = newim2;
  //   });
  //   print('done');
  // }

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

  apiCall(List<File> files) async {
    LoaderDialog().showIndicator(context);
    var uri = Uri.parse('${baseUrl()}/add_post');

// create multipart request
    var request = new http.MultipartRequest("POST", uri);
    print("♞♞♞♞♞♞♞" + userID + "♞♞♞♞♞♞♞");

    for (var file in files) {
      String fileName = file.path.split("/").last;
      // ignore: deprecated_member_use
      var stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
      var length = await file.length(); //imageFile is your image file
      var multipartFileSign =
          new http.MultipartFile('image[]', stream, length, filename: fileName);

      request.files.add(multipartFileSign);
    }

    Map<String, String> headers = {
      "Accept": "application/json",
    };

//add headers
    request.headers.addAll(headers);

//adding params
    request.fields['user_id'] = userID;
    request.fields['text'] = _captionController.text;
    request.fields['location'] = _locationController.text;

// send
    var response = await request.send();

    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    print(userData);

    LoaderDialog().showIndicator(context);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BottomTabbar()),
      (Route<dynamic> route) => false,
    );
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => TabbarScreen()),
    // );
    //   String responseData = await response.stream
    //       .transform(utf8.decoder)
    //       .join(); // decodes on response data using UTF8.decoder
    //   Map data = json.decode(responseData);
    //  print(data["response_code"]); // Parse data from JSON string
  }
}
