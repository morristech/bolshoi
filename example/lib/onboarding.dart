import 'dart:async';
import 'dart:collection';

import 'package:bolshoi/bolshoi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final titleStyle = new TextStyle(color: Colors.white, fontSize: 64.0);
final btStyle = new TextStyle(color: Colors.cyan[500], fontSize: 24.0);
final btStyle2 = new TextStyle(color: Colors.white, fontSize: 32.0);

class OnBoardingDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new OnBoardingDemoState();
}

class OnBoardingDemoState extends State<OnBoardingDemo>
    with TickerProviderStateMixin {
  final tWidth = 360.0;

  double tLeft = 0.0;
  double tTop = 0.0;
  double tAlpha = 0.0;
  double btBottom = -100.0;
  double btAlpha = 0.0;
  double bt2Bottom = -100.0;
  double bt2Alpha = 0.0;

  AnimationQueue animsQ;

  Queue<PropertyAnimationBase> anims = new Queue();

  Queue<PropertyAnimationBase> completedAnims = new Queue();

  PropertyAnimationBase currentAnim;
  StreamSubscription<AnimationStatus> currentAnimSub;

  bool queueComplete = false;

  void setTitleTop(double v) => setState(() => tTop = v);
  void setTitleAlpha(double a) => setState(() => tAlpha = a);
  void setBtBottom(double v) => setState(() => btBottom = v);
  void setBtAlpha(double a) => setState(() => btAlpha = a);
  void setBt2Bottom(double v) => setState(() => bt2Bottom = v);
  void setBt2Alpha(double a) => setState(() => bt2Alpha = a);

  void playAnimQueue() {
    if (!queueComplete) {
      currentAnim = anims.first;
      currentAnimSub = currentAnim.statu$.listen(onStatus);
      currentAnim.forward();
    } else {
      currentAnim = completedAnims.last;
      currentAnimSub = currentAnim.statu$.listen(onStatus);
      currentAnim.reverse();
    }
  }

  void onStatus(AnimationStatus status) {
    if (!queueComplete) {
      if (status == AnimationStatus.completed) {
        currentAnimSub.cancel();
        currentAnimSub = null;
        completedAnims.add(anims.removeFirst());
        if (anims.isNotEmpty)
          playAnimQueue();
        else {
          queueComplete = true;
        }
      }
    } else {
      if (status == AnimationStatus.dismissed) {
        currentAnimSub.cancel();
        currentAnimSub = null;
        anims.add(completedAnims.removeLast());
        if (completedAnims.isNotEmpty) {
          playAnimQueue();
        } else {
          queueComplete = false;
        }
      }
    }
  }

  @override
  void initState() {
    final List<PropertyAnimationBase> choregraphy = [
      new AnimationGroup([
        new PropertyAnimation(kDuration_ms,
            vsync: this,
            curve: Curves.fastOutSlowIn,
            tween: new Tween<double>(begin: -100.0, end: 150.0),
            animator: setTitleTop),
        new PropertyAnimation(kDuration_ms,
            vsync: this,
            curve: Curves.fastOutSlowIn,
            tween: new Tween<double>(begin: 0.0, end: 1.0),
            animator: setTitleAlpha)
      ]),
      new AnimationGroup([
        new PropertyAnimation(kDuration2_ms,
            vsync: this,
            curve: Curves.easeOut,
            tween: new Tween<double>(begin: -100.0, end: 280.0),
            animator: setBtBottom),
        new PropertyAnimation(kDuration_ms,
            vsync: this,
            curve: Curves.fastOutSlowIn,
            tween: new Tween<double>(begin: 0.0, end: 1.0),
            animator: setBtAlpha)
      ]),
      new AnimationGroup([
        new PropertyAnimation(kDuration2_ms,
            vsync: this,
            curve: Curves.easeOut,
            tween: new Tween<double>(begin: -100.0, end: 120.0),
            animator: setBt2Bottom),
        new PropertyAnimation(kDuration_ms,
            vsync: this,
            curve: Curves.fastOutSlowIn,
            tween: new Tween<double>(begin: 0.0, end: 1.0),
            animator: setBt2Alpha)
      ])
    ];
    animsQ = new AnimationQueue();
    animsQ.addAll(choregraphy);
    animsQ.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final Size size = constraints.biggest;
      tLeft = (size.width - tWidth) * .5;
      final title = new Positioned(
          left: tLeft,
          top: tTop,
          child: new SizedBox(
              width: tWidth,
              child: new Opacity(
                opacity: tAlpha,
                child: new Text('Welcome',
                    textAlign: TextAlign.center, style: titleStyle),
              )));
      final btNew = new Positioned(
          left: tLeft,
          bottom: btBottom,
          child: new Align(
              alignment: FractionalOffset.bottomCenter,
              child: new SizedBox.fromSize(
                  size: new Size(tWidth, 80.0),
                  child: new Opacity(
                      opacity: btAlpha,
                      child: new RaisedButton(
                          child: new Text('Créer un compte', style: btStyle),
                          onPressed: () => animsQ
                              .reverse() /*print('OnBoardingDemoState.build... ')*/,
                          color: Colors.white)))));
      Widget mainStack = new Stack(children: [
        title,
        btNew,
        new Positioned(
            left: tLeft,
            bottom: bt2Bottom,
            child: new SizedBox.fromSize(
                size: new Size(tWidth, 80.0),
                child: new Opacity(
                  opacity: bt2Alpha,
                  child: new FlatButton(
                      child: new Text('Se connecter', style: btStyle2),
                      textColor: Colors.white,
                      color: new Color(0x20FFFFFF),
                      onPressed: () => print('OnBoardingDemoState.build... ')),
                ))),
      ]);
      return new DecoratedBox(
          decoration: new BoxDecoration(color: Colors.cyan[800]),
          child: new SizedBox(
              width: size.width, height: size.height, child: mainStack));
    });
  }
}
