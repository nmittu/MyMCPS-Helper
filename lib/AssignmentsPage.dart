import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'main.dart';
import 'GradingCategory.dart';
import 'Assignment.dart';
import 'package:tuple/tuple.dart';
import 'GradeUtils.dart';
import 'AnimatedFAB.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io' show Platform;
import 'dart:math';
import 'AppStateHandler.dart';

class AssignmentsPage extends StatefulWidget {
  String secid;
  String className;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new AssignmentPageState(secid, className);
  }

  AssignmentsPage(String secid, String className){
    this.secid = secid;
    this.className = className;
  }

}

class AssignmentPageState extends AppStateHandler{
  List<dynamic> Categories;
  List<dynamic> Grades;
  List<dynamic> CategoryNames;
  double _total;
  String className;
  bool _isloading = true;
  bool fabVisible = true;

  AssignmentPageState(String secid, String className){
    this.className = className;
    loadData(secid).then((Tuple2 data){
      Categories = data.item1;
      Grades = data.item2;
      CalculateGrade();
    });
  }

  void CalculateGrade(){
    Map<String, List<double>> totals = new Map();

    for (var category in Categories){
      totals[category.Description] = new List.from([0.toDouble(), 0.toDouble()]);
    }

    for(var g in Grades){
      if (g.Grade != null && g.Grade.toLowerCase() == "x"){
        continue;
      }

      List<double> pair;
      try{
        pair = totals[g.AssignmentType];
      }catch(exception){
        continue;
      }

      try{
        if (!(g.Grade != null && g.Grade.toLowerCase() == "z")){
          pair[0] += double.parse(g.Points);
        }
      }catch(exception){
        continue;
      }

      try{
        pair[1] += double.parse(g.Possible);
      }catch(exception){
        pair[0] -= double.parse(g.Points);
        continue;
      }
    }

    double totalWeights = 0;
    double total = 0;
    for (var gc in Categories){
      double weight = 0;

      if(gc.Description != ""){
        weight = double.parse(gc.Weight);
      }

      if (totals[gc.Description][1] != 0){
        totalWeights += double.parse(gc.Weight);
      }

      if (totals[gc.Description][1] != 0){
        total += (totals[gc.Description][0]/totals[gc.Description][1]) * weight;
      }
    }

    total /= totalWeights;
    total *= 100;

    setState(() {
      _total = total;
      _isloading = false;
      for (var cat in Categories){
        cat.PointsEarned = totals[cat.Description][0].toString();
        cat.PointsPossible = totals[cat.Description][1].toString();
      }
    });
  }

  Future<Tuple2<dynamic, dynamic>> loadData(String secid) async {
    List<dynamic> categories = await MyApp.Account.loadCategories(secid);
    List<dynamic> grades = await MyApp.Account.loadAssignments(secid);

    List<String> cat_names = new List();
    for(int i = 0; i < categories.length; i++){
      var cat = categories[i];
      if(cat == null || cat.Description == null || cat_names.contains(cat.Description)){
        categories.removeAt(i);
        i--;
        continue;
      }
      cat_names.add(cat.Description);
    }

    CategoryNames = cat_names;

    for(int i = 0; i < grades.length; i++){
      var g = grades[i];
      if(g == null || g.Description == null){
        grades.removeAt(i);
        i--;
      }
    }

    return new Tuple2(categories, grades);
  }


  Map<int, TextField> pointsMap = new Map();
  Map<int, TextField> possibleMap = new Map();
  TextField getTextField(Map<int, TextField> map, int index, {String text, var Obj, Function onChange, bool addDelta = true}){
    if(map.containsKey(index)){
      //We want to keep everything the same except for the onChange function (we need the index var in the onChange to update).
      return TextField(focusNode: map[index].focusNode, decoration: map[index].decoration, keyboardType: map[index].keyboardType, controller: map[index].controller, onChanged: onChange, keyboardAppearance: map[index].keyboardAppearance,);
    }


    var ret = TextField(focusNode: FocusNode(), decoration: InputDecoration(contentPadding: EdgeInsets.all(5)), keyboardType: TextInputType.number, controller: TextEditingController(text: text) ,onChanged: onChange, keyboardAppearance: Theme.of(context).brightness);

    map[index] = ret;
    return ret;
  }
  
  ScrollController scrollController = ScrollController();
  
