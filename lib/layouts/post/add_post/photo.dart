import 'package:flutter/material.dart';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:memeland/global/global.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/photofilters.dart';
import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as imageLib;
import 'package:memeland/layouts/post/add_post/addvideoPost.dart';
import 'package:memeland/layouts/post/add_post/insta_upload_photo_screen.dart';
import 'package:video_compress/video_compress.dart';

import 'package:video_player/video_player.dart';

class PhotoScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  PhotoScreen({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _MyHomePageState extends State<PhotoScreen> {
  AppState state;
  File imageFile;

  bool selectPhoto = false;

  bool selectVideo = false;
  bool isLoading = false;
  File _video;
  //File _cameraVideo;

  VideoPlayerController _videoPlayerController;
  // ignore: unused_field
  VideoPlayerController _cameraVideoPlayerController;

  List<File> alldata = [];

  var savedimageUrls = [];

  @override
  void initState() {
    super.initState();
    state = AppState.free;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'New post',
          style: TextStyle(
              fontSize: 16, color: Theme.of(context).primaryColorLight, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (alldata.length > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            InstaUploadPhotoScreen(image: alldata)),
                  );
                } else if (_video != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            InstaUploadVideoScreen(video: _video)),
                  );

                  setState(() {
                    _videoPlayerController.setVolume(0);
                    _videoPlayerController.pause();
                  });
                }
              },
              child: Text('Next'))
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
      ),

      body: Stack(
        children: [
          Center(
            child: Column(
              children: <Widget>[
                selectPhoto == true
                    ? Expanded(
                        child: Padding(
                        padding: const EdgeInsets.only(bottom: 0, top: 20),
                        child: alldata.length > 0
                            ? Container(
                                height: SizeConfig.safeBlockVertical * 17,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    alldata.length > 0
                                        ? Expanded(
                                            child: ListView.builder(
                                                scrollDirection: Axis.vertical,
                                                itemCount: alldata.length,
                                                itemBuilder: (BuildContext ctxt,
                                                    int index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              new BoxDecoration(
                                                            color: Colors
                                                                .grey[300],
                                                            borderRadius:
                                                                new BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  8.0),
                                                            ),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            child: Image.file(
                                                              alldata[index],
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  alldata.remove(
                                                                      alldata[
                                                                          index]);
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black45,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .white)),
                                                                child: Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 20,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: InkWell(
                                                              onTap: () {
                                                                getImage(
                                                                  context,
                                                                  alldata[
                                                                      index],
                                                                );
                                                              },
                                                              child: Chip(
                                                                label: Text(
                                                                  "Apply Filter",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          SizeConfig.blockSizeHorizontal *
                                                                              3.5),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          )
                                        : Container()
                                  ],
                                ))
                            : Center(
                                child: Text(
                                  "Select photo or video",
                                  style: TextStyle(
                                    color: appColor,
                                  ),
                                ),
                              ),
                      ))
                    : Expanded(
                        child: Padding(
                        padding: const EdgeInsets.only(bottom: 20, top: 50),
                        child: _video != null
                            ? _videoPlayerController.value.isInitialized
                                ? Center(
                                    child: AspectRatio(
                                      aspectRatio: _videoPlayerController
                                          .value.aspectRatio,
                                      child:
                                          VideoPlayer(_videoPlayerController),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      "Select photo or video",
                                      style: TextStyle(
                                        color: appColor,
                                      ),
                                    ),
                                  )
                            : Center(
                                child: Text(
                                  "Select photo or video",
                                  style: TextStyle(
                                    color: appColor,
                                  ),
                                ),
                              ),
                      )),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 40, right: 40, bottom: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: selectPhoto == true
                              ? Column(
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        //selectImageSource();
                                        selectImageSource();
                                      },
                                      child: Text(
                                        "Photo",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: appColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                      child: new Center(
                                        child: new Container(
                                          width: 60,
                                          margin:
                                              new EdgeInsetsDirectional.only(
                                                  start: 1.0, end: 1.0),
                                          height: 3.0,
                                          color: appColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectPhoto = true;
                                      selectVideo = false;
                                    });
                                    selectImageSource();

                                    //selectImageSource();
                                  },
                                  child: Text(
                                    "Photo",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: appColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins-Medium"),
                                  ))),
                      Expanded(
                        child: selectVideo == true
                            ? Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      selectVideoSource();
                                    },
                                    child: Text(
                                      "Video",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: appColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Poppins-Medium"),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                    child: new Center(
                                      child: new Container(
                                        width: 60,
                                        margin: new EdgeInsetsDirectional.only(
                                            start: 1.0, end: 1.0),
                                        height: 3.0,
                                        color: appColor,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectPhoto = false;
                                    selectVideo = true;
                                  });

                                  selectVideoSource();
                                },
                                child: Text(
                                  "Video",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: appColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins-Medium"),
                                )),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Center(
                  child: loader(context),
                )
              : Container()
        ],
      ),
      // floatingActionButton: imageFile != null
      //     ? FloatingActionButton(
      //         backgroundColor: appColor,
      //         onPressed: () {
      //           // if (state == AppState.free)
      //           //  selectImageSource();
      //           if (state == AppState.picked)
      //             _cropImage();
      //           else if (state == AppState.cropped) _clearImage();
      //         },
      //         child: _buildButtonIcon(),
      //       )
      //     : Container(),
    );
  }

  // Widget _buildButtonIcon() {
  //   // if (state == AppState.free)
  //   //   return Icon(Icons.add);
  //   if (state == AppState.picked)
  //     return Icon(Icons.crop);
  //   else if (state == AppState.cropped)
  //     return Icon(Icons.clear);
  //   else
  //     return Container();
  // }

  Future<Null> getImageFromGallery() async {
    // ignore: deprecated_member_use
    imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
    }
  }

  // ignore: unused_element
  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: appColor,
            toolbarWidgetColor: Colors.white,
            statusBarColor: appColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: '',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  // ignore: unused_element
  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }

  // _pickVideo() async {
  //   File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
  //   _video = video;
  //   _videoPlayerController = VideoPlayerController.file(_video)
  //     ..initialize().then((_) {
  //       setState(() {});
  //       _videoPlayerController.play();
  //     });
  // }

  _pickVideo() async {
    var video = await ImagePicker().getVideo(source: ImageSource.gallery);

    if (video != null) {
      indicatorDialog(context);
      await VideoCompress.setLogLevel(0);

      final compressedVideo = await VideoCompress.compressVideo(
        video.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (compressedVideo != null) {
        Navigator.pop(context);
        setState(() {
          _video = File(compressedVideo.path);
        });
        _videoPlayerController =
            VideoPlayerController.file(File(compressedVideo.path))
              ..initialize().then((_) {
                setState(() {
                  _videoPlayerController.play();
                });
              });
      } else {
        debugPrint('error in compressing video from gallery');
      }
    }
  }

  // _pickVideoFromCamera() async {
  //   File video = await ImagePicker.pickVideo(source: ImageSource.camera);
  //   _video = video;
  //   _videoPlayerController = VideoPlayerController.file(_video)
  //     ..initialize().then((_) {
  //       setState(() {});
  //       _videoPlayerController.play();
  //     });
  // }

  _pickVideoFromCamera() async {
    var video = await ImagePicker().getVideo(source: ImageSource.camera);

    if (video != null) {
      indicatorDialog(context);
      await VideoCompress.setLogLevel(0);

      final compressedVideo = await VideoCompress.compressVideo(
        video.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (compressedVideo != null) {
        Navigator.pop(context);
        setState(() {
          _video = File(compressedVideo.path);
        });

        _videoPlayerController =
            VideoPlayerController.file(File(compressedVideo.path))
              ..initialize().then((_) {
                setState(() {
                  _videoPlayerController.play();
                });
              });
        // Navigator.pop(
        //   context,
        // );
      } else {
        debugPrint('error in compressing video from camera');
      }
    }
  }

  selectVideoSource() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(height: 10.0),
              Text(
                "Pick Video",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Poppins-Medium"),
              ),
              Container(height: 30.0),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromCamera();
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.camera_alt,
                      color: appColor,
                    ),
                    Container(width: 10.0),
                    Text('Camera',
                        style: TextStyle(fontFamily: "Poppins-Medium"))
                  ],
                ),
              ),
              Container(height: 15.0),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.storage,
                      color: appColor,
                    ),
                    Container(width: 10.0),
                    Text('Gallery',
                        style: TextStyle(fontFamily: "Poppins-Medium"))
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  selectImageSource() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(height: 10.0),
              Text(
                "Pick Image",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Poppins-Medium",
                ),
              ),
              Container(height: 10.0),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  getImageFromCamera();
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.camera_alt,
                      color: appColor,
                    ),
                    Container(width: 10.0),
                    Text('Camera',
                        style: TextStyle(fontFamily: "Poppins-Medium"))
                  ],
                ),
              ),
              Container(height: 15.0),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // getImages();
                  // getImageFromGallery();
                  getImageFromG();
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.storage,
                      color: appColor,
                    ),
                    Container(width: 10.0),
                    Text('Gallery',
                        style: TextStyle(fontFamily: "Poppins-Medium"))
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // getImageFromCamera() async {
  //   var imageFile = await ImagePicker.pickImage(
  //     source: ImageSource.camera,
  //     imageQuality: 50,
  //   );

  //   setState(() {
  //     alldata.add(imageFile);
  //   });
  // }

  Future getImageFromCamera() async {
    var image = await ImagePicker().getImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image != null) {
      indicatorDialog(context);
      final dir = await getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 30,
      ).then((value) async {
        Navigator.pop(context);
        setState(() {
          // isLoading = false;
          imageFile = value;
          alldata.add(imageFile);
          state = AppState.picked;
        });
      });
    }
  }

  // getImageFromG() async {
  //   var imageFile = await ImagePicker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 50,
  //   );

  //   setState(() {
  //     alldata.add(imageFile);
  //   });
  // }

  Future getImageFromG() async {
    var image = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      indicatorDialog(context);
      final dir = await getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 40,
      ).then((value) async {
        Navigator.pop(context);
        setState(() {
          imageFile = value;
          alldata.add(imageFile);
          state = AppState.picked;
        });
      });
    }
  }

  /* filter preset */

  List<Filter> filters = presetFiltersList;
  String fileName;

  Future getImage(context, image2) async {
    //  imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    fileName = path.basename(image2.path);
    var image = imageLib.decodeImage(image2.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
    Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => Container(
          child: new PhotoFilterSelector(
            title: Text(
              "Photo Customization",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Poppins-Medium",
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            image: image,
            filters: presetFiltersList,
            filename: fileName,
            loader: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.grey[400]))),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        isLoading = false;

        var finalimage = imagefile['image_filtered'];
        alldata.add(finalimage);
        alldata.remove(image2);
      });
      print(image2.path);
    }
  }

  /* filter preset */
}
