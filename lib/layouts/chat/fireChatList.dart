// import 'package:memeland/global/global.dart';
// import 'package:memeland/views/chat/fireChat.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:intl/intl.dart';

// class FireChatList extends StatefulWidget {
//   final GlobalKey<ScaffoldState> parentScaffoldKey;
//   FireChatList({Key key, this.parentScaffoldKey}) : super(key: key);

//   String currentUserName;
//   String currentUserImage;

//   // FireChatList({this.currentUserName, this.currentUserImage});
//   @override
//   _ChatListState createState() => _ChatListState();
// }

// class _ChatListState extends State<FireChatList> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         iconTheme: IconThemeData(
//           color: Colors.black, //change your color here
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         title: Text(
//           "Messanger",
//           style: TextStyle(
//               color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         // actions: <Widget>[
//         //   FlatButton(
//         //     textColor: Colors.black,
//         //     onPressed: () {
//         //       // Navigator.pop(context);
//         //     },
//         //     child: Text(
//         //       "",
//         //       style: TextStyle(
//         //           color: Colors.black,
//         //           fontSize: 17,
//         //           fontWeight: FontWeight.bold),
//         //     ),
//         //     shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
//         //   ),
//         // ],
//       ),
//       body: Container(
//         height: double.infinity,
//         child: Stack(
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.only(top: 15),
//               child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(40),
//                         topLeft: Radius.circular(40)),
//                     // image: DecorationImage(
//                     //   image: AssetImage(
//                     //     "assets/images/img.png",
//                     //   ),
//                     //   fit: BoxFit.fill,
//                     //   alignment: Alignment.topCenter,
//                     //   colorFilter: new ColorFilter.mode(
//                     //       Colors.blue.withOpacity(0.5), BlendMode.dstATop),
//                     // ),
//                   ),
//                   child: friendListToMessage(userID)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget friendListToMessage(String userData) {
//     return StreamBuilder(
//       stream: Firestore.instance
//           .collection("chatList")
//           .document(userData)
//           .collection(userData)
//           .orderBy("timestamp", descending: true)
//           .snapshots(),
//       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasData) {
//           return Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             child: snapshot.data.documents.length > 0
//                 ? ListView.builder(
//                     itemCount: snapshot.data.documents.length,
//                     itemBuilder: (context, int index) {
//                       List chatList = snapshot.data.documents;
//                       return buildItem(chatList, index);
//                     },
//                   )
//                 : Center(
//                     child: Text("Currently you don't have any messages"),
//                   ),
//           );
//         }
//         return Container(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           alignment: Alignment.center,
//           child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisSize: MainAxisSize.max,
//               children: <Widget>[
//                 CupertinoActivityIndicator(),
//               ]),
//         );
//       },
//     );
//   }

//   Widget buildItem(List chatList, int index) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 0, right: 0, top: 0),
//       child: GestureDetector(
//         onTap: () => Navigator.push(
//             context,
//             CupertinoPageRoute(
//                 builder: (context) => FireChat(
//                     // peerName:peerName,
//                     // peerUrl:peerUrl,
//                     currentuser: userID,
//                     currentusername: widget.currentUserName,
//                     currentuserimage: widget.currentUserImage,
//                     peerID: chatList[index]['id'],
//                     peerUrl: chatList[index]['profileImage'],
//                     // userData: userData,
//                     peerName: chatList[index]['name']))),
//         child: Padding(
//           padding: const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 8),
//           child: Stack(
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.only(left: 0, top: 0),
//                 child: Card(
//                   elevation: 10.0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Stack(
//                     children: <Widget>[
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: <Widget>[
//                           SizedBox(width: 60),
//                           Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 50, top: 10, right: 40, bottom: 5),
//                               child: Container(
//                                 // color: Colors.purple,
//                                 width: MediaQuery.of(context).size.width - 200,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: <Widget>[
//                                     Container(
//                                       height: 5,
//                                     ),
//                                     Container(
//                                       // color: Colors.yellow,
//                                       width: MediaQuery.of(context).size.width -
//                                           180,
//                                       child: Text(
//                                         chatList[index]['name'],
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black,
//                                           fontFamily: "Poppins-Medium",
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(top: 3),
//                                       child: Container(
//                                         width:
//                                             MediaQuery.of(context).size.width -
//                                                 150,
//                                         child: Text(
//                                           DateFormat('dd MMM yyyy, kk:mm')
//                                               .format(DateTime
//                                                   .fromMillisecondsSinceEpoch(
//                                                       int.parse(chatList[index]
//                                                           ['timestamp']))),
//                                           style: TextStyle(
//                                               color: Color(0xFF343e57),
//                                               fontSize: 11.0,
//                                               fontStyle: FontStyle.normal),
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(top: 3),
//                                       child: Container(
//                                         // color: Colors.red,
//                                         width:
//                                             MediaQuery.of(context).size.width -
//                                                 150,
//                                         height: 20,
//                                         child: Text(
//                                           chatList[index]['content'],
//                                           overflow: TextOverflow.ellipsis,
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.black,
//                                             fontSize: 12,
//                                             fontFamily: "Poppins-Medium",
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       height: 5,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 10),
//                             child: int.parse(chatList[index]['badge']) > 0
//                                 ? Container(
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       color: Colors.red,
//                                     ),
//                                     alignment: Alignment.center,
//                                     height: 30,
//                                     width: 30,
//                                     child: Text(
//                                       chatList[index]['badge'],
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w900),
//                                     ),
//                                   )
//                                 : Container(
//                                     child: Icon(
//                                       Icons.arrow_forward_ios,
//                                       color: appColor,
//                                       size: 25.0,
//                                     ),
//                                   ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                     ],
//                   ),
//                 ),
//               ),

