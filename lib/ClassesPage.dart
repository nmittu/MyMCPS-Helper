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

class ClassesPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ClassesPageState();
  }

}

class ClassesPageState extends State<StatefulWidget>{
  var _isloading = true;
  List<dynamic> _classes;

  ClassesPageState(){
    MyApp.Account.loadClasses().then(classesCallback);
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
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Classes")),
      drawer: Drawer(
        child: SafeArea(child: Column(
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
                        Text("Not affiliated with MCPS or Powerschool", style: TextStyle(fontSize: 15, color: Theme.of(context).accentColor), textAlign: TextAlign.center,)
                      ],
                    )
                  ),
                  InkWell(child: ListTile(title: Text("Logout")), onTap: (){
                    MyApp.Account.deleteAccount();
                    MyApp.Account.logout();
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                    },),
                  InkWell(child: ListTile(title: Text("Theme"),), onTap: (){
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
            InkWell(child: ListTile(title: Text("Dark")), onTap: (){
              if(Theme.of(context).brightness == Brightness.light) {
                Theme.of(context).copyWith(accentColor: Colors.blue);
                SharedPreferences.getInstance().then((pref){
                  pref.setBool("SameAccent", false);
                });
              }
              DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
            },),
          ],
        )),
      ),
      body: SafeArea(
          child: _isloading ? Center(child: CircularProgressIndicator()) : ListView.builder(itemCount: _classes.length,
              itemBuilder: (context, index) => InkWell(
                onTap: (){
                  Navigator.push(context, new CupertinoPageRoute(builder: (context) => new AssignmentsPage(_classes[index].sectionid, _classes[index].courseName)));
                },
                child: Padding( padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(_classes[index].courseName, style: TextStyle(fontSize: 20),),
                      Container(
                        width: 100,
                        decoration: new BoxDecoration(color: GradeUtils.getGradeColor(_classes[index].percent), borderRadius: new BorderRadius.all(Radius.circular(8))),
                        child: Center(child: Text(_classes[index].percent+"%", style: TextStyle(fontSize: 30, color: Colors.white),)),
                      )
                    ],
                  ),
                ),
              )

          )
      ),
    );
  }

}