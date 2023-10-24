import 'dart:async';
import 'dart:convert';
import 'package:memeland/Helper/sizeConfig.dart';
import 'package:memeland/global/global.dart';
import 'package:memeland/layouts/user/forgotpass.dart';
import 'package:memeland/layouts/user/google_sign_in.dart';
import 'package:memeland/layouts/user/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memeland/shared_preferences/preferencesKey.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailNode = FocusNode();
  final passwordNode = FocusNode();
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                // const Color(0xFFC7A4D5),
                // const Color(0xFFB5B7E0),
                Colors.white,
                Colors.white,
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: WillPopScope(
          onWillPop: () async => false,
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
                                              color: Theme.of(context).primaryColorLight,
                                              fontFamily: 'BrushScript',
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal *
                                                  12.5))),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 10,
                                ),
                                _emailTextfield(context),
                                _passwordTextfield(context),
                                _forgotPassword(),
                                _loginButton(context),
                                // _dontHaveAnAccount(context),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      horizontalLine(),
                                      Text("OR",
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: "Poppins-Medium",
                                              fontWeight: FontWeight.bold,
                                              color: fontColorGrey)),
                                      horizontalLine(),
                                    ],
                                  ),
                                ),
                                //numberButton(),
                                googleButton(),
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
      ),
    );
  }

  Widget _emailTextfield(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: CustomtextField(
          focusNode: emailNode,
          textInputAction: TextInputAction.next,
          controller: emailController,
          hintText: 'Enter Email',
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
          focusNode: passwordNode,
          maxLines: 1,
          controller: passwordController,
          obscureText: !_obscureText,
          hintText: 'Enter Password',
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

  Widget _forgotPassword() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, top: 10),
      child: Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: () {
            setState(() {
              emailNode.unfocus();
              passwordNode.unfocus();
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgetPass()),
            );
          },
          child: Text.rich(
            TextSpan(
              text: 'Forgot Password?',
              style: TextStyle(
                fontSize: 14,
                color: appColor,
                fontWeight: FontWeight.normal,
                fontFamily: "Poppins-Medium",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Padding(
        padding: const EdgeInsets.only(right: 20, top: 0, left: 20),
        child: SizedBox(
          height: SizeConfig.blockSizeVertical * 6,
          width: SizeConfig.screenWidth,
          child: CustomButtom(
            title: 'Log In',
            color: buttonColorBlue,
            onPressed: () {
              if (emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                setState(() {
                  emailNode.unfocus();
                  passwordNode.unfocus();
                  isLoading = true;
                });

                _signInWithEmailAndPassword();
              } else {
                setState(() {
                  emailNode.unfocus();
                  passwordNode.unfocus();
                });
                toast("Error", "Email and password is required", context);
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
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SignUp(),
          ),
        );
      },
      child: Padding(
        padding:
            const EdgeInsets.only(right: 20, top: 10, left: 20, bottom: 10),
        child: Text.rich(
          TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              fontSize: 14,
              color: appColorGrey,
              fontWeight: FontWeight.w700,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  fontSize: 14,
                  // decoration: TextDecoration.underline,
                  color: appColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
            width: SizeConfig.blockSizeHorizontal * 30,
            height: 2.0,
            color: Colors.grey[300]),
      );

  Widget googleButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Container(
          width: SizeConfig.blockSizeHorizontal * 70,
          margin: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
          child: InkWell(
            onTap: () {
              _signInWithGoogle();
            },
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Image.asset('assets/images/google.png',
                    height: SizeConfig.blockSizeVertical * 4),
                new Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Text(
                      "Sign in with Google",
                      style: TextStyle(
                          color: appColor, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          )),
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      FirebaseMessaging().getToken().then((token) async {
        print(token);
        final response = await client.post('${baseUrl()}/login', body: {
          "email": emailController.text,
          "password": passwordController.text,
          "device_token": token,
        });
        print('*****************' + token + '*****************');

        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
          });
          Map<String, dynamic> dic = json.decode(response.body);
          print(response.body);

          if (dic['response_code'] == "1") {
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
          } else {
            // Loader().hideIndicator(context);
            setState(() {
              isLoading = false;
            });
            toast("Error", "Wrong Email / Phone Number, Please try agains",
                context);
          }
        } else {
          // Loader().hideIndicator(context);
          setState(() {
            isLoading = false;
          });
          toast("Error", "Cannot communicate with server", context);
        }
      });

      // final response = await client.post('${baseUrl()}/login', body: {
      //   "phone": emailController.text,
      //   "password": passwordController.text
      // });

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toast("Error", e.toString(), context);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        emailNode.unfocus();
        passwordNode.unfocus();
        isLoading = true;
      });
      signInWithGoogle(context).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      toast("Error", 'Failed to sign in with Google: $e', context);
    }
  }
}
