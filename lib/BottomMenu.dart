import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as Vector;
import 'dart:math';
import 'dart:core';
import 'package:flutter/animation.dart';

class BottomMenu extends StatefulWidget{
  BottomMenu({Key key, this.flippedCards, this.resetCallback}) : super(key: key);

  final List<String> flippedCards;
  final VoidCallback resetCallback;

  @override
  BottomMenuState createState() => new BottomMenuState();

}

class BottomMenuState extends State<BottomMenu> with TickerProviderStateMixin{

  bool expanded = false;
  double slidingDistance = 280.0 - 70.0;
  Matrix4 transformationMatrix = new Matrix4.identity();
  Offset offset;
  Offset difference; // used because onPanUp doesnt provide a global position
  Offset touchDown;
  
  AnimationController animationController;

  @override
  void initState() {
    super.initState();

    offset = new Offset(0.0, slidingDistance);
    transformationMatrix = new Matrix4.translationValues(0.0, offset.dy, 0.0);

  }

  toggleState(){
    expanded = !expanded;
    animateTo(expanded);
  }

  reset(){
    if(widget.resetCallback != null)
      widget.resetCallback();
  }

  animateTo(bool expand){
    
    if(animationController != null){
      animationController.reset();
      animationController.dispose();
    }

    animationController = new AnimationController(
        duration: const Duration(milliseconds: 200), 
        vsync: this,
        );
    
    CurvedAnimation easeOutController = new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    Animation<double> animationPosition;
    //animationPosition = new Tween(begin: offset.dy, end: 0.0).animate(easeOutController);

    if(expand){
      animationPosition = new Tween(begin: offset.dy, end: 0.0).animate(easeOutController)
      ..addStatusListener((AnimationStatus status){
        if(status == AnimationStatus.completed)
          offset = new Offset(0.0, 0.0);
      });
    }else{
      animationPosition = new Tween(begin: offset.dy, end: slidingDistance).animate(easeOutController)
      ..addStatusListener((AnimationStatus status){
        if(status == AnimationStatus.completed)
          offset = new Offset(0.0, slidingDistance);
      });
    }

    animationPosition.addListener(() {
      setState(() {
        transformationMatrix = new Matrix4.translationValues(0.0, animationPosition.value, 0.0);
      });
    });

    animationController.addStatusListener((AnimationStatus status){
      if(status == AnimationStatus.completed && animationController != null){
        animationController.dispose();
        animationController = null;
      }
    });
    animationController.reset();
    animationController.forward();
  }

  onPanDown(DragDownDetails details){
    touchDown = details.globalPosition;
  }

  onPanUpdate(DragUpdateDetails details){
    setState(() {
      difference = details.globalPosition - touchDown + offset;

      if(difference.dy < 0)
        difference = new Offset(0.0, 0.0);
      if(difference.dy > slidingDistance)
        difference = new Offset(0.0, slidingDistance);

      transformationMatrix = new Matrix4.translationValues(0.0, difference.dy, 0.0);
    });

  }
  
  onPanUp(DragEndDetails details){
    offset = difference;
  }

  @override
  Widget build(BuildContext context){

    List<Widget> cards = [];
    for(String card in widget.flippedCards){
      cards.add(
        new Padding(
          padding: new EdgeInsets.all(5.0),
          child: new Image(
            image: new AssetImage('assets/' + card + '.png'),
          ), 
        ), 
      );
    }

    return new GestureDetector(
      onPanDown: onPanDown,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanUp,
      child: new Container(
        transform: transformationMatrix,
        //color: Color(0xAA000000),
        child: new SizedBox(
          height: 280.0,
          child: new Column(
          //child: new Row(
            children: <Widget>[
              new SizedBox(
                height: 70.0,
                child: new IconButton(
                  icon: new Icon(Icons.expand_less),
                  color: Colors.grey,
                  tooltip: 'Options',
                  padding: new EdgeInsets.all(20.0),
                  onPressed: toggleState,
                ),
              ),
              new SizedBox(
                height: 50.0,
                child: new IconButton(
                  icon: new Icon(Icons.replay),
                  color: Colors.grey,
                  tooltip: 'New deck',
                  //padding: new EdgeInsets.all(25.0),
                  onPressed: reset,
                ),
              ),
              new SizedBox(
                height: 150.0,
                child: new ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: cards,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  dispose(){
    if(animationController != null)
      animationController.dispose();
    super.dispose();
  }
}