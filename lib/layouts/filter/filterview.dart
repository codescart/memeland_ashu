import 'dart:async';
import 'dart:convert';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:memeland/global/global.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:memeland/layouts/user/publicProfile.dart';
import 'package:memeland/models/intrest_model.dart';

class FilterView extends StatefulWidget {
  @override
  _FilterViewState createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController controller = new TextEditingController();

  // ignore: unused_field
  String _categoryValue;
  String categoryName;
  IntrestModel intrestModel;
  bool isSearch = false;
  bool isSearchData = false;
  bool clearData = false;
  String countryValue;
  String stateValue;
  String gender;
  var gender1 = [
    'Male',
    'Female',
    'Trans Male',
    'Trans Female',
    'Gender-Fluid',
    'Non-Binary',
    'Queer',
    'Intersex',
    'Other'
  ];

  // String profession;
  // var profession1 = [
  //   "Meeting new people",
  //   "Making new friends",
  //   "Meeting online",
  //   "Meeting in person",
  //   "Dating Men",
  //   "Dating Women",
  //   "Meeting Cis Men",
  //   "Meeting Trans Men",
  //   "Meeting Cis Women",
  //   "Meeting Trans Women",
  //   "Meeting Non Binary  ",
  //   "Meeting Non-Conforming",
  //   "Meeting Queer people",
  //   "Meeting Custom Non-Binary",
  // ];

  double startAge = 18;
  double endAge = 99;
  RangeValues _age = RangeValues(18, 99);

  bool isLoading = false;
  var userData;
  var serchedUserData;

  List userList = [];
  @override
  void initState() {
    _getTopUser();
    // _getintrest();

    super.initState();
  }

  _getTopUser() async {
    setState(() {
      isSearch = true;
    });
    var uri =  Uri.parse('${baseUrl()}/get_all_users');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    userData = json.decode(responseData);
    print('???????????');
    print(userData);

    setState(() {
      isSearch = false;
    });
  }

