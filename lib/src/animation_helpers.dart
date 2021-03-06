import 'dart:async';
import 'dart:collection';

import 'package:bolshoi/bolshoi.dart';
import 'package:bolshoi/src/property_animation.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

const kDuration = const Duration(milliseconds: 500);
const kDuration_ms = 500;
const kDuration2 = const Duration(milliseconds: 360);
const kDuration2_ms = 360;

/// opacity animation helper
class Fade extends Animate<double> implements IAnimation {
  Fade(int milliseconds,
      {@required OnTick<double> onTick,
      @required TickerProvider ticker,
      Curve curve = Curves.easeIn,
      bool out: false})
      : super(
          milliseconds,
          curve: curve,
          onTick: onTick,
          begin: out ? 1.0 : 0.0,
          end: out ? 0.0 : 1.0,
          ticker: ticker,
        );
}

///
class Zoom extends Animate<double> implements IAnimation {
  Zoom(int milliseconds,
      {OnTick animator, TickerProvider vsync, bool out: false})
      : super(
          milliseconds,
          curve: Curves.easeIn,
          onTick: animator,
          begin: out ? 1.0 : 0.0,
          end: out ? 0.0 : 1.0,
          ticker: vsync,
        );
}

/// Deprecated animation queue => vf. cf [AnimationSequence]
///
/// future : base on bi-directionnal queue ?
/// [BidirectionalIterator] [cf. doc](https://api.dartlang.org/stable/1.22.1/dart-core/BidirectionalIterator-class.html)
///
@deprecated
class AnimationQueue extends ListQueue<PropertyAnimationBase> {
  AnimationStatus currentStatus = AnimationStatus.dismissed;

  List<PropertyAnimationBase> _completedQueue;

  StreamController<AnimationStatus> _statu$Control =
      new StreamController<AnimationStatus>.broadcast();

  Stream<AnimationStatus> _statu$;

  Stream<AnimationStatus> get statu$ => _statu$;

  Iterator _iteratorRef;

  AnimationQueue() {
    _statu$ = _statu$Control.stream;
    _completedQueue = new List<PropertyAnimationBase>();
  }

  /// create an animation queue from a list of PropertyAnimationBase
  factory AnimationQueue.from(Iterable<PropertyAnimationBase> elements) {
    return new AnimationQueue()..addAll(elements);
  }

  /// create an iterator reference if none
  void _initIterator() {
    if (_iteratorRef == null) {
      _iteratorRef = iterator;
      _iteratorRef.moveNext();
      _completedQueue = map((a) => a).toList();
    }
  }

  /// start the animation chain
  void forward() {
    if (isNotEmpty) {
      // init iteratorRef
      _initIterator();
      _iteratorRef.current.statu$
          .where(
              (AnimationStatus status) => status == AnimationStatus.completed)
          .listen((AnimationStatus status) {
        if (_iteratorRef.moveNext())
          forward();
        else {
          currentStatus = AnimationStatus.completed;
          _statu$Control.add(status);
        }
      });
      _iteratorRef.current.forward();
      currentStatus = AnimationStatus.forward;
    }
  }

  /// reverse all animations
  void reverse() {
    if (_completedQueue.length > 0) {
      final current = _completedQueue.last
        ..statu$.listen((status) {
          if (status == AnimationStatus.dismissed) {
            _completedQueue.removeLast();
            if (_completedQueue.isNotEmpty)
              reverse();
            else {
              currentStatus = AnimationStatus.dismissed;
              _statu$Control.add(status);
            }
          } else {
            currentStatus = AnimationStatus.reverse;
          }
        });
      current.reverse();
    }
  }
}
