import 'package:flutter/material.dart';

class GradeUtils{
  static Color getGradeColor(String percent){
    var per = double.tryParse(percent);
    if(per >= 89.5){
      return Colors.green;
    }else if (per >= 79.5){
      return Colors.blue;
    }else if (per >= 69.5){
      return Colors.orange;
    }else if (per >= 59.5){
      return Colors.deepOrange;
    }else {
      return Colors.red;
    }
  }

  static double getGradePercent(String points, String possible){
    var p = double.tryParse(points);
    var pp = double.tryParse(possible);

    if(p == null ||pp==null || pp==0){
      return 100;
    }else{
      return p/pp*100;
    }
  }

  static double getGradeGPA(String percent){
    var per = double.tryParse(percent);
    if(per >= 89.5){
      return 4;
    }else if (per >= 79.5){
      return 3;
    }else if (per >= 69.5){
      return 2;
    }else if (per >= 59.5){
      return 1;
    }else {
      return 0;
    }
  }
}