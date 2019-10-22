import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';
import 'dart:core';
import 'package:flutter/animation.dart';

class CardImage extends StatefulWidget{
  CardImage({Key key, this.image, this.constant = false, this.id = -1, this.onRemove}) : super(key: key);

  final int id;
  final String image;
  final bool constant;
  final VoidCallback onRemove;

  @override
  CardImageState createState() => new CardImageState();
}

enum CardStates{
  constant, faceDown, faceUp, flipping, gone
}

class CardImageState extends State<CardImage> with TickerProviderStateMixin{

  CardStates state = CardStates.constant;

  Vector3 size = Vector3(300.0, 418.5, 0.0);
  String imageFile = 'back_blue';

  Vector3 touchDown;
  Matrix4 transformationMatrix = Matrix4.translationValues(0.0, 0.0, 0.0);
  Vector3 rotation = new Vector3.zero();
  Vector3 position = new Vector3.zero();

  double freePlay = 100.0;
  double rotationSpeed = 100.0;
  double flipOffset = 418.5;

  AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print('init Card');


    if(!widget.constant)
      setCardState(CardStates.faceDown);
  }

  @override
  didUpdateWidget(CardImage oldCardImage){
    super.didUpdateWidget(oldCardImage);

    setState(() {
      position = Vector3.zero();      
      rotation = Vector3.zero();     

      setCardState(widget.constant ? CardStates.constant : CardStates.faceDown); 
    });
  }

  setCardState(CardStates state){
    //print(state);
    this.state = state;
    
    switch(state){
      case CardStates.faceDown:
        //print("faceDown");
        animateTo(CardStates.faceDown);
        break;
      case CardStates.flipping:
        //print("flipping");
        //imageFile = widget.image;
        break;
      case CardStates.faceUp:
        //print("faceUp");
        animateTo(CardStates.faceUp);
        break;
      case CardStates.gone:
        //print("gone");
        animateTo(CardStates.gone);
        break;
    }
  }

  updateView(){
    transformationMatrix = Matrix4.translation(position) * getRotationMatrix(rotation);

    imageFile = rotation.x.abs() > pi/2 ? widget.image : 'back_blue';
  }

  Matrix4 getRotationMatrix(Vector3 rotation){
    
    final perspective = 0.0008;
    Matrix4 projection = new Matrix4.identity()
      ..setEntry(3, 2, -perspective);
      //..setEntry(0, 0, 1 / radius)
      //..setEntry(1, 1, 1 / radius)
      //..setEntry(2, 3, -radius)
      //..setEntry(3, 3, perspective * radius + 1.0);

    projection *= new Matrix4.rotationX(rotation.x);
    projection *= new Matrix4.rotationY(rotation.y);

    //return new Matrix4.translation(center) * projection * new Matrix4.translation(-center);
    return projection;
  }

  calculateTransformationValues(Vector3 position, Vector3 speed){
    switch(state){
      case CardStates.faceDown:
        this.position = position;

        if(position.y > freePlay){
          Vector3 scaledPosition = position / position.length * (position.length - freePlay) / rotationSpeed;
          rotation = scaledPosition.cross(new Vector3(0.0, 0.0, 1.0));

          if(rotation.x > pi/2){
            setCardState(CardStates.flipping);
          }

        }else{
          this.rotation = new Vector3.zero();
        }

        break;

      case CardStates.flipping:
        this.position = position;

        if(rotation.x < pi){
          Vector3 scaledPosition = position / position.length * (position.length - freePlay) / rotationSpeed;
          Vector3 realRotation = scaledPosition.cross(new Vector3(0.0, 0.0, 1.0));

          double rx = rotation.x + (speed.y.abs() / rotationSpeed);
          double ry = realRotation.y * ( 2 - 2 * rx / pi);
          rotation = new Vector3(rx, ry, 0.0);
        }else{
          this.rotation = new Vector3(pi, 0.0, 0.0);
        }

        break;

      case CardStates.faceUp:
        this.position = position + new Vector3(0.0, flipOffset, 0.0);
        this.rotation = new Vector3(pi, 0.0, 0.0);
        break;

      case CardStates.constant:
      default:
        this.position = new Vector3.zero();
        this.rotation = new Vector3.zero();
        break;
    }
  }

  animateTo(CardStates state){
    if(state == CardStates.flipping || state == CardStates.constant)
      return;

    if(animationController != null){
      animationController.reset();
      animationController.dispose();
    }

    animationController = new AnimationController(
        duration: const Duration(milliseconds: 200), 
        vsync: this,
        );

    if(state == CardStates.faceDown){
      CurvedAnimation easeOutController = new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

      Animation<Vector3> animationPosition;
      animationPosition = new Tween(begin: position.clone(), end: Vector3.zero()).animate(easeOutController)
        ..addListener(() {
          setState(() {
            position = animationPosition.value;
          });
        });
      Animation<Vector3> animationRotation;
      animationRotation = new Tween(begin: rotation.clone(), end: Vector3.zero()).animate(easeOutController)
        ..addListener(() {
          setState(() {
            rotation = animationRotation.value;
          });
        });
    }

    if(state == CardStates.faceUp){
      CurvedAnimation easeOutController = new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

      Animation<Vector3> animationPosition;
      animationPosition = new Tween(begin: position.clone(), end: new Vector3(0.0, flipOffset, 0.0)).animate(easeOutController)
        ..addListener(() {
          setState(() {
            position = animationPosition.value;
          });
        });
      Animation<Vector3> animationRotation;
      animationRotation = new Tween(begin: rotation.clone(), end: new Vector3(pi, 0.0, 0.0)).animate(easeOutController)
        ..addListener(() {
          setState(() {
            rotation = animationRotation.value;
          });
        });
    }

    if(state == CardStates.gone){
      Animation<Vector3> animationPosition;
      animationPosition = new Tween(begin: position.clone(), end: new Vector3(0.0, -1.5 * flipOffset, 0.0)).animate(animationController)
        ..addListener(() {
          setState(() {
            position = animationPosition.value;
          });
        })
        ..addStatusListener((AnimationStatus status){
          if(status == AnimationStatus.completed){
            if(widget.onRemove != null)
              widget.onRemove();
          }
        });
    }
    
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
    if(widget.constant)
      return;
    //print("onPanDown");
    setState(() {
      Offset offset = details.globalPosition;
      touchDown = new Vector3(offset.dx, offset.dy, 0.0);
    });
  }

  onPanUpdate(DragUpdateDetails details){
    if(widget.constant)
      return;
    //print("onPanUpdate");
    setState(() {
      Offset offset = details.globalPosition;
      Offset delta = details.delta;
      // touch now - touch down
      Vector3 position = new Vector3(offset.dx, offset.dy, 0.0) - touchDown;
      Vector3 speed = new Vector3(delta.dx, delta.dy, 0.0);
      calculateTransformationValues(position, speed);
    });
  }

  onPanUp(DragEndDetails details){
    if(widget.constant)
      return;
    //print("onPanUp");
    //print(details.velocity);
    if(state == CardStates.faceDown){
      if(details.velocity.pixelsPerSecond.dy > 1000)
        setCardState(CardStates.faceUp);
      else
        setCardState(CardStates.faceDown);
    }

    if(state == CardStates.flipping || state == CardStates.faceUp)
      setCardState(CardStates.faceUp);

    if(details.velocity.pixelsPerSecond.dy < -1000)
      setCardState(CardStates.gone);
  }

  onTapUp(TapUpDetails details){
    if(widget.constant)
      return;

    switch(state){
      case CardStates.faceUp:
        setCardState(CardStates.gone);
        break;
      case CardStates.faceDown:
        setCardState(CardStates.faceUp);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context){
    //print('build Card');
    updateView();

    return new GestureDetector(
      onPanDown: onPanDown,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanUp,
      onTapUp: onTapUp,
      child: new Align(
        alignment: Alignment.center,
        child: new Transform(
          transform: transformationMatrix,
          alignment: FractionalOffset.topCenter,
          child: Transform(
            transform: new Matrix4.rotationX(pi),
            alignment: FractionalOffset.center,
            child: new Image(
              image: new AssetImage('assets/' + imageFile + '.png'),
              width: size.x,
              height: size.y,
            ), 
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