  _getserchedUser() async {
    closeKeyboard();
    setState(() {
      isSearch = true;
    });
    var uri = Uri.parse('${baseUrl()}/users_filter');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    // request.fields['interests_id'] =
    //     _categoryValue != null ? _categoryValue.toString() : '';
    request.fields['name'] = controller.text.toLowerCase();
    request.fields['country'] = countryValue != null ? countryValue : '';
    request.fields['age'] =
        '${startAge.round().toString()},${endAge.round().toString()}';
    request.fields['gender'] = gender != null ? gender : '';
    request.fields['state'] = stateValue != null ? stateValue : '';

    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    serchedUserData = json.decode(responseData);
    print(serchedUserData);
    if (userData['response_code'] == '1') {
      // print(userData['message']);
      // setState(() {
      //   userList = serchedUserData['users'];
      // });

      // print(userList);

      // onSearchTextChanged();
    }
    print(request.fields);

    setState(() {
      isSearch = false;
    });
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

  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 1,
            title: Text(
              "Accounts",
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColorLight,
                )),
          ),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : LayoutBuilder(
                  builder: (context, constraint) {
                    return Column(
                      children: <Widget>[
                        Container(child: filterWidget(context)),
                        Expanded(
                            child: isSearch == true
                                ? CupertinoActivityIndicator()
                                : _serachuser()),
                      ],
                    );
                  },
                )),
    );
  }

  Widget _serachuser() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Padding(
          padding: const EdgeInsets.only(left: 22, top: 0),
          child: isSearchData == true
              ? ListView.builder(
                  itemCount: serchedUserData['users'].length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, int index) {
                    return allUserWidget(serchedUserData['users'][index]);
                  },
                )
              : isSearchData == false
                  ? ListView.builder(
                      itemCount: userData['users'].length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return allUserWidget(userData['users'][index]);
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text("No search found"),
                      ),
                    )),
    );
  }

  Widget allUserWidget(lists) {
    return lists['id'] == userID
        ? Container()
        : InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PublicProfile(
                        peerId: lists["id"],
                        peerUrl: lists["profile_pic"],
                        peerName: lists["username"])),
              );
            },
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  child: Container(
                    width: SizeConfig.screenWidth,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            lists["profile_pic"].length > 0
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(lists["profile_pic"]),
                                    radius: 28,
                                  )
                                : Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        shape: BoxShape.circle),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Image.asset(
                                        "assets/images/name.png",
                                        height: 10,
                                        color: Colors.white,
                                      ),
                                    )),
                            SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  lists["username"],
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                          ],
                        ),
                        Container(height: 10),
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 10, right: 30),
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Icon(
                        //         Icons.work,
                        //         color: Colors.grey[600],
                        //         size: 22,
                        //       ),
                        //       Container(width: 5),
                        //       Expanded(
                        //         child: Text(
                        //           lists["bio"],
                        //           style: TextStyle(
                        //             color: appColorBlack,
                        //             fontSize: 14,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Container(height: 5),
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 10, right: 20),
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         Icons.location_on,
                        //         color: Colors.grey[600],
                        //         size: 22,
                        //       ),
                        //       Container(width: 3),
                        //       Expanded(
                        //         child: Text(
                        //           lists["city"] +
                        //               ", " +
                        //               lists["state"] +
                        //               ", " +
                        //               lists["country"],
                        //           style: TextStyle(
                        //             color: appColorBlack,
                        //             fontSize: 13,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0, right: 20, top: 5, bottom: 5),
                          child: Container(
                            height: 1,
                            color: Colors.grey[400],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget filterWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Column(
        children: [
          Row(
            children: [
              // Expanded(
              //   child: Container(
              //     height: 43,
              //     child: FormField<String>(
              //       builder: (FormFieldState<String> state) {
              //         return Container(
              //           child: Stack(
              //             children: <Widget>[
              //               Container(
              //                 color: Colors.white,
              //                 child: InputDecorator(
              //                   decoration: InputDecoration(
              //                     enabledBorder: OutlineInputBorder(
              //                       borderSide: BorderSide(
              //                           color: Colors.grey, width: 1),
              //                       borderRadius: BorderRadius.circular(5),
              //                     ),
              //                     focusedBorder: OutlineInputBorder(
              //                       borderSide: BorderSide(
              //                           color: Colors.grey, width: 1),
              //                       borderRadius: BorderRadius.circular(5),
              //                     ),
              //                     errorStyle: TextStyle(
              //                         color: Colors.redAccent, fontSize: 14.0),
              //                     contentPadding: EdgeInsets.only(
              //                         top: 0, bottom: 0, left: 10, right: 15),
              //                   ),
              //                   isEmpty: _categoryValue == '',
              //                   child: DropdownButtonHideUnderline(
              //                     child: DropdownButton<String>(
              //                       isExpanded: true,
              //                       value: _categoryValue,
              //                       isDense: true,
              //                       hint: Text(
              //                         "Profession",
              //                         style: TextStyle(
              //                           color: Colors.black45,
              //                         ),
              //                       ),
              //                       style: TextStyle(
              //                         color: Colors.black,
              //                       ),
              //                       onChanged: (String newValue) {
              //                         setState(() {
              //                           categoryName = newValue;
              //                           _categoryValue = newValue;
              //                           state.didChange(newValue);
              //                         });
              //                       },
              //                       items: intrestModel.interests.map((item) {
              //                         return new DropdownMenuItem(
              //                             child: new Text(
              //                               item.type,
              //                               style: TextStyle(fontSize: 15),
              //                             ),
              //                             value: item.id.toString());
              //                       }).toList(),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // ),
              Container(width: 5),
              // Expanded(
              //   child: Column(
              //     children: [
              //       Text(
              //         "Age:  ${startAge.round().toString()}-${endAge.round().toString()}",
              //         style: TextStyle(fontSize: 12),
              //       ),
              //       SliderTheme(
              //         data: SliderThemeData(
              //             showValueIndicator: ShowValueIndicator.always),
              //         child: RangeSlider(
              //           values: _age,
              //           min: 18,
              //           max: 99,
              //           labels: RangeLabels('${_age.start.round()}' + " yrs",
              //               '${_age.end.round()}' + " yrs"),
              //           inactiveColor: Colors.grey,
              //           activeColor: Colors.green,
              //           onChanged: (RangeValues values) {
              //             setState(() {
              //               _age = values;
              //               startAge = _age.start;
              //               endAge = _age.end;
              //             });
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
          Container(height: 5),
          Row(
            children: [
              Expanded(
                  child: Container(
                  height: 43,
                  child: TextField(
                    controller: controller,
                    //onChanged: onSearchTextChanged,
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 13),
                    decoration: new InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      filled: false,
                      hintStyle:
                          new TextStyle(color: appColorGrey, fontSize: 13),
                      hintText: "Search by Name",
                      fillColor: Colors.grey[300],
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
                ]),
          //     Container(width: 10),
          //     // Expanded(
          //     //   child: Container(
          //     //     height: 43,
          //     //     child: FormField<String>(
          //     //       builder: (FormFieldState<String> state) {
          //     //         return Container(
          //     //           child: Stack(
          //     //             children: <Widget>[
          //     //               Container(
          //     //                 color: Theme.of(context).brightness ==
          //     //                         Brightness.dark
          //     //                     ? Colors.transparent
          //     //                     : Colors.white,
          //     //                 child: InputDecorator(
          //     //                   decoration: InputDecoration(
          //     //                     enabledBorder: OutlineInputBorder(
          //     //                       borderSide: BorderSide(
          //     //                           color: Colors.grey, width: 1),
          //     //                       borderRadius: BorderRadius.circular(5),
          //     //                     ),
          //     //                     focusedBorder: OutlineInputBorder(
          //     //                       borderSide: BorderSide(
          //     //                           color: Colors.grey, width: 1),
          //     //                       borderRadius: BorderRadius.circular(5),
          //     //                     ),
          //     //                     errorStyle: TextStyle(
          //     //                         color: Colors.redAccent, fontSize: 14.0),
          //     //                     contentPadding: EdgeInsets.only(
          //     //                         top: 0, bottom: 0, left: 10, right: 15),
          //     //                   ),
          //     //                   child: DropdownButtonHideUnderline(
          //     //                     child: DropdownButton(
          //     //                       isExpanded: true,
          //     //                       value: gender,
          //     //                       isDense: true,
          //     //                       hint: Padding(
          //     //                         padding: const EdgeInsets.only(top: 0),
          //     //                         child: Text(
          //     //                           'Gender',
          //     //                           style: TextStyle(
          //     //                               color: Colors.grey[600],
          //     //                               fontSize: 13),
          //     //                         ),
          //     //                       ),
          //     //                       icon: Container(),
          //     //                       onChanged: (String newValue) {
          //     //                         setState(() {
          //     //                           gender = newValue;
          //     //                           state.didChange(newValue);
          //     //                         });
          //     //                       },
          //     //                       items: gender1.map((item) {
          //     //                         return new DropdownMenuItem(
          //     //                           child: new Text(
          //     //                             item,
          //     //                             textAlign: TextAlign.center,
          //     //                             style: TextStyle(
          //     //                                 color:Colors.grey.shade600,
          //     //                                 fontSize: 13),
          //     //                           ),
          //     //                           value: item,
          //     //                         );
          //     //                       }).toList(),
          //     //                     ),
          //     //                   ),
          //     //                 ),
          //     //               ),
          //     //             ],
          //     //           ),
          //     //         );
          //     //       },
          //     //     ),
          //     //   ),
          //     // ),
          //   ],
          // ),
          // Container(height: 5),
          // clearData == false
          //     ? CSCPicker(
          //         flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
          //         showCities: false,
          //         showStates: true,
          //         dropdownItemStyle: TextStyle(
          //           color: Theme.of(context).brightness == Brightness.dark
          //               ? Colors.white
          //               : Colors.grey[600],
          //           fontSize: 13,
          //         ),
          //         dropdownHeadingStyle: TextStyle(
          //           color: Theme.of(context).brightness == Brightness.dark
          //               ? Colors.white
          //               : Colors.grey[600],
          //           fontSize: 13,
          //         ),
          //         selectedItemStyle: TextStyle(
          //           color:Colors.grey[600],
          //           fontSize: 13,
          //         ),
          //         disabledDropdownDecoration: BoxDecoration(
          //             borderRadius: BorderRadius.all(Radius.circular(5)),
          //             color: Theme.of(context).brightness == Brightness.dark
          //                 ? Colors.transparent
          //                 : Colors.white,
          //             border: Border.all(color: Colors.grey, width: 1)),
          //         dropdownDecoration: BoxDecoration(
          //             borderRadius: BorderRadius.all(Radius.circular(5)),
          //             color: Theme.of(context).brightness == Brightness.dark
          //                 ? Colors.transparent
          //                 : Colors.white,
          //             border: Border.all(color: Colors.grey, width: 1)),
          //         onCountryChanged: (value) {
          //           setState(() {
          //             countryValue = value;
          //           });
          //         },
          //         onStateChanged: (value) {
          //           setState(() {
          //             stateValue = value;
          //           });
          //         },
          //         onCityChanged: (value) {
          //           setState(() {
          //             // cityValue = value;
          //           });
          //         },
          //       )
          //     : Container(
          //         height: 43,
          //         child: Center(child: const CupertinoActivityIndicator()),
          //       ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 43,
                  child: CustomButtom(
                    title: 'SEARCH',
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.black45,
                    onPressed: () {
                      setState(() {
                        isSearch = true;
                        isSearchData = true;
                      });

                      _getserchedUser();
                    },
                  ),
                ),
              ),
              Container(width: 10),
              Expanded(
                child: SizedBox(
                  height: 43,
                  child: CustomButtom(
                    title: 'CLEAR FILTERS',
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.black45,
                    onPressed: () {
                      setState(() {
                        clearData = true;
                        isSearchData = false;
                        // _searchResult.clear();
                        isSearch = true;
                        _age = RangeValues(18, 99);
                        // _categoryValue = null;
                        startAge = 18;
                        endAge = 99;
                        controller.clear();
                        gender = null;
                        countryValue = null;
                        stateValue = null;
                      });
                      startTime();
                    },
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 0, right: 20, top: 10, bottom: 5),
            child: Container(
              height: 1,
              color: Colors.grey[400],
            ),
          )
        ],
      ),
    );
  }

  // onSearchTextChanged() async {
  //   setState(() {
  //     _searchResult.clear();
  //   });
  //   startTime();

  //   userList.forEach((userDetail) {
  //     if (userDetail['username'] != null) if (userDetail['username']
  //             .toLowerCase()
  //             .contains(controller.text.toLowerCase()) &&
  //         userDetail['gender'].contains(gender != null ? gender : "") &&
  //         userDetail['interests_id'].contains(
  //             _categoryValue != null ? _categoryValue.toString() : "") &&
  //         userDetail['country']
  //             .contains(countryValue != null ? countryValue : "") &&
  //         startAge <= int.parse(userDetail['age']) &&
  //         double.parse(userDetail['age']) <= endAge)
  //       _searchResult.add(userDetail['users']);
  //   });

  //   setState(() {
  //     print(_searchResult);
  //   });
  // }

  startTime() async {
    var _duration = new Duration(seconds: 1);
    return new Timer(_duration, navigationPage);
  }

  navigationPage() {
    setState(() {
      isSearch = false;
      clearData = false;
    });
  }
}

// List _searchResult = [];
