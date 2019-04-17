import 'package:flutter/material.dart';
import 'main.dart';
import 'package:mymcps_helper/ClassesPage.dart';

class StudentsPage extends StatelessWidget{
  List<dynamic> studentNames = MyApp.Account.getStudentNames();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Students"),),
      body: SafeArea(
          child: ListView.builder(
              itemCount: studentNames.length,
              itemBuilder: (context, index){
                return Card(
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, new MaterialPageRoute(builder: (context) => ClassesPage.withStudentName(studentNames[index])));
                    },
                    child: Padding(padding: EdgeInsets.all(10), child: Text(studentNames[index], style: TextStyle(fontSize: 20))),
                  ),
                );
              }
          )
      ),
    );
  }

}