//               //  Padding(
//               //    padding: const EdgeInsets.only(top: 12,left: 5),
//               //    child: Card(
//               //                   elevation: 4.0,
//               //                   shape: RoundedRectangleBorder(
//               //                       borderRadius: BorderRadius.circular(5.0)),
//               //                   child: Container(
//               //                     height: 45,
//               //                     width: 45,
//               //                     decoration: BoxDecoration(
//               //                         color: Colors.grey[200],
//               //                         border: Border.all(
//               //                           color: Colors
//               //                               .green, //                   <--- border color
//               //                           width: 2.5,
//               //                         ),
//               //                         borderRadius: BorderRadius.circular(5.0)),
//               //                     child: ClipRRect(
//               //                         borderRadius: BorderRadius.circular(5.0),
//               //                         child: chatList[index]['profileImage'] != null
//               //             ? CachedNetworkImage(
//               //                 placeholder: (context, url) => Container(
//               //                   child: CupertinoActivityIndicator(),
//               //                   width: 35.0,
//               //                   height: 35.0,
//               //                   padding: EdgeInsets.all(10.0),
//               //                 ),
//               //                 errorWidget: (context, url, error) => Material(
//               //                   child: Padding(
//               //                     padding: const EdgeInsets.all(0.0),
//               //                     child: Icon(Icons.person,size: 30,color: Colors.grey,),
//               //                   ),
//               //                   borderRadius: BorderRadius.all(
//               //                     Radius.circular(8.0),
//               //                   ),
//               //                   clipBehavior: Clip.hardEdge,
//               //                 ),
//               //                 imageUrl: chatList[index]['profileImage'],
//               //                 width: 35.0,
//               //                 height: 35.0,
//               //                 fit: BoxFit.cover,
//               //               )
//               //             : Padding(
//               //                 padding: const EdgeInsets.all(10.0),
//               //                 child: Icon(
//               //                   Icons.person,
//               //                   size: 25,
//               //                 ),
//               //               ),),
//               //                   ),
//               //                 ),
//               //  ),

//               Padding(
//                 padding: const EdgeInsets.only(left: 20, top: 12),
//                 child: Container(
//                   height: 65,
//                   width: 65,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 0.5,
//                     ),
//                     shape: BoxShape.circle,
//                     color: Colors.red,
//                   ),
//                   child: Material(
//                     child: chatList[index]['profileImage'] != null
//                         ? CachedNetworkImage(
//                             placeholder: (context, url) => Container(
//                               child: CupertinoActivityIndicator(),
//                               width: 35.0,
//                               height: 35.0,
//                               padding: EdgeInsets.all(10.0),
//                             ),
//                             errorWidget: (context, url, error) => Material(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(0.0),
//                                 child: Icon(
//                                   Icons.person,
//                                   size: 30,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(8.0),
//                               ),
//                               clipBehavior: Clip.hardEdge,
//                             ),
//                             imageUrl: chatList[index]['profileImage'],
//                             width: 35.0,
//                             height: 35.0,
//                             fit: BoxFit.cover,
//                           )
//                         : Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Icon(
//                               Icons.person,
//                               size: 25,
//                             ),
//                           ),
//                     borderRadius: BorderRadius.all(
//                       Radius.circular(100.0),
//                     ),
//                     clipBehavior: Clip.hardEdge,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget friendName(AsyncSnapshot friendListSnapshot, int index) {
//     return Container(
//       width: 200,
//       alignment: Alignment.topLeft,
//       child: RichText(
//         text: TextSpan(children: <TextSpan>[
//           TextSpan(
//             text:
//                 "${friendListSnapshot.data["firstname"]} ${friendListSnapshot.data["lastname"]}",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
//           )
//         ]),
//       ),
//     );
//   }

//   Widget messageButton(AsyncSnapshot friendListSnapshot, int index) {
//     return RaisedButton(
//       color: Colors.red,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//       child: Text(
//         "Message",
//         style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
//       ),
//       onPressed: () {},
//     );
//   }
// }
