import 'dart:convert';
import 'package:memeland/global/global.dart';
import 'package:memeland/models/intrest_model.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memeland/shared_preferences/preferencesKey.dart';

// ignore: must_be_immutable
class CreateProfile extends StatefulWidget {
  CreateProfile({this.name, this.password, this.email, this.id});
  String id;
  String email;
  String name;
  String password;

  @override
  _LoginState createState() => _LoginState(
        id: id,
        name: name,
        password: password,
        email: email,
      );
}

class _LoginState extends State<CreateProfile> {
  _LoginState({this.name, this.password, this.email, this.id});

  FocusNode ageNode = new FocusNode();
  String id;
  bool buttonclick = false;
  String cityValue;
  String countryValue;
  String dataheight;
  String email;
  String gender;
  // var gender1 = [
  //   "Male",
  //   "Female",
  //   "Other",
  // ];

  var gender1 = ['Male', 'Female', 'Other'];

  String height;
  IntrestModel intrestModel;
  bool isLoading = false;
  String name;
  String orietantion;
  String password;
  List<String> selectedCat = [];
  var splitData = [];
  String stateValue;

  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    print('USER ID >>>>>>$id');
    _getintrest();

    // _selectedoptions = _uniquoptions;
    super.initState();
  }

  _getintrest() async {
    setState(() {
      isLoading = true;
    });
    var uri = Uri.parse('${baseUrl()}/get_all_interests');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    intrestModel = IntrestModel.fromJson(userData);
    print(responseData);

    setState(() {
      isLoading = false;
    });
  }

  //EditInfoData >>>>Start

  Widget editInfoData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(height: 15),
        ageWidget(),
        Container(height: 15),
        genderWidget(),
        Container(height: 15),
        locationWidget(),
        // Container(height: 15),
        // interestTree(),
        Container(height: 30),
      ],
    );
  }

  Widget ageWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Age",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: appColorBlack),
          ),
          CustomtextField3(
              textAlign: TextAlign.start,
              controller: _ageController,
              focusNode: ageNode,
              maxLines: 1,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              hintText: 'Enter your age'),
        ],
      ),
    );
  }

  Widget genderWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gender",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: appColorBlack),
          ),
          FormField<String>(
            builder: (FormFieldState<String> state) {
              return Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      // height: 55,
                      color: Colors.white,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          errorStyle: TextStyle(
                              color: Colors.redAccent, fontSize: 16.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: gender,
                            isDense: true,
                            hint: Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Text(
                                'Select Gender',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              ),
                            ),
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 0, top: 5),
                              child: Icon(
                                // Add this
                                Icons.arrow_drop_down, // Add this
                                color: appColorBlack, // Add this
                              ),
                            ),
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
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                value: item,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            height: 1,
            color: Colors.grey[300],
          )
        ],
      ),
    );
  }

  Widget locationWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Location",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: appColorBlack),
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            children: [
              CSCPicker(
                flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                disabledDropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: appColorWhite,
                    border: Border.all(color: Colors.grey.shade300, width: 1)),
                onCountryChanged: (value) {
                  setState(() {
                    countryValue = value;
                  });
                },
                onStateChanged: (value) {
                  setState(() {
                    stateValue = value;
                  });
                },
                onCityChanged: (value) {
                  setState(() {
                    cityValue = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget interestTree() {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 30, right: 30, top: 0),
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
  //             : ListView.builder(
  //                 shrinkWrap: true,
  //                 physics: NeverScrollableScrollPhysics(),
  //                 primary: false,
  //                 padding: EdgeInsets.all(5),
  //                 itemCount: intrestModel.interests.length,
  //                 // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                 //   crossAxisCount: 2,
  //                 //   childAspectRatio: 100 / 50,
  //                 // ),
  //                 itemBuilder: (BuildContext context, int index) {
  //                   return Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: SizedBox(
  //                       height: 40,
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
  //                                     style: TextStyle(
  //                                         color: Colors.white, fontSize: 12),
  //                                   ),
  //                                 )
  //                               : Center(
  //                                   child: Text(
  //                                   intrestModel.interests[index].type,
  //                                   style: TextStyle(
  //                                       color: Colors.black, fontSize: 12),
  //                                 ))),
  //                     ),
  //                   );
  //                 },
  //               )

  //         // uniqueoptions(),
  //         // Padding(
  //         //   padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
  //         //   child: Column(
  //         //     children: <Widget>[
  //         //       buttonWidget("Meeting new people"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Making new friends"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Meeting online"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Meeting in person"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Dating Men"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Dating Women "),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Meeting Cis Men"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Meeting Trans Men"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Meeting Cis Women"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Meeting Trans Women"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Meeting Non Binary  "),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Meeting Non-Conforming"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Meeting Queer people"),
  //         //       SizedBox(
  //         //         height: 10,
  //         //       ),
  //         //       buttonWidget("Meeting Custom Non-Binary"),
  //         //       // Padding(
  //         //       //   padding: const EdgeInsets.only(top: 10),
  //         //       //   child: Row(
  //         //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         //       //     children: [
  //         //       //       buttonWidget("Meeting new people"),
  //         //       //       buttonWidget("Making new friends"),
  //         //       //     ],
  //         //       //   ),
  //         //       // ),
  //         //       // Padding(
  //         //       //   padding: const EdgeInsets.only(top: 10),
  //         //       //   child: Row(
  //         //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         //       //     children: [
  //         //       //       buttonWidget("Meeting online"),
  //         //       //       buttonWidget("Meeting in person"),
  //         //       //     ],
  //         //       //   ),
  //         //       // ),
  //         //       // Padding(
  //         //       //   padding: const EdgeInsets.only(top: 10),
  //         //       //   child: Row(
  //         //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         //       //     children: [
  //         //       //       buttonWidget("Dating Men"),
  //         //       //       buttonWidget("Dating Women "),
  //         //       //     ],
  //         //       //   ),
  //         //       // ),
  //         //       // Padding(
  //         //       //   padding: const EdgeInsets.only(top: 10),
  //         //       //   child: Row(
  //         //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         //       //     children: [
  //         //       //       buttonWidget("Meeting Cis Men"),
  //         //       //       buttonWidget("Meeting Trans Men"),
  //         //       //     ],
  //         //       //   ),
  //         //       // ),
  //         //       // Padding(
  //         //       //   padding: const EdgeInsets.only(top: 10),
  //         //       //   child: Row(
  //         //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         //       //     children: [
  //         //       //       buttonWidget("Meeting Cis Women"),
  //         //       //       buttonWidget("Meeting Trans Women"),
  //         //       //     ],
  //         //       //   ),
  //         //       // ),
  //         //       // Padding(
  //         //       //   padding: const EdgeInsets.only(top: 10),
  //         //       //   child: Row(
  //         //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         //       //     children: [
  //         //       //       buttonWidget("Meeting Non Binary  "),
  //         //       //       buttonWidget("Meeting Non-Conforming"),
  //         //       //       buttonWidget("Meeting Queer people"),
  //         //       //       buttonWidget("Meeting Custom Non-Binary"),
  //         //       //     ],
  //         //       //   ),
  //         //       // ),
  //         //       // Padding(
  //         //       //   padding: const EdgeInsets.only(top: 10),
  //         //       //   child: Row(
  //         //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         //       //     children: [
  //         //       //       buttonWidget("Meeting Queer people"),
  //         //       //       buttonWidget("Meeting Custom Non-Binary"),
  //         //       //     ],
  //         //       //   ),
  //         //       // ),
  //         //     ],
  //         //   ),
  //         // )
  //       ],
  //     ),
  //   );
  // }

  // static List<UniqeOption> _uniquoptions = [
  //   UniqeOption(id: 1, name: "Meeting new people"),
  //   UniqeOption(id: 2, name: "Making new friends"),
  //   UniqeOption(id: 3, name: "Meeting online"),
  //   UniqeOption(id: 4, name: "Meeting in person"),
  //   UniqeOption(id: 5, name: "Dating Men"),
  //   UniqeOption(id: 6, name: "Dating Women "),
  //   UniqeOption(id: 7, name: "Meeting Cis Men"),
  //   UniqeOption(id: 8, name: "Meeting Trans Men"),
  //   UniqeOption(id: 9, name: "Meeting Cis Women"),
  //   UniqeOption(id: 10, name: "Meeting Trans Women"),
  //   UniqeOption(id: 11, name: "Meeting Non Binary"),
  //   UniqeOption(id: 12, name: "Meeting Non-Conforming"),
  //   UniqeOption(id: 13, name: "Meeting Queer people"),
  //   UniqeOption(id: 14, name: "Meeting Custom Non-Binary"),
  // ];

  // List<UniqeOption> _selectedoptions = [];

  // final _items = _uniquoptions
  //     .map((options) => MultiSelectItem<UniqeOption>(options, options.name))
  //     .toList();

  // Widget uniqueoptions() {
  //   return Column(
  //     children: [
  //       MultiSelectDialogField(
  //         onConfirm: (val) {
  //           _selectedoptions = val;
  //           print(_selectedoptions.iterator);

  //         },
  //         items: _items,
  //         selectedColor: Colors.black,

  //         initialValue:
  //             _selectedoptions, // setting the value of this in initState() to pre-select values.
  //       ),
  //     ],
  //   );
  // }

  Widget buttonWidget(title) {
    return splitData.contains(title)
        ? SelectedButton2(
            title: title,
            onPressed: () {
              setState(() {
                splitData.remove(title);
              });
            },
          )
        : UnSelectedButton2(
            title: title,
            onPressed: () {
              setState(() {
                splitData.add(title);
              });
            },
          );
  }

  updateData() {
    // var bio = splitData.join(',');
    FirebaseMessaging().getToken().then((token) async {
      try {
        setState(() {
          buttonclick = true;
        });

        // final response = await client.post('${baseUrl()}/login', body: {
        //   "phone": emailController.text,
        //   "password": passwordController.text
        // });

        final response = await client.post('${baseUrl()}/register_new', body: {
          'id': id,
          "email": email,
          // "password": password,
          "username": name,
          "age": _ageController.text,
          "gender": gender,
          "country": countryValue != null ? countryValue : '',
          "state": stateValue != null ? stateValue : '',
          "city": cityValue != null ? cityValue : '',
          "bio": '',
          'interest_id': '1',
          // 'interests_id':
          //     selectedCat.toString().replaceAll('[', '').replaceAll(']', ''),
          "device_token": token,
        });
        print(response.statusCode);

        if (response.statusCode == 200) {
          setState(() {
            buttonclick = false;
          });
          Map<String, dynamic> dic = json.decode(response.body);
          print(response.body);

          if (dic['response_code'] == "1") {
            setState(() {
              buttonclick = false;
            });

            String userResponseStr = json.encode(dic);
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.setString(
                SharedPreferencesKey.LOGGED_IN_USERRDATA, userResponseStr);

            print("PRINT DIC>>>>>>>>>>>>> $dic");
            // Loader().hideIndicator(context);
            setState(() {
              isLoading = false;
            });

            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);

            // Navigator.of(context).pushAndRemoveUntil(
            //   MaterialPageRoute(
            //     builder: (context) => BottomTabbar(),
            //   ),
            //   (Route<dynamic> route) => false,
            // );

            // Navigator.of(context).pushAndRemoveUntil(
            //   MaterialPageRoute(
            //     builder: (context) => Login(),
            //   ),
            //   (Route<dynamic> route) => false,
            // );
          } else {
            // Loader().hideIndicator(context);
            setState(() {
              buttonclick = false;
            });
            toast("Error", dic['message'], context);
          }
        } else {
          // Loader().hideIndicator(context);
          setState(() {
            buttonclick = false;
          });
          toast("Error", "Cannot communicate with server", context);
        }
      } catch (e) {
        if (mounted)
          setState(() {
            buttonclick = false;
          });
        toast("Error", e.toString(), context);
      }
    });
  }

  // dataEntry(userId) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   preferences
  //       .setString(SharedPreferencesKey.LOGGED_IN_USERRDATA, userId)
  //       .then((value) {
  //     setState(() {
  //       globalID = userId;
  //       isLoading = false;
  //     });
  //     Navigator.push(
  //       context,
  //       CupertinoPageRoute(
  //         builder: (context) => BottomTabbar(),
  //       ),
  //     );
  //     toast("Success", "User Register Success", context);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: appColorWhite,
            elevation: 1,
            title: Text(
              "Create Profile",
              style: TextStyle(
                  fontSize: 16,
                  color: appColorBlack,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: appColorBlack,
                )),
            actions: [
              InkWell(
                onTap: () {
                  if (_ageController.text.isNotEmpty &&
                      gender != null &&
                      countryValue != null &&
                      stateValue != null &&
                      cityValue != null) {
                    updateData();
                  } else {
                    toast("Error", "All fields are mandatory", context);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 0, right: 15, left: 0),
                  child: Center(
                    child: Text(
                      'Done',
                      style: TextStyle(
                          color: appColorBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              // ListView(
              //   children: <Widget>[
              //     Container(
              //       height: 10,
              //     ),

              //   ],
              // ),
              editInfoData(),
              Center(child: buttonclick == true ? loader(context) : Container())
            ],
          )),
    );
  }
}