  void showPicker(BuildContext context, int index){
    if(Platform.isIOS){
      showCupertinoModalPopup(context: context, builder: (context) => Container(
          height: 250,
          child:DefaultTextStyle(
              style: const TextStyle(
                color: CupertinoColors.black,
                fontSize: 22.0,

              ),
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: CategoryNames.indexOf(Grades[index].AssignmentType)),
                itemExtent: 30,
                children: CategoryNames.map((var cat_name) => Text(cat_name)).toList(),
                onSelectedItemChanged: (int val){
                  Grades[index].AssignmentType = CategoryNames[val];
                  CalculateGrade();
                },
              )
          )
      ),);
    }else{
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return SimpleDialog(
            title: Text("Categories"),
            children: CategoryNames.map((var cat_name) => SimpleDialogOption(onPressed: () => Navigator.pop(context, cat_name), child: Text(cat_name))).toList(),
          );
        }
      ).then((var value){
        if(value != null) {
          Grades[index].AssignmentType = value;
          CalculateGrade();
        }
      });
    }
  }

  String getPointsFormatted(Assignment g){
    if(g.Grade != null && (g.Grade.toLowerCase() == "z" || g.Grade.toLowerCase() == "x")){
      return g.Grade;
    }
    return g.Points;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
      ),
      floatingActionButton: AnimatedFAB(scrollController, (){
        FocusScope.of(context).requestFocus(FocusNode());
        Grades.insert(0, Assignment(AssignmentType: CategoryNames[0], Description: "New Assignment", Points: "", Possible: "10.0"));
        pointsMap = pointsMap.map((int i, TextField tf) => MapEntry(i+1, tf));
        possibleMap = possibleMap.map((int i, TextField tf) => MapEntry(i+1, tf));
        CalculateGrade();
      }),
      body: GestureDetector(onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },child: SafeArea(
          child: _isloading ? Center(child: CircularProgressIndicator()) : Column(
            children: <Widget>[
              Card(child: Container(child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: Categories.length+1,
                  itemBuilder: (context, index) => Padding( padding: EdgeInsets.fromLTRB(6,2,6,2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          index < Categories.length ? Text(Categories[index].Description, style: TextStyle(fontSize: 15)) : Container(),
                          index < Categories.length ? Text(Categories[index].PointsEarned.toString() + "/" + Categories[index].PointsPossible.toString() + " (" + ((double.parse(Categories[index].PointsPossible) == 0) ? "100" : (100*double.parse(Categories[index].PointsEarned)/double.parse(Categories[index].PointsPossible)).toStringAsFixed(1)) + "%)", style: TextStyle(fontSize: 15),) : Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Container(
                              width: 100,
                              decoration: new BoxDecoration(color: GradeUtils.getGradeColor(_total.toString()), borderRadius: new BorderRadius.all(Radius.circular(8))),
                              child: Center(child: Text(_total.toStringAsPrecision(3)+"%", style: TextStyle(fontSize: 30, color: Colors.white),))
                            )
                          )
                        ],
                      )
                  )
              ),) ,),
              Expanded(child:ListView.builder(
                controller: scrollController,
                  itemCount: Grades.length,
                  itemBuilder: (context, index) => Slidable(delegate: SlidableDrawerDelegate(), actionExtentRatio: 0.25,  child: Padding(
                    padding: EdgeInsets.all(0),//EdgeInsets.fromLTRB(6, 2, 6, 2),
                    child: Card(child: Padding(padding: EdgeInsets.fromLTRB(5, 0, 5, 5),child:Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.fromLTRB(5, 5, 0, 0), child: Align(alignment: Alignment.centerLeft ,child: Text(Grades[index].Description, maxLines: 2,style: TextStyle(fontSize: 17),))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(child: Padding(padding: EdgeInsets.all(5), child: Container(child: TextField(enableInteractiveSelection: false, focusNode: AlwaysDisabledFocusNode(), decoration: InputDecoration(contentPadding: EdgeInsets.all(5)), keyboardType: TextInputType.number, controller: TextEditingController(text: Grades[index].AssignmentType),onTap: (){
                              //FocusScope.of(context).requestFocus(new FocusNode());
                              showPicker(context, index);
                            },),))),
                            Padding(padding: EdgeInsets.all(5), child: Container(child: Row(children: <Widget>[
                              Container(width: 40, child: getTextField(pointsMap, index, text: getPointsFormatted(Grades[index]), onChange: (String val){
                                Grades[index].Grade = "";
                                Grades[index].Points = val;
                                CalculateGrade();
                              }),),
                              Align(alignment: Alignment.centerLeft, child: Text("/")),
                              Container(width: 40, child: getTextField(possibleMap, index, text: Grades[index].Possible, addDelta: false, onChange: (String val){
                                Grades[index].Possible = val;
                                CalculateGrade();
                              }),),
                            ],),)),
                            Padding(padding: EdgeInsets.all(5), child: Container(
                              width: 100,
                              decoration: new BoxDecoration(color: GradeUtils.getGradeColor(GradeUtils.getGradePercent(Grades[index].Points, Grades[index].Possible).toString()), borderRadius: new BorderRadius.all(Radius.circular(8))),
                              child: Center(child: Text((GradeUtils.getGradePercent(Grades[index].Points, Grades[index].Possible).toStringAsPrecision(3)+"%"), style: TextStyle(fontSize: 30, color: Colors.white),))
                            ))
                        ],)
                      ],
                    ))),
                  ),
                  secondaryActions: <Widget>[IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: (){
                        Grades.removeAt(index);
                        possibleMap.remove(index);
                        pointsMap.remove(index);
                        pointsMap = pointsMap.map((int i, TextField tf) => i>index ? MapEntry(i-1, tf) : MapEntry(i, tf));
                        possibleMap = possibleMap.map((int i, TextField tf) => i>index ? MapEntry(i-1, tf) : MapEntry(i, tf));
                        CalculateGrade();
                      },)],
                  )
              ))
            ],
          )
      )),
    );
  }

}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}