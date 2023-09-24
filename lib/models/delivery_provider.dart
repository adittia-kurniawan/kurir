import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kurir/models/delivery.dart';

class DeliveryProvider extends ChangeNotifier {
  late Delivery _delivery;
  late List<int> _timeWindows;
  late List<int> _expectedFinishTimes;

  Delivery get delivery => _delivery;

  set delivery(Delivery newDelivery) {
    _delivery = newDelivery;
    _timeWindows = List.filled(_delivery.stops.length, -1);
    _expectedFinishTimes = List.filled(_delivery.stops.length, -1);
    _delivery.startTime = DateTime.timestamp().millisecondsSinceEpoch;
    notifyListeners();
  }

  ({String date, String time}) getStartTime() {
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(delivery.startTime).toLocal();
    return (
      date: dateTime.toString().substring(0, 10),
      time: dateTime.toString().substring(11, 19),
    );
  }

  updateTime(int newNow) {
    _delivery.startTime = newNow;
    var startingTime =
        _delivery.startTime + const Duration(minutes: 5).inMilliseconds;
    var prevStopName = "base";
    if (_delivery.startTime < _delivery.plannedStartTime) {
      startingTime = delivery.plannedStartTime;
    }
    for (int i = 0; i < _timeWindows.length; i++) {
      var stop = delivery.stops[i];
      var drivingTime = delivery.matrix["$prevStopName-${stop.name}"]!.duration;

      var eta = startingTime + Duration(minutes: drivingTime).inMilliseconds;
      var roundedEta = (eta / 300000).ceil() * 300000;
      _timeWindows[i] = roundedEta;
      var expectedFinishTime =
          eta + Duration(minutes: stop.unloadingTime).inMilliseconds;

      _expectedFinishTimes[i] = expectedFinishTime;
      startingTime = expectedFinishTime;
      prevStopName = stop.name;
    }
    notifyListeners();
  }

  ({String date, String time}) getTimeWindow(int index) {
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(_timeWindows[index]).toLocal();

    return (
      date: dateTime.toString().substring(0, 10),
      time: dateTime.toString().substring(11, 19),
    );
  }
}
