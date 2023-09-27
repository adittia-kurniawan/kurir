class Stop {
  int number;
  String name;
  String address;
  int stopIndex;
  int stopStartTime;
  int stopEndTime;
  int unloadingTime;

  Stop(
      {required this.number,
      required this.name,
      required this.address,
      required this.stopIndex,
      required this.stopStartTime,
      required this.stopEndTime,
      required this.unloadingTime});
}

class Connection {
  int duration;
  int length;

  Connection({required this.duration, required this.length});
}

class Delivery {
  String deliveryNumber;
  int startTime = 0;
  int finishTime = 0;
  int plannedStartTime;
  late List<Stop> stops;
  late Map<String, Connection> matrix;

  /*
  Delivery(DeliveryT d)
      : deliveryNumber = d.deliveryNumber,
        plannedStartTime = d.plannedStartTime {
    stops = d.stops
        .map(
          (e) => Stop(
              number: e.number,
              name: e.name,
              address: e.address,
              stopIndex: e.stopIndex,
              stopStartTime: e.stopStartTime,
              stopEndTime: e.stopEndTime,
              unloadingTime: e.unloadingTime),
        )
        .toList();
    stops.sort((a, b) => a.stopIndex.compareTo(b.stopIndex));
    matrix = d.matrix.map((key, value) => MapEntry(
        key, Connection(duration: value.duration, length: value.length)));
  }
  */

  Delivery(
      {required this.deliveryNumber,
      required this.startTime,
      required this.finishTime,
      required this.plannedStartTime,
      required this.stops,
      required this.matrix});

  factory Delivery.fromJson(Map<String, dynamic> json) {
    String deliveryNumber = json["deliveryNumber"];
    int startTime = json["startTime"];
    int finishTime = json["finishTime"];
    int plannedStartTime = json["plannedStartTime"];
    List<dynamic> stopsTemp = (json["stops"] as List<dynamic>);
    stopsTemp.sort(
      (a, b) => (a["stopIndex"] as int).compareTo(b["stopIndex"] as int),
    );

    List<Stop> stops = stopsTemp
        .map(
          (e) => Stop(
            number: e["number"],
            name: e["name"],
            address: e["address"],
            stopIndex: e["stopIndex"],
            stopStartTime: e["stopStartTime"],
            stopEndTime: e["stopEndTime"],
            unloadingTime: e["unloadingTime"],
          ),
        )
        .toList();

    Map<String, Connection> matrix =
        (json["matrix"] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        Connection(duration: value["duration"], length: value["length"]),
      ),
    );
    return Delivery(
      deliveryNumber: deliveryNumber,
      startTime: startTime,
      finishTime: finishTime,
      plannedStartTime: plannedStartTime,
      stops: stops,
      matrix: matrix,
    );
  }
}
