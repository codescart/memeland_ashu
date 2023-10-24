import 'package:memeland/app.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance().then(
    (prefs) {
      runApp(
        Snapta(prefs),
      );
    },
  );
}
