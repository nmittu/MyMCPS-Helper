import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'main.dart';
import 'package:mymcps_helper/Class.dart';
import 'package:mymcps_helper/AssignmentsPage.dart';
import 'GradeUtils.dart';
import 'LoginPage.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'AppStateHandler.dart';
import 'package:firebase_admob/firebase_admob.dart';

class ClassesPage extends StatefulWidget{
  String name = null;

  ClassesPage(){}

  ClassesPage.withStudentName(String name){
    this.name = name;
  }
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    if(name == null) {
      return new ClassesPageState();
    }else{
      return new ClassesPageState.withStudentName(name);
    }
  }

}

class ClassesPageState extends AppStateHandler{
  var _isloading = true;
  List<dynamic> _classes;
  String title;
  bool canPop = false;

  ClassesPageState(){
    MyApp.Account.loadClasses().then(classesCallback);
    title = "Classes";
  }

  initState(){
    super.initState();
  }

  Future<List<dynamic>> loadWithName(String name) async{
    await MyApp.Account.setActiveAccount(name);
    return await MyApp.Account.loadClasses();
  }

  ClassesPageState.withStudentName(String name){
    title = name;
    loadWithName(name).then(classesCallback);
  }

  double calculateGPA(){
    if(_classes == null)
      return 0;
    return _classes.map((dynamic c) => GradeUtils.getGradeGPA(c.percent)).reduce((a,b)=>a+b)/_classes.length;
  }

  Future<List> filterClasses(List<dynamic> classes) async {
    List<dynamic> classesToShow = new List();

    for(var clazz in classes){
      if(clazz != null && clazz.period != null && clazz.period.length >= 2 && int.parse(clazz.period.substring(0,2)) <= 9 && clazz.courseName.toLowerCase() != "lunch" && clazz.termid == await MyApp.Account.loadTerm()){
        classesToShow.add(await MyApp.Account.loadClassDetails(clazz.sectionid));
      }
    }

    return classesToShow;
  }

  classesCallback(var classes){
    filterClasses(classes).then((clazzes){
      setState(() {
        _isloading = false;
        _classes = clazzes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    // TODO: implement build
    return WillPopScope(onWillPop: () async {
      return canPop;
    },
    child: Scaffold(
      appBar: AppBar(title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title),
          Text("GPA:" + calculateGPA().toStringAsFixed(2), style: TextStyle(fontSize: 10),)
        ],
      )),
      drawer: Drawer(
        child: SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 55), child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  new DrawerHeader(child:
                    Column(
                      children: <Widget>[
                        Text('MyMCPS Helper', style: TextStyle(fontSize: 35, color: Theme.of(context).accentColor)),
                        Text('By: Nikhil Mittu', style: TextStyle(fontSize: 20, color: Theme.of(context).accentColor),),
                        Container(height: 15,),
                        Text("Not affiliated with MCPS or Powerschool", style: TextStyle(fontSize: 15, color: Theme.of(context).accentColor), textAlign: TextAlign.center,),
                        Text("v" + MyApp.version + " b"+ MyApp.buildNumber, style: TextStyle(fontSize: 12, color: Theme.of(context).accentColor), textAlign: TextAlign.center)
                      ],
                    )
                  ),
                  InkWell(child: ListTile(leading: Icon(Icons.arrow_back), title: Text("Logout")), onTap: (){
                    MyApp.Account.deleteAccount();
                    MyApp.Account.logout();
                    canPop = true;
                    Navigator.pop(context);
                    if(title != "Classes"){
                      Navigator.pop(context);
                    }
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                    },),
                  (title == "Classes") ? Container() : InkWell(child: ListTile(leading: Icon(Icons.person), title: Text("Switch student"),), onTap: (){
                    canPop = true;
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },),
                  InkWell(child: ListTile(leading: Icon(Icons.style),title: Text("Theme"),), onTap: (){
                    showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                              title: Text('Select a color'),
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  pickerColor: Theme.of(context).primaryColor,
                                  onColorChanged: (Color color) {
                                    DynamicTheme.of(context).setThemeData(ThemeData(primaryColor: color, accentColor: color, brightness: Theme.of(context).brightness));
                                    SharedPreferences.getInstance().then((SharedPreferences pref){
                                      pref.setInt("ThemeColor", color.value);
                                      pref.setBool("SameAccent", true);
                                    });
                                    MyApp.themeColor = color;
                                  },
                                ),
                              )
                          );
                        }
                    );
                  },)
                ],
              ),
            ),
            InkWell(child: ListTile(leading: Icon(Icons.brightness_4),title: Text("Dark Mode")), onTap: (){
              if(Theme.of(context).brightness == Brightness.light) {
                MyApp.themeColor = null;
                SharedPreferences.getInstance().then((pref){
                  pref.setBool("SameAccent", false);
                });
              }
              DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
            },),
          ],
        )),
      )),
      body: SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 50),
          child: _isloading ? Center(child: CircularProgressIndicator()) : ListView.builder(itemCount: _classes.length,
              itemBuilder: (context, index) => Card(child: InkWell(
                  onTap: (){
                    Navigator.push(context, new CupertinoPageRoute(builder: (context) => new AssignmentsPage(_classes[index].sectionid, _classes[index].courseName)));
                  },
                  child: Padding( padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_classes[index].courseName, style: TextStyle(fontSize: 20),),
                          Text( _classes[index].teacher + " PD: " + _classes[index].period + " RM: " + _classes[index].room, overflow: TextOverflow.ellipsis,)
                        ],
                      )),
                      Container(
                        width: 100,
                        decoration: new BoxDecoration(color: GradeUtils.getGradeColor(_classes[index].percent), borderRadius: new BorderRadius.all(Radius.circular(8))),
                        child: Center(child: Text(_classes[index].percent+"%", style: TextStyle(fontSize: 30, color: Colors.white),)),
                      )
                    ],
                  ),
                )),
              )

          )))
      ),
    );
  }

}
