import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'AccountManager.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'admobIds.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:package_info/package_info.dart';


void main(){
  FirebaseAdMob.instance.initialize(appId: admobIds.appId);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((val){
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  static Color themeColor = null;
  static var Account = new AccountManager();
  static double safePaddingBottom;
  static String version;
  static String buildNumber;
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
    FirebaseAnalytics analytics = FirebaseAnalytics();

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch: themeColor != null ? themeColor : Colors.blue,
        accentColor: themeColor != null ? themeColor : Colors.blue,
        brightness: brightness
      ),
      themedWidgetBuilder: (context, theme){
        return MaterialApp(
          //debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: theme,
          home: LoginPage(),
          builder: (context, widget){
            var mediaQuery = MediaQuery.of(context);
            PackageInfo.fromPlatform().then((PackageInfo packageInfo){
              version = packageInfo.version;
              buildNumber = packageInfo.buildNumber;
            });
            //double paddingBottom = 50.0;
            //ouble paddingRight = 0.0;
            safePaddingBottom = mediaQuery.padding.bottom;
            //if (mediaQuery.orientation == Orientation.landscape){
            //  paddingBottom = 0.0;
            //  paddingRight = 50.0;
            //}

            //return new Column(
            //    children: [
            //      Expanded(child: widget),
            //      Container(height: paddingBottom, color: theme.scaffoldBackgroundColor,)
            //    ]
            //);
            return widget;
          },
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics)
          ],
        );
      },
    );


  }
}
