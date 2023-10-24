import 'package:memeland/Helper/sizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// ignore: must_be_immutable
class VideoViewFix extends StatefulWidget {
  final String url;
  final bool play;
  bool mute;
  final String id;

  VideoViewFix({this.url, this.play, this.id, this.mute});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<VideoViewFix> with WidgetsBindingObserver {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  VideoPlayerController controller;

  Duration duration, position;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = VideoPlayerController.network(
      widget.url,
      //closedCaptionFile: _loadCaptions(),
    );

    controller.addListener(() {
      if (mounted) setState(() {});
    });
    controller.setLooping(true);
    controller.initialize();

    // if (widget.play != null && widget.play == true) {
    //   controller.play();
    //   controller.setLooping(true);
    // }

    // duration = controller.value.duration;
    // position = controller.value.position;
    // if (duration != null && position != null)
    //   position = (position > duration) ? duration : position;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('didChangeAppLifecycleState CALLED ✅');
    print(state);

    switch (state) {
      case AppLifecycleState.inactive:
        setState(() {
          controller.setVolume(0.0);
        });
        print('AppLifecycleState inactive');
        break;
      case AppLifecycleState.resumed:
        setState(() {
          controller.setVolume(0.5);
        });
        print('AppLifecycleState resumed');
        break;
      case AppLifecycleState.paused:
        setState(() {
          controller.setVolume(0.0);
        });
        print('AppLifecycleState paused');
        break;
      case AppLifecycleState.detached:
        setState(() {
          controller.setVolume(0.0);
        });
        print('AppLifecycleState detached');
        break;
    }

    // if (state == AppLifecycleState.inactive &&
    //     state == AppLifecycleState.paused) {
    //   print('if called ✅');
    //   setState(() {
    //     controller.setVolume(0.0);
    //   });
    // } else {
    //   print('if called ✅');
    //   setState(() {
    //     controller.setVolume(0.5);
    //   });
    // }
  }

  @override
  void didUpdateWidget(VideoViewFix oldWidget) {
    if (widget.play != null &&
        widget.play == true &&
        oldWidget.play != widget.play) {
      if (widget.play) {
        controller.play();
        controller.setLooping(true);
      } else {
        controller.pause();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Center(
            child: ClipRRect(
              child: Container(
                height: SizeConfig.blockSizeVertical * 40,
                child: controller.value.isInitialized
                    ? Center(
                        child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VisibilityDetector(
                                key: Key(DateTime.now()
                                    .microsecondsSinceEpoch
                                    .toString()),
                                onVisibilityChanged: (VisibilityInfo info) {
                                  debugPrint(
                                      "${info.visibleFraction} of my widget is visible");
                                  if (info.visibleFraction <= 0.70) {
                                    if (controller != null) controller.pause();
                                  } else {
                                    if (controller != null) controller.play();
                                  }
                                },
                                child: Stack(
                                  children: [
                                    VideoPlayer(controller),
                                    // VideoProgressIndicator(controller,
                                    //     allowScrubbing: false),

                                    // _PlayPauseOverlay(
                                    //     controller: controller,
                                    //     mute: widget.mute),
                                  ],
                                ))),
                      )
                    : AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: Container(
                            // height: 40,
                            // width: 40,
                            child: Center(
                          child: CircularProgressIndicator(),
                        )),
                      ),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, VideoPlayerValue value, child) {
              return Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      value.position.inMinutes.toString() +
                          ":" +
                          value.position.inSeconds.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
          _overlayWidget(controller),
        ],
      ),
    );
  }

  Widget _overlayWidget(VideoPlayerController controller) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomRight,
        child: RawMaterialButton(
          constraints: BoxConstraints.tight(Size(36, 36)),
          onPressed: () {
            print('Button is Pressed');

            if (widget.mute == false) {
              setState(() {
                widget.mute = true;
              });
              // controller.setVolume(20.0);
              print('********if********');
              print(widget.mute);
            } else {
              setState(() {
                widget.mute = false;
                // controller.setVolume(0.0);
              });
              print('********else********');
              print(widget.mute);
            }

            // controller.pause();
            widget.mute ? controller.setVolume(0.0) : controller.setVolume(0.5);
          },
          child:
              Icon(widget.mute ? Icons.volume_off : Icons.volume_up,color: Colors.black ,size: 18),
          shape: new CircleBorder(),
          elevation: 0.0,
          fillColor: Color.fromARGB(255, 240, 240, 240),
        ),
      ),
    );
  }
}



// class _PlayPauseOverlay extends StatelessWidget {
//   final VideoPlayerController controller;
//   bool mute;
//   _PlayPauseOverlay({this.controller, this.mute});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         AnimatedSwitcher(
//           duration: Duration(milliseconds: 50),
//           reverseDuration: Duration(milliseconds: 200),
//           child: mute
//               ? Container(
//                   color: Colors.black26,
//                   child: Center(
//                     child: Icon(
//                       Icons.music_off,
//                       color: Colors.white,
//                       size: 100.0,
//                     ),
//                   ),
//                 )
//               : SizedBox.shrink(),
//         ),
//         InkWell(
//           onTap: () {
//             print('Button is Pressed');
//             if (mute == false) {
//               mute = true;
//             } else {
//               print('****************');
//               mute = false;
//             }

//             // controller.pause();
//             mute ? controller.setVolume(0.0) : controller.setVolume(20.0);
//           },
//         ),
//       ],
//     );
//   }
// }

//  Container(
//         // color: Colors.grey,
//         //  height: SizeConfig.blockSizeVertical * 40,
//         width: SizeConfig.screenWidth,
//         child: AspectRatio(
//           aspectRatio: controller.value.aspectRatio,
//           child: Stack(
//             alignment: Alignment.bottomCenter,
//             children: <Widget>[
//               widget.play == null
//                   ? VisibilityDetector(
//                       key: Key(
//                           DateTime.now().microsecondsSinceEpoch.toString()),
//                       onVisibilityChanged: (VisibilityInfo info) {
//                         debugPrint(
//                             "${info.visibleFraction} of my widget is visible");
//                         if (info.visibleFraction == 0) {
//                           if (controller != null) controller.pause();
//                         } else {
//                           if (controller != null) controller.play();
//                         }
//                       },
//                       child: VideoPlayer(controller))
//                   : VideoPlayer(controller),

//               // ClosedCaption(text: controller.value.caption.text),
//               _PlayPauseOverlay(controller: controller, id: widget.id),
//               //  VideoProgressIndicator(_controller, allowScrubbing: true),
//             ],
//           ),
//         ),
//       ),
