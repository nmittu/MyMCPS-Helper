import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'AccountManager.dart';
import 'package:dynamic_theme/dynamic_theme.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static var Account = new AccountManager();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch: Colors.blue,
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
