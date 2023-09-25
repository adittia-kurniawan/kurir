import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kurir/models/delivery.dart';

typedef TimeWindowT = ({String name, String address, String date, String time});

enum DeliveryStatus { empty, reorder, running, done }

class DeliveryProvider extends ChangeNotifier {
  late Delivery _delivery;
  late List<int> _timeWindows;
  late List<int> _expectedFinishTimes;
  int _currentStopIndex = 0;
  Timer? _timer;

  int get stopCount => _delivery.stops.length;
  String get deliveryNumber => _delivery.deliveryNumber;
  DeliveryStatus deliveryStatus = DeliveryStatus.empty;

  void startReorder(Delivery newDelivery) {
    deliveryStatus = DeliveryStatus.reorder;
    _delivery = newDelivery;
    _timeWindows = List.filled(_delivery.stops.length, -1);
    _expectedFinishTimes = List.filled(_delivery.stops.length, -1);
    _updateDeliveryTime();

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (deliveryStatus == DeliveryStatus.running) {
          print("[TIMER] time windows");
        } else if (deliveryStatus == DeliveryStatus.reorder) {
          print("[TIMER] deliveryTime");
          _updateDeliveryTime();
        } else {
          print("[TIMER] berdetak");
        }
      },
    );
  }

  void reorderStops() {
    if (deliveryStatus == DeliveryStatus.done) {
      return;
    }
    deliveryStatus = DeliveryStatus.reorder;
    _currentStopIndex = 0;
  }

  void stopReorder() {
    deliveryStatus = DeliveryStatus.empty;
    _currentStopIndex = 0;
    _timer?.cancel();
    _timer = null;
  }

  void startDelivery() {
    deliveryStatus = DeliveryStatus.running;
    _currentStopIndex = 0;
    notifyListeners();
  }

  void finishCurrentStop() {
    if (_currentStopIndex == stopCount - 1) {
      return;
    }
    var now = DateTime.timestamp().millisecondsSinceEpoch;
    _delivery.stops[_currentStopIndex].stopEndTime = now;
    ++_currentStopIndex;
    _delivery.stops[_currentStopIndex].stopStartTime = now;
    notifyListeners();
  }

  void finishDelivery() {
    deliveryStatus = DeliveryStatus.done;
    _currentStopIndex = 0;
    _timer?.cancel();
    _timer = null;
    var now = DateTime.timestamp().millisecondsSinceEpoch;
    _delivery.stops[stopCount - 1].stopEndTime = now;
    notifyListeners();
  }

  ({String date, String time}) getStartTime() {
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(_delivery.startTime).toLocal();
    return (
      date: dateTime.toString().substring(0, 10),
      time: dateTime.toString().substring(11, 19),
    );
  }

  TimeWindowT getTimeWindow(int index) {
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(_timeWindows[index]).toLocal();
    var stop = _delivery.stops[index];

    return (
      name: stop.name,
      address: stop.address,
      date: dateTime.toString().substring(0, 10),
      time: dateTime.toString().substring(11, 19),
    );
  }

  TimeWindowT getStopFinishTime(int index) {
    var stop = _delivery.stops[index];
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(stop.stopEndTime).toLocal();

    return (
      name: stop.name,
      address: stop.address,
      date: dateTime.toString().substring(0, 10),
      time: dateTime.toString().substring(11, 19),
    );
  }

  ({TimeWindowT current, TimeWindowT? next}) getCurrentStopTimeWindow() {
    TimeWindowT current = getTimeWindow(_currentStopIndex);
    TimeWindowT? next;
    var nextStopIndex = _currentStopIndex + 1;
    if (nextStopIndex < _timeWindows.length) {
      next = getTimeWindow(nextStopIndex);
    }
    return (current: current, next: next);
  }

  _updateDeliveryTime() {
    _delivery.startTime = DateTime.timestamp().millisecondsSinceEpoch;
    var startingTime =
        _delivery.startTime + const Duration(minutes: 5).inMilliseconds;
    var prevStopName = "base";
    if (_delivery.startTime < _delivery.plannedStartTime) {
      startingTime = _delivery.plannedStartTime;
    }
    for (int i = 0; i < _timeWindows.length; i++) {
      var stop = _delivery.stops[i];
      var drivingTime =
          _delivery.matrix["$prevStopName-${stop.name}"]!.duration;

      var eta = startingTime + Duration(minutes: drivingTime).inMilliseconds;
      var roundedEta = eta;
      //var roundedEta = (eta / 300000).ceil() * 300000;
      _timeWindows[i] = roundedEta;
      var expectedFinishTime =
          eta + Duration(minutes: stop.unloadingTime).inMilliseconds;

      _expectedFinishTimes[i] = expectedFinishTime;
      startingTime = expectedFinishTime;
      prevStopName = stop.name;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
