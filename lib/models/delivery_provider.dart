import 'package:flutter/material.dart';
import 'package:kurir/models/delivery.dart';

class DeliveryProvider extends ChangeNotifier {
  late Delivery _delivery;
  int _now = -1;
  late List<int> _timeWindows;
  late List<int> _expectedFinishTimes;

  Delivery get delivery => _delivery;

  set delivery(Delivery newDelivery) {
    _delivery = newDelivery;
    _timeWindows = List.filled(_delivery.stops.length, -1);
    _expectedFinishTimes = List.filled(_delivery.stops.length, -1);
    _now = -1;
    notifyListeners();
  }

  ({String date, String time}) getNow() {
    if (_now < 0) {
      return (date: "yy:MM:dd", time: "HH:mm:ss");
    }
    var dateTime = DateTime.fromMillisecondsSinceEpoch(_now).toLocal();
    return (
      date: dateTime.toString().substring(0, 10),
      time: dateTime.toString().substring(11, 19),
    );
  }

  updateTime(int newNow) {
    _now = newNow;
    var startingTime = _now + const Duration(minutes: 5).inMilliseconds;
    var prevStopName = "base";
    if (_now < _delivery.plannedStartTime) {
      startingTime = delivery.plannedStartTime;
    }
    for (int i = 0; i < _timeWindows.length; i++) {
      var stop = delivery.stops[i];
      var drivingTime = delivery.matrix["$prevStopName-${stop.name}"]!.duration;

      var eta = startingTime + Duration(minutes: drivingTime).inMilliseconds;
      var roundedEta = eta + const Duration(minutes: 5).inMilliseconds;
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
    if (_now < 0 || index >= _timeWindows.length) {
      return (date: "yy:MM:dd", time: "HH:mm:ss");
    }
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(_timeWindows[index]).toLocal();
    return (
      date: dateTime.toString().substring(0, 10),
      time: dateTime.toString().substring(11, 19),
    );
  }
}
