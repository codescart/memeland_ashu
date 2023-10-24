// import 'dart:convert';

// import 'package:memeland/Helper/sizeConfig.dart';
// import 'package:memeland/global/global.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class PersonalInfo extends StatefulWidget {
//   @override
//   _PersonalInfoState createState() => _PersonalInfoState();
// }

// class _PersonalInfoState extends State<PersonalInfo> {
//   bool isLoading = false;
//   TextEditingController controller = TextEditingController();

//   TextEditingController emailController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController genderController = TextEditingController();
//   // bool isSwitched = false;

//   @override
//   void initState() {
//     // isSwitched = globalPrivacy;

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return Scaffold(
//         backgroundColor: appColorWhite,
//         appBar: AppBar(
//           backgroundColor: appColorWhite,
//           elevation: 1,
//           title: Text(
//             "Personal Information",
//             style: TextStyle(
//                 fontSize: 16,
//                 color: appColorBlack,
//                 fontWeight: FontWeight.bold),
//           ),
//           centerTitle: true,
//           leading: IconButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               icon: Icon(
//                 Icons.arrow_back_ios,
//                 color: appColorBlack,
//               )),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: InkWell(
//                 onTap: () {
//                   // Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(builder: (context) => BottomTabbar()),
//                   // );
//                 },
//                 child: Text(
//                   'Done',
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             Container(width: 20)
//           ],
//         ),
//         body: isLoading == true ? Center(child: loader(context)) : _userInfo());
//   }

//   Widget _userInfo() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.symmetric(horizontal: 0),
//       child: Stack(
//         children: <Widget>[
//           Container(
//             width: MediaQuery.of(context).size.width,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 SizedBox(height: 50),
//                 Text(
//                   'This information won\'t be display \n in public profile',
//                   style: TextStyle(
//                       color: appColorBlack,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Poppins-Medium'),
//                   textAlign: TextAlign.center,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
//                   child: Container(
//                     color: Colors.white,
//                     child: Column(
//                       children: <Widget>[
//                         Material(
//                           elevation: 5.0,
//                           shadowColor: Colors.white,
//                           borderRadius: BorderRadius.circular(10.0),
//                           child: Container(
//                             width: SizeConfig.screenWidth,
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 border: Border.all(
//                                     color: appColorBlack, width: 1.5)),
//                             child: Padding(
//                               padding: EdgeInsets.only(
//                                 top: 10.0,
//                                 bottom: 00.0,
//                                 left: 20.0,
//                                 right: 20.0,
//                               ),
//                               child: InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     emailController.text = userEmail;
//                                   });
//                                   openBottmSheet("Email", 'email', userEmail);
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       bottom: 20, top: 10),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       Text(
//                                         "Email",
//                                         style: TextStyle(
//                                             fontFamily: "Poppins-Medium",
//                                             color: appColorBlack,
//                                             fontSize:
//                                                 SizeConfig.safeBlockHorizontal *
//                                                     3,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       SizedBox(
//                                         width:
//                                             SizeConfig.blockSizeHorizontal * 55,
//                                         child: Text(
//                                           userEmail,
//                                           maxLines: 1,
//                                           textAlign: TextAlign.right,
//                                           style: TextStyle(
//                                               color: appColorBlack,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: SizeConfig.blockSizeVertical * 3,
//                         ),
//                         Material(
//                           elevation: 5.0,
//                           shadowColor: Colors.white,
//                           borderRadius: BorderRadius.circular(10.0),
//                           child: Container(
//                             width: SizeConfig.screenWidth,
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 border: Border.all(
//                                     color: appColorBlack, width: 1.5)),
//                             child: Padding(
//                               padding: EdgeInsets.only(
//                                 top: 10.0,
//                                 bottom: 00.0,
//                                 left: 20.0,
//                                 right: 20.0,
//                               ),
//                               child: InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     phoneController.text = userPhone;
//                                   });
//                                   openBottmSheet("Phone", 'phone', userPhone);
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       bottom: 20, top: 10),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       Text(
//                                         "Phone",
//                                         style: TextStyle(
//                                             fontFamily: "Poppins-Medium",
//                                             color: appColorBlack,
//                                             fontSize:
//                                                 SizeConfig.safeBlockHorizontal *
//                                                     3,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       SizedBox(
//                                         width:
//                                             SizeConfig.blockSizeHorizontal * 35,
//                                         child: userPhone != null
//                                             ? Text(
//                                                 userPhone,
//                                                 maxLines: 1,
//                                                 textAlign: TextAlign.right,
//                                                 style: TextStyle(
//                                                     color: appColorBlack,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               )
//                                             : Text(
//                                                 "ex. +1123456789",
//                                                 maxLines: 1,
//                                                 textAlign: TextAlign.right,
//                                                 style: TextStyle(
//                                                     color: Colors.grey,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: SizeConfig.blockSizeVertical * 3,
//                         ),
//                         Material(
//                           elevation: 5.0,
//                           shadowColor: Colors.white,
//                           borderRadius: BorderRadius.circular(10.0),
//                           child: Container(
//                             width: SizeConfig.screenWidth,
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 border: Border.all(
//                                     color: appColorBlack, width: 1.5)),
//                             child: Padding(
//                               padding: EdgeInsets.only(
//                                 top: 10.0,
//                                 bottom: 00.0,
//                                 left: 20.0,
//                                 right: 20.0,
//                               ),
//                               child: InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     genderController.text = userGender;
//                                   });
//                                   openBottmSheet(
//                                       "Gender", 'gender', userGender);
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       bottom: 20, top: 10),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       Text(
//                                         "Gender",
//                                         style: TextStyle(
//                                             fontFamily: "Poppins-Medium",
//                                             color: appColorBlack,
//                                             fontSize:
//                                                 SizeConfig.safeBlockHorizontal *
//                                                     3,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       SizedBox(
//                                         width:
//                                             SizeConfig.blockSizeHorizontal * 35,
//                                         child: userGender != null
//                                             ? Text(
//                                                 userGender,
//                                                 maxLines: 1,
//                                                 textAlign: TextAlign.right,
//                                                 style: TextStyle(
//                                                     color: appColorBlack,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               )
//                                             : Text(
//                                                 "Male/Female",
//                                                 maxLines: 1,
//                                                 textAlign: TextAlign.right,
//                                                 style: TextStyle(
//                                                     color: Colors.grey,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         // SizedBox(
//                         //   height: SizeConfig.blockSizeVertical * 3,
//                         // ),
//                         // Material(
//                         //   elevation: 5.0,
//                         //   shadowColor: Colors.white,
//                         //   borderRadius: BorderRadius.circular(10.0),
//                         //   child: Container(
//                         //     width: SizeConfig.screenWidth,
//                         //     decoration: BoxDecoration(
//                         //         color: Colors.white,
//                         //         borderRadius: BorderRadius.circular(10.0),
//                         //         border: Border.all(
//                         //             color: appColorBlack, width: 1.5)),
//                         //     child: Padding(
//                         //       padding: EdgeInsets.only(
//                         //         top: 10.0,
//                         //         bottom: 00.0,
//                         //         left: 20.0,
//                         //         right: 20.0,
//                         //       ),
//                         //       child: InkWell(
//                         //         onTap: () {
//                         //           setState(() {
//                         //             controller.text = globalBday;
//                         //           });
//                         //           openBottmSheet(
//                         //               "Birthday", 'bday', globalBday);
//                         //         },
//                         //         child: Padding(
//                         //           padding: const EdgeInsets.only(
//                         //               bottom: 20, top: 10),
//                         //           child: Row(
//                         //             mainAxisAlignment:
//                         //                 MainAxisAlignment.spaceBetween,
//                         //             children: <Widget>[
//                         //               Text(
//                         //                 "Birthday",
//                         //                 style: TextStyle(
//                         //                     fontFamily: "Poppins-Medium",
//                         //                     color: appColorBlack,
//                         //                     fontSize:
//                         //                         SizeConfig.safeBlockHorizontal *
//                         //                             3,
//                         //                     fontWeight: FontWeight.bold),
//                         //               ),
//                         //               SizedBox(
//                         //                 width:
//                         //                     SizeConfig.blockSizeHorizontal * 35,
//                         //                 child: globalBday.length > 0
//                         //                     ? Text(
//                         //                         globalBday,
//                         //                         maxLines: 1,
//                         //                         textAlign: TextAlign.right,
//                         //                         style: TextStyle(
//                         //                             color: appColorBlack,
//                         //                             fontWeight:
//                         //                                 FontWeight.bold),
//                         //                       )
//                         //                     : Text(
//                         //                         "12/2/2001",
//                         //                         maxLines: 1,
//                         //                         textAlign: TextAlign.right,
//                         //                         style: TextStyle(
//                         //                             color: Colors.grey,
//                         //                             fontWeight:
//                         //                                 FontWeight.bold),
//                         //                       ),
//                         //               ),
//                         //             ],
//                         //           ),
//                         //         ),
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//                         // SizedBox(
//                         //   height: SizeConfig.blockSizeVertical * 3,
//                         // ),
//                         // Material(
//                         //   elevation: 5.0,
//                         //   shadowColor: Colors.white,
//                         //   borderRadius: BorderRadius.circular(10.0),
//                         //   child: Container(
//                         //     width: SizeConfig.screenWidth,
//                         //     decoration: BoxDecoration(
//                         //         color: Colors.white,
//                         //         borderRadius: BorderRadius.circular(10.0),
//                         //         border: Border.all(
//                         //             color: appColorBlack, width: 1.5)),
//                         //     child: Padding(
//                         //       padding: EdgeInsets.only(
//                         //         top: 10.0,
//                         //         bottom: 0.0,
//                         //         left: 20.0,
//                         //         right: 20.0,
//                         //       ),
//                         //       child: InkWell(
//                         //         onTap: () {},
//                         //         child: Padding(
//                         //           padding:
//                         //               const EdgeInsets.only(bottom: 10, top: 0),
//                         //           child: Row(
//                         //             mainAxisAlignment:
//                         //                 MainAxisAlignment.spaceBetween,
//                         //             children: <Widget>[
//                         //               Text(
//                         //                 "privacy",
//                         //                 style: TextStyle(
//                         //                     fontFamily: "Poppins-Medium",
//                         //                     color: appColorBlack,
//                         //                     fontSize:
//                         //                         SizeConfig.safeBlockHorizontal *
//                         //                             3,
//                         //                     fontWeight: FontWeight.bold),
//                         //               ),
//                         //               SizedBox(
//                         //                 width: 60,
//                         //                 child: Switch(
//                         //                   value: isSwitched,
//                         //                   onChanged: (value) {
//                         //                     setState(() {
//                         //                       isSwitched = value;

//                         //                       FirebaseFirestore.instance
//                         //                           .collection("user")
//                         //                           .doc(globalID)
//                         //                           .update({
//                         //                         'privacy': value
//                         //                       }).then((_) {
//                         //                         setState(() {
//                         //                           globalPrivacy = value;
//                         //                         });
//                         //                       });
//                         //                     });
//                         //                   },
//                         //                   activeColor: appColorBlack,
//                         //                 ),
//                         //               ),
//                         //             ],
//                         //           ),
//                         //         ),
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//                         SizedBox(
//                           height: SizeConfig.blockSizeVertical * 5,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   openBottmSheet(String name, String fieldName, String value) {
//     showModalBottomSheet(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20.0),
//           topRight: Radius.circular(20.0),
//         ),
//       ),
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//             ),
//             child: Container(
//               height: 500,
//               child: ListView(
//                 children: <Widget>[
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20.0),
//                         topRight: Radius.circular(20.0),
//                       ),
//                     ),
//                     height: 60,
//                     child: Padding(
//                       padding:
//                           const EdgeInsets.only(left: 15, right: 15, top: 15),
//                       child: Text(
//                         name,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           fontStyle: FontStyle.normal,
//                           //color: Colors.purple
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: 1,
//                     color: Colors.grey,
//                   ),
//                   Container(
//                       margin: EdgeInsets.only(left: 20.0, right: 20.0),
//                       height: 120,
//                       // color: Colors.red,
//                       child: Padding(
//                           padding: const EdgeInsets.only(
//                               top: 20, right: 20, left: 20),
//                           child: CustomtextField(
//                             maxLines: 1,
//                             textInputAction: TextInputAction.next,
//                             controller: controller,
//                             hintText: 'Enter $name',
//                             prefixIcon: Icon(
//                               Icons.person,
//                               color: appColorGrey,
//                               size: 30.0,
//                             ),
//                           ))),
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(left: 90, right: 90, top: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 15, right: 10),
//                             child: Container(
//                               width: 70,
//                               height: 35,
//                               // ignore: deprecated_member_use
//                               child: RaisedButton(
//                                 shape: new RoundedRectangleBorder(
//                                   borderRadius: new BorderRadius.circular(8.0),
//                                 ),
//                                 onPressed: () {
//                                   _updateProfile(fieldName, value);
//                                   // if (controller.text.length > 0) {
//                                   //   FirebaseFirestore.instance
//                                   //       .collection("user")
//                                   //       .doc(globalID)
//                                   //       .update({
//                                   //     fieldName: controller.text
//                                   //   }).then((value) {
//                                   //     setState(() {
//                                   //       if (fieldName == "mobile") {
//                                   //         globalPhone = controller.text;
//                                   //       } else if (fieldName == "gender") {
//                                   //         globalGender = controller.text;
//                                   //       } else if (fieldName == "bday") {
//                                   //         globalBday = controller.text;
//                                   //       }
//                                   //     });
//                                   //     Navigator.pop(context);
//                                   //   });
//                                   // } else {
//                                   //   Toast.show("Enter text", context,
//                                   //       duration: Toast.LENGTH_SHORT,
//                                   //       gravity: Toast.BOTTOM);
//                                   // }
//                                 },
//                                 color: buttonColorBlue,
//                                 textColor: Colors.white,
//                                 child: Text("Update".toUpperCase(),
//                                     style: TextStyle(fontSize: 14)),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _updateProfile(String fieldName, String value) async {
//     try {
//       setState(() {
//         isLoading = true;
//       });

//       // final response = await client.post('${baseUrl()}/login', body: {
//       //   "phone": emailController.text,
//       //   "password": passwordController.text
//       // });

//       var uri = Uri.parse('${baseUrl()}/user_edit');
//       var request = new http.MultipartRequest("POST", uri);
//       Map<String, String> headers = {
//         "Accept": "application/json",
//       };
//       request.headers.addAll(headers);
//       request.fields['id'] = userID;
//       request.fields['$fieldName'] = value;

//       var response = await request.send();
//       String responseData =
//           await response.stream.transform(utf8.decoder).join();
//       var dic = json.decode(responseData);

//       if (response.statusCode == 200) {
//         setState(() {
//           isLoading = false;
//         });

//         print(dic);

//         if (dic['response_code'] == "1") {
//           setState(() {
//             isLoading = false;

//             if (fieldName == "email") {
//               userEmail = value;
//             } else if (fieldName == "phone") {
//               userPhone = value;
//             } else if (fieldName == "gender") {
//               userGender = value;
//             }
//           });
//           toast("Success", "Update Successfully", context);
//           Navigator.pop(context);
//         } else {
//           Navigator.pop(context);
//           // Loader().hideIndicator(context);
//           setState(() {
//             isLoading = false;
//           });
//           toast("Error", "Update Fail!", context);
//         }
//       } else {
//         // Loader().hideIndicator(context);
//         setState(() {
//           isLoading = false;
//         });
//         toast("Error", "Cannot communicate with server", context);
//       }

//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       toast("Error", e.toString(), context);
//     }
//   }
// }
