import 'package:flutter/material.dart';
import 'dart:core';
import 'LoginPage.dart';
import 'main.dart';
import 'package:firebase_admob/firebase_admob.dart';

abstract class AppStateHandler extends State<StatefulWidget> with WidgetsBindingObserver{
  static var _timeOfClose;
  BuildContext context;
  BannerAd banner;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

  }
  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.paused:
        _timeOfClose = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        if(DateTime.now().difference(_timeOfClose).inMinutes>10){
          MyApp.Account.logout();
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage.fromPop(pop: true,)));
        }
        break;
      default:
        break;
    }
  }
}
