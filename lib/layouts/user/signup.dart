import 'dart:convert';

import 'package:memeland/Helper/sizeConfig.dart';
import 'package:memeland/global/global.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:memeland/layouts/user/createProfile.dart';
import 'package:memeland/layouts/webview/webview.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  File imageFile;
  bool isLoading = false;
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = false;
  bool checkedValue = false;

  @override
  void initState() {
    super.initState();
  }

  String userId;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpassController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  // Future<void> _register() async {
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     toast("Error", e.toString(), context);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(
      decoration: BoxDecoration(
        color: Color(0XFF106C6F),
      ),
      child: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                // const Color(0xFFC7A4D5),
                // const Color(0xFFB5B7E0),
                Colors.white,
                Colors.white
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: LayoutBuilder(builder: (context, constraint) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 100),
                              //   child: Center(child: _appIcon()),
                              // ),
                              SizedBox(height: 80,),
                              Container(
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new AssetImage(
                                          'assets/images/appicon.png',
                                        ),
                                      )
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Center(
                                    child: Text('Memeland',
                                        style: TextStyle(
                                            fontFamily: 'BrushScript',
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal *
                                                    12.5))),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical * 4,
                              ),
                              _nameTextfield(context),
                              _passwordTextfield(context),
                              _emailTextfield(context),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical * 2,
                              ),
                              _termsCondition(context),
                              //  _mobTextfield(context),
                              _loginButton(context),
                            ],
                          ),
                          isLoading == true
                              ? Center(child: loader(context))
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  _dontHaveAnAccount(context),
                ],
              );
            })),
      ),
    );
  }

  Widget _nameTextfield(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: CustomtextField(
          maxLines: 1,
          textInputAction: TextInputAction.next,
          controller: nameController,
          hintText: 'Enter Username',
          prefixIcon: Icon(
            Icons.person,
            color: iconColor,
            size: 30.0,
          ),
        ));
  }

  Widget _passwordTextfield(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: CustomtextField(
          textInputAction: TextInputAction.next,
          controller: passwordController,
          maxLines: 1,
          hintText: 'Enter Password',
          obscureText: !_obscureText,
          prefixIcon: Icon(
            Icons.lock,
            color: iconColor,
            size: 30.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: appColorGrey,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ));
  }

  Widget _emailTextfield(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
      child: CustomtextField(
        maxLines: 1,
        textInputAction: TextInputAction.next,
        controller: emailController,
        hintText: 'Enter Email',
        prefixIcon: Icon(
          Icons.email,
          color: iconColor,
          size: 30.0,
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Padding(
        padding: const EdgeInsets.only(right: 20, top: 0, left: 20),
        child: SizedBox(
          height: SizeConfig.blockSizeVertical * 6,
          width: SizeConfig.screenWidth,
          child: CustomButtom(
            title: 'Sign Up',
            color: buttonColorBlue,
            onPressed: () {
              Pattern pattern =
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              RegExp regex = new RegExp(pattern);
              if (passwordController.text != '' &&
                  nameController.text != '' &&
                  // mobileController.text != '' &&
                  regex.hasMatch(emailController.text.trim()) &&
                  emailController.text.trim() != '' &&
                  passwordController.text.length > 5 &&
                  checkedValue != false) {
                _apiCall();

                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => CreateProfile(
                //         name: nameController.text,
                //         password: passwordController.text,
                //         email: emailController.text)));
              } else {
                if (nameController.text.isEmpty)
                  simpleAlertBox(
                      content: Text("Please enter username"), context: context);
                else if (passwordController.text.isEmpty) {
                  simpleAlertBox(
                      content: Text(
                          "Fields is empty or password length should be between 6-8 characters."),
                      context: context);
                } else if (emailController.text.isEmpty) {
                  simpleAlertBox(
                      content: Text("please enter email"), context: context);
                } else if (checkedValue == false) {
                  simpleAlertBox(
                      content: Text("Accept term & condition to continue"),
                      context: context);
                } else {
                  simpleAlertBox(
                      content: Text("please enter valid email"),
                      context: context);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _dontHaveAnAccount(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(right: 20, top: 10, left: 20, bottom: 10),
        child: Text.rich(
          TextSpan(
            text: "Already have an account? ",
            style: TextStyle(
              fontSize: 14,
              color: appColorGrey,
              fontWeight: FontWeight.w700,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  fontSize: 14,
                  // decoration: TextDecoration.underline,
                  color: fontColorBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _termsCondition(BuildContext context) {
    void _handleURLButtonPress(BuildContext context, String url) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => WebViewContainer(url)));
    }

    return CheckboxListTile(
      activeColor: appColor,
      title: Wrap(
        alignment: WrapAlignment.start,
        children: <Widget>[
          Text("By using our app you agree to our ",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Theme.of(context).primaryColorLight,
              )),
          InkWell(
            onTap: () {
              _handleURLButtonPress(context,
                  "https://memeland.in/terms.html");
            },
            child: Text("Terms and Conditions ",
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold)),
          ),
          Text("and ",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Theme.of(context).primaryColorLight,
              )),
          InkWell(
            onTap: () {
              _handleURLButtonPress(context,
                  "https://memeland.in/policy.html");
            },
            child: Text("Privacy Policy",
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),

      value: checkedValue,
      onChanged: (newValue) {
        setState(() {
          checkedValue = newValue;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    );
  }

  Future<void> _apiCall() async {
    try {
      setState(() {
        isLoading = true;
      });

      // final response = await client.post('${baseUrl()}/login', body: {
      //   "phone": emailController.text,
      //   "password": passwordController.text
      // });

      final response =
          await client.post('${baseUrl()}/username_email_check', body: {
        "username": nameController.text,
        "email": emailController.text.toLowerCase().trim().toString(),
        "password": passwordController.text
      });

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        Map<String, dynamic> dic = json.decode(response.body);
        print(response.body);

        if (dic['response_code'] == "1") {
          print("PRINT DIC>>>>>>>>>>>>> $dic");
          // Loader().hideIndicator(context);
          setState(() {
            isLoading = false;
          });

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  CreateProfile(
                  id: dic['user']['id'],
                  name: nameController.text,
                  password: passwordController.text,
                  email: emailController.text)));
        } else {
          // Loader().hideIndicator(context);
          setState(() {
            isLoading = false;
          });
          toast("Error", dic['message'], context);
        }
      } else {
        // Loader().hideIndicator(context);
        setState(() {
          isLoading = false;
        });
        toast("Error", "Cannot communicate with server", context);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toast("Error", e.toString(), context);
    }
  }
}
