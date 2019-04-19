import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'main.dart';

class AnimatedFAB extends StatefulWidget{
  ScrollController scrollController;
  Function onTap;

  AnimatedFAB(ScrollController scrollController, Function onTap){
    this.scrollController = scrollController;
    this.onTap = onTap;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AnimatedFABState(scrollController, onTap);
  }

}

class AnimatedFABState extends State<StatefulWidget> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> size;
  Animation<double> angle;
  Function onTap;

  AnimatedFABState(ScrollController scrollController, Function onTap){
    scrollController.addListener((){
      if (scrollController.position.userScrollDirection == ScrollDirection.forward)
        _animationController.reverse();
      else
        _animationController.forward();
    });
    this.onTap = onTap;
  }

  @override
  void initState() {
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {});
      });

    size = Tween<double>(begin: 1, end: 0).animate(_animationController);
    angle = Tween<double>(begin: 0, end: 180).animate(_animationController);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Transform.scale(scale: size.value, child: FloatingActionButton(onPressed: (){onTap();},child: Transform.rotate(angle: angle.value, child: Icon(Icons.add),))),
        SizedBox(height: 50.0+MyApp.safePaddingBottom)
      ]
    );
  }

}
