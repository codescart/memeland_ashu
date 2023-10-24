import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:memeland/global/global.dart';
import 'package:memeland/layouts/user/login.dart';
import 'package:memeland/layouts/user/saved_bookmars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memeland/layouts/webview/webview.dart';
import 'package:memeland/shared_preferences/preferencesKey.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  void _handleURLButtonPress(BuildContext context, String url) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(url)));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          GestureDetector(
              onTap: () {},
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: appColor,
                ),
                accountName: Text(
                  userName,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .merge(TextStyle(color: Colors.white)),
                ),
                accountEmail: Text(
                  userEmail,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .merge(TextStyle(color: Colors.white)),
                ),
                currentAccountPicture: userImage != '' && userImage != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(userImage),
                      )
                    : CircleAvatar(
                        // backgroundColor: Colors.white,
                        radius: 50,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset(
                            'assets/images/user.png',
                            color: Colors.white,
                          ),
                        )),
              )),

          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/Pages', arguments: 0);
            },
            leading: Icon(
              CupertinoIcons.house_fill,
              // ignore: deprecated_member_use
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColorWhite
                  : Theme.of(context).colorScheme.secondary.withOpacity(1),
            ),
            title: Text(
              'Home',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/Pages', arguments: 4);
            },
            leading: Icon(
              CupertinoIcons.person_crop_circle_fill,
              // ignore: deprecated_member_use
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColorWhite
                  : Theme.of(context).colorScheme.secondary.withOpacity(1),
              size: 27,
            ),
            title: Text(
              'Profile',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedBookmarks()),
              );
            },
            leading: Icon(
              CupertinoIcons.bookmark,
              // ignore: deprecated_member_use
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColorWhite
                  : Theme.of(context).colorScheme.secondary.withOpacity(1),
              size: 27,
            ),
            title: Text(
              'Saved',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            onTap: () {
              if (themeSwitch != true) {
                setState(() {
                  themeSwitch = true;
                });
                setBrightness(Brightness.dark);
                DynamicTheme.of(context).setTheme(1);
              } else {
                setState(() {
                  themeSwitch = false;
                });
                setBrightness(Brightness.light);
                DynamicTheme.of(context).setTheme(0);
              }
            },
            leading: Icon(
              themeSwitch ? Icons.light_mode : Icons.dark_mode,
              // ignore: deprecated_member_use
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColorWhite
                  : Theme.of(context).colorScheme.secondary.withOpacity(1),
            ),
            title: Text(
              themeSwitch ? "Light mode" : "Dark mode",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),

          ListTile(
            onTap: () {
              _launch('https://memeland.in/');
            },
            leading: Icon(
              Icons.assignment_rounded,
              // ignore: deprecated_member_use
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColorWhite
                  : Theme.of(context).colorScheme.secondary.withOpacity(1),
            ),
            title: Text(
              'Help',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),

          ListTile(
            onTap: () {
              // Navigator.of(context).pushNamed('/Pages', arguments: 3);
            },
            // trailing: Icon(
            //   Icons.remove,
            //   // ignore: deprecated_member_use
            //   color: Theme.of(context).accentColor.withOpacity(1),
            // ),
            title: Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          ListTile(
            onTap: () {
              _handleURLButtonPress(context,
                  "https://memeland.in/privacy.html");
              // Navigator.of(context).pushNamed('/Pages', arguments: 3);
            },
            leading: Icon(
              Icons.info,
              // ignore: deprecated_member_use
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColorWhite
                  : Theme.of(context).colorScheme.secondary.withOpacity(1),
            ),
            title: Text(
              'Terms and condition',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            onTap: () {
              _handleURLButtonPress(context,
                  "https://memeland.in/terms.html");
              // Navigator.of(context).pushNamed('/Pages', arguments: 3);
            },
            leading: Icon(
              Icons.privacy_tip,
              // ignore: deprecated_member_use
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColorWhite
                  : Theme.of(context).colorScheme.secondary.withOpacity(1),
            ),
            title: Text(
              'Privacy policy ',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            onTap: () {
              _launch('https://memeland.in/index.html');
              // Navigator.of(context).pushNamed('/Pages', arguments: 3);
            },
            leading: Icon(
              Icons.help,
              // ignore: deprecated_member_use
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColorWhite
                  : Theme.of(context).colorScheme.secondary.withOpacity(1),
            ),
            title: Text(
              'About',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),

          ListTile(
            onTap: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences
                  .remove(SharedPreferencesKey.LOGGED_IN_USERRDATA)
                  .then((_) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                  (Route<dynamic> route) => false,
                );
                // Navigator.of(context, rootNavigator: true)
                //     .pop();
              });
              // if (currentUser.value.apiToken != null) {
              //   logout().then((value) {
              //     Navigator.of(context)
              //         .pushNamedAndRemoveUntil('/Pages', (Route<dynamic> route) => false, arguments: 2);
              //   });
              // } else {
              //   Navigator.of(context).pushNamed('/Login');
              // }
            },
            leading: Icon(
              Icons.exit_to_app,
              // ignore: deprecated_member_use
              color: Theme.of(context).brightness == Brightness.dark
                  ? appColorWhite
                  : Theme.of(context).colorScheme.secondary.withOpacity(1),
            ),
            title: Text(
              'Logout',
              // ignore: deprecated_member_use
            ),
          ),
          // setting.value.enableVersion
          //     ? ListTile(
          //         dense: true,
          //         title: Text(
          //           S.of(context).version + " " + setting.value.appVersion,
          //           style: Theme.of(context).textTheme.body1,
          //         ),
          //         trailing: Icon(
          //           Icons.remove,
          //           color: Theme.of(context).focusColor.withOpacity(0.3),
          //         ),
          //       )
          //     : SizedBox(),
        ],
      ),
    );
  }

  _launch(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
