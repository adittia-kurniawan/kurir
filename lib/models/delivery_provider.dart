import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kurir/models/delivery.dart';

class DeliveryProvider extends ChangeNotifier {
  late Delivery _delivery;
  late List<int> _timeWindows;
  late List<int> _expectedFinishTimes;

  Delivery get delivery => _delivery;

  bool isDeliveryRunning = false;
  Timer? _timer;

  set delivery(Delivery newDelivery) {
    _delivery = newDelivery;
    _timeWindows = List.filled(_delivery.stops.length, -1);
    _expectedFinishTimes = List.filled(_delivery.stops.length, -1);
    _delivery.startTime = DateTime.timestamp().millisecondsSinceEpoch;
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isDeliveryRunning) {
        print("[TIMER] time windows");
      } else {
        print("[TIMER] deliveryTime");
        _updateDeliveryTime();
      }
    });
  }

  void stopTimer() {
    isDeliveryRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  ({String date, String time}) getStartTime() {
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(delivery.startTime).toLocal();
    return (
      date: dateTime.toString().substring(0, 10),
      time: dateTime.toString().substring(11, 19),
    );
  }

  _updateDeliveryTime() {
    _delivery.startTime = DateTime.timestamp().millisecondsSinceEpoch;
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

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
