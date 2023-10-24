import 'dart:convert';
import 'dart:io';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:memeland/global/global.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:memeland/layouts/widgets/multi_select.dart';
import 'package:memeland/models/intrest_model.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  TextEditingController controller = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController webController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  File _image;
  Future<void> getImageGallery() async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = File(image.path);
      print('Image Path $_image');
    });
  }

  Future<void> getImageFromCamera() async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = File(image.path);
      print('Image Path $_image');
    });
  }

  IntrestModel intrestModel;
  List<String> selectedCat = [];

  String gender;

  var gender1 = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    usernameController.text = userName;
    nameController.text = userfullname;
    // webController.text = userWeb;
    bioController.text = userBio;
    emailController.text = userEmail;
    phoneController.text = userPhone;
    if (userGender != '') {
      gender = userGender;
    } else {
      gender = 'Male';
    }

    // _getintrest();

    super.initState();
  }

  // _getintrest() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   var uri = Uri.parse('${baseUrl()}/get_all_interests');
  //   var request = new http.MultipartRequest("POST", uri);
  //   Map<String, String> headers = {
  //     "Accept": "application/json",
  //   };
  //   request.headers.addAll(headers);
  //   request.fields['user_id'] = userID;
  //   var response = await request.send();
  //   print(response.statusCode);
  //   String responseData = await response.stream.transform(utf8.decoder).join();
  //   var userData = json.decode(responseData);
  //   intrestModel = IntrestModel.fromJson(userData);
  //   print(responseData);
  //   selectedCat.addAll(intrestarray);

  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0.5,
            title: Text(
              "Edit Profile",
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
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });

                    if (_image != null) {
                      final dir = await getTemporaryDirectory();
                      final targetPath = dir.absolute.path +
                          "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

                      await FlutterImageCompress.compressAndGetFile(
                        _image.absolute.path,
                        targetPath,
                        quality: 20,
                      ).then((value) async {
                        print("Compressed");
                        _updateProfile(value);
                      });
                    } else {
                      _updateProfile(null);
                    }
                  },
                  child: Center(
                    child: Text(
                      'Done',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Container(width: 20)
            ],
          ),
          body: Stack(
            children: <Widget>[
              _userInfo2(),
              isLoading == true
                  ? Center(
                      child: loader(context),
                    )
                  : Container()
            ],
          )),
    );
  }

  Widget _userInfo2() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 40),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        border: Border.all(
                          color:
                              appColorBlack, //                   <--- border color
                          width: 3.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: InkWell(
                          onTap: () {
                            selectImageSource();
                          },
                          child: CircleAvatar(
                            backgroundImage: _image != null
                                ? FileImage(_image)
                                : userImage != '' && userImage != null
                                    ? NetworkImage(userImage)
                                    : NetworkImage(
                                        "${"https://www.nicepng.com/png/detail/136-1366211_group-of-10-guys-login-user-icon-png.png"}"),
                            radius: 50,
                          ),
                        ),
                      ),
                    ),
                    Container(height: 5),
                    InkWell(
                      onTap: () {
                        selectImageSource();
                      },
                      child: Text(
                        "Change profile photo",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                Container(height: 20),
                divider(),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        child: Text(
                          "Username",
                          style: TextStyle(
                              fontFamily: "Poppins-Medium",
                              color: Theme.of(context).primaryColorLight,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              hintText: "Enter Username",
                              hintStyle: TextStyle(
                                  color: Colors.grey[500], fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? appColorWhite.withOpacity(0.5)
                                        : Colors.black45,
                                    width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? appColorWhite.withOpacity(0.5)
                                        : Colors.black45,
                                    width: 0.5),
                              ),
                            ),
                            // scrollPadding: EdgeInsets.all(20.0),
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 99999,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        child: Text(
                          "Name",
                          style: TextStyle(
                              fontFamily: "Poppins-Medium",
                              color: Theme.of(context).primaryColorLight,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: "Enter name",
                              hintStyle: TextStyle(
                                  color: Colors.grey[500], fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? appColorWhite.withOpacity(0.5)
                                        : Colors.black45,
                                    width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? appColorWhite.withOpacity(0.5)
                                        : Colors.black45,
                                    width: 0.5),
                              ),
                            ),
                            // scrollPadding: EdgeInsets.all(20.0),
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 99999,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Container(
                //         width: 100,
                //         child: Text(
                //           "Website",
                //           style: TextStyle(
                //               fontFamily: "Poppins-Medium",
                //               color: appColorBlack,
                //               fontSize: 14,
                //               fontWeight: FontWeight.bold),
                //         ),
                //       ),
                //       Expanded(
                //         child: Padding(
                //           padding: const EdgeInsets.only(left: 0),
                //           child: TextField(
                //             controller: webController,
                //             decoration: InputDecoration(
                //               hintText: "Enter Website",
                //               hintStyle: TextStyle(
                //                   color: Colors.grey[500], fontSize: 14),
                //               alignLabelWithHint: true,
                //               enabledBorder: UnderlineInputBorder(
                //                 borderSide: BorderSide(
                //                     color: Colors.black45, width: 0.5),
                //               ),
                //               focusedBorder: UnderlineInputBorder(
                //                 borderSide: BorderSide(
                //                     color: Colors.black45, width: 0.5),
                //               ),
                //             ),
                //             // scrollPadding: EdgeInsets.all(20.0),
                //             // keyboardType: TextInputType.multiline,
                //             // maxLines: 99999,
                //             style:
                //                 TextStyle(color: appColorBlack, fontSize: 15),
                //             autofocus: false,
                //           ),
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Bio",
                            style: TextStyle(
                                fontFamily: "Poppins-Medium",
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: bioController,
                            decoration: InputDecoration(
                              hintText: "Enter Bio",
                              hintStyle: TextStyle(
                                  color: Colors.grey[500], fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? appColorWhite.withOpacity(0.5)
                                        : Colors.black45,
                                    width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? appColorWhite.withOpacity(0.5)
                                        : Colors.black45,
                                    width: 0.5),
                              ),
                            ),
                            scrollPadding: EdgeInsets.all(20.0),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Email",
                            style: TextStyle(
                                fontFamily: "Poppins-Medium",
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: emailController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "Enter email",
                              hintStyle: TextStyle(
                                  color: Colors.grey[500], fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? appColorWhite.withOpacity(0.5)
                                        : Colors.black45,
                                    width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? appColorWhite.withOpacity(0.5)
                                        : Colors.black45,
                                    width: 0.5),
                              ),
                            ),
                            scrollPadding: EdgeInsets.all(20.0),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Phone",
                            style: TextStyle(
                                fontFamily: "Poppins-Medium",
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              hintText: "Enter phone number",
                              hintStyle: TextStyle(
                                  color: Colors.grey[500], fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? appColorWhite.withOpacity(0.5)
                                        : Colors.black45,
                                    width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? appColorWhite.withOpacity(0.5)
                                        : Colors.black45,
                                    width: 0.5),
                              ),
                            ),
                            scrollPadding: EdgeInsets.all(20.0),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 10, right: 10, bottom: 10),
                  child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "Gender",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorStyle: TextStyle(
                                  color: Colors.redAccent, fontSize: 12),
                              contentPadding: EdgeInsets.only(
                                  top: 0, bottom: 5, left: 0, right: 0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: gender,
                                isDense: true,
                                hint: Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: Text(
                                    'Gender',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 13),
                                  ),
                                ),
                                icon: Container(),
                                onChanged: (String newValue) {
                                  setState(() {
                                    gender = newValue;
                                    state.didChange(newValue);
                                  });
                                },
                                items: gender1.map((item) {
                                  return new DropdownMenuItem(
                                    child: new Text(
                                      item,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          fontSize: 13),
                                    ),
                                    value: item,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                // Container(height: 20),
                divider(),
                // interestTree()

                // Padding(
                //   padding: const EdgeInsets.only(left: 15, top: 15),
                //   child: InkWell(
                //     onTap: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(builder: (context) => PersonalInfo()),
                //       );
                //     },
                //     child: Row(
                //       children: [
                //         Text(
                //           'Personal information Settings',
                //           style: TextStyle(color: Colors.blue),
                //           textAlign: TextAlign.center,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget interestTree() {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Text(
  //               "What interests you?",
  //               style: TextStyle(
  //                   color: Colors.black,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 20),
  //             )
  //           ],
  //         ),
  //         SizedBox(
  //           height: 20,
  //         ),
  //         isLoading
  //             ? Center(
  //                 child: CupertinoActivityIndicator(),
  //               )
  //             : Container(
  //                 // height: 200,
  //                 child: GridView.builder(
  //                   shrinkWrap: true,
  //                   primary: false,
  //                   scrollDirection: Axis.vertical,
  //                   // padding: EdgeInsets.all(5),
  //                   itemCount: intrestModel.interests.length,
  //                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                     crossAxisCount: 3,
  //                     childAspectRatio: 100 / 100,
  //                   ),
  //                   itemBuilder: (BuildContext context, int index) {
  //                     return Container(
  //                       margin:
  //                           EdgeInsets.symmetric(horizontal: 5, vertical: 10),
  //                       // height: 40,
  //                       // ignore: deprecated_member_use
  //                       child: RaisedButton(
  //                           shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(20),
  //                               side: BorderSide(
  //                                   color: selectedCat.contains(
  //                                           intrestModel.interests[index].id)
  //                                       ? Colors.transparent
  //                                       : Colors.grey)),
  //                           color: selectedCat
  //                                   .contains(intrestModel.interests[index].id)
  //                               ? Colors.black
  //                               : Colors.grey[200],
  //                           onPressed: () => setState(
  //                                 () {
  //                                   if (selectedCat.contains(
  //                                       intrestModel.interests[index].id)) {
  //                                     selectedCat.remove(
  //                                         intrestModel.interests[index].id);
  //                                   } else {
  //                                     selectedCat.add(
  //                                         intrestModel.interests[index].id);

  //                                     // if (vendorType == "Store vendor") {
  //                                     //   if (check.length <= 0) {
  //                                     //     check.add(snapshot.data.categories[index].id);
  //                                     //   }
  //                                     // } else if (vendorType == "Individual vendor") {
  //                                     //   if (check.length <= 2) {
  //                                     //     check.add(snapshot.data.categories[index].id);
  //                                     //   }
  //                                     // }
  //                                   }
  //                                 },
  //                               ),
  //                           child: selectedCat
  //                                   .contains(intrestModel.interests[index].id)
  //                               ? Center(
  //                                   child: Text(
  //                                     intrestModel.interests[index].type,
  //                                     textAlign: TextAlign.center,
  //                                     style: TextStyle(
  //                                         color: Colors.white, fontSize: 12),
  //                                   ),
  //                                 )
  //                               : Center(
  //                                   child: Text(
  //                                   intrestModel.interests[index].type,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                       color: Colors.black, fontSize: 12),
  //                                 ))),
  //                     );
  //                   },
  //                 ),
  //               )
  //       ],
  //     ),
  //   );
  // }

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
                  getImageGallery();
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

  Widget divider() {
    return Container(
      height: 0.5,
      color: Colors.grey[400],
    );
  }

  Future<void> _updateProfile(File img) async {
    closeKeyboard();
    try {
      setState(() {
        isLoading = true;
      });

      // final response = await client.post('${baseUrl()}/login', body: {
      //   "phone": emailController.text,
      //   "password": passwordController.text
      // });

      var uri = Uri.parse('${baseUrl()}/user_edit');
      var request = new http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        "Accept": "application/json",
      };
      request.headers.addAll(headers);
      request.fields['id'] = userID;
      request.fields['username'] = usernameController.text;
      request.fields['fullname'] = nameController.text;
      request.fields['interests_id'] = '1';
      // request.fields['interests_id'] =
      //     selectedCat.toString().replaceAll('[', '').replaceAll(']', '');
      request.fields['bio'] = bioController.text;
      request.fields['email'] = emailController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['gender'] = gender;
      if (img != null) {
        request.files
            .add(await http.MultipartFile.fromPath('profile_pic', img.path));
      }

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var dic = json.decode(responseData);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });

        print(dic);

        if (dic['response_code'] == "1") {
          setState(() {
            isLoading = false;
            userName = usernameController.text;
            userfullname = nameController.text;
            // userWeb = webController.text;
            userBio = bioController.text;
            userEmail = emailController.text;
            userPhone = phoneController.text;
            userGender = genderController.text;
            userImage = dic['user']['profile_pic'];
          });
          toast("Success", "Update Successfully", context);
          print(userImage);
        } else {
          // Loader().hideIndicator(context);
          setState(() {
            isLoading = false;
          });
          toast("Error", "Update Fail!", context);
        }
      } else {
        // Loader().hideIndicator(context);
        setState(() {
          isLoading = false;
        });
        toast("Error", "Cannot communicate with server", context);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toast("Error", e.toString(), context);
    }
  }

  // ignore: unused_element
  void _showMultiSelect(BuildContext context) async {
    final items = <MultiSelectDialogItem<int>>[
      MultiSelectDialogItem(1, 'Dog'),
      MultiSelectDialogItem(2, 'Cat'),
      MultiSelectDialogItem(3, 'Mouse'),
    ];

    final selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
          initialSelectedValues: [1, 3].toSet(),
        );
      },
    );

    print(selectedValues);
  }
}
