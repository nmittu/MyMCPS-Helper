import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'AccountManager.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static Color themeColor = null;
  static var Account = new AccountManager();
  // This widget is the root of your application.
  static setColor(BuildContext context){
    SharedPreferences.getInstance().then((SharedPreferences pref){
      var color = Color(pref.getInt("ThemeColor"));
      if(pref.getBool("SameAccent")){
        DynamicTheme.of(context).setThemeData(ThemeData(primaryColor: color, accentColor: color, brightness: DynamicTheme.of(context).brightness));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch: themeColor != null ? themeColor : Colors.blue,
        accentColor: themeColor != null ? themeColor : Colors.blue,
        brightness: brightness
      ),
      themedWidgetBuilder: (context, theme){
        return MaterialApp(
          title: 'Flutter Demo',
          theme: theme,
          home: LoginPage(),
        );
      },
    );


  }
}
