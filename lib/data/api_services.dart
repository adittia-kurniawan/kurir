import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:kurir/models/delivery.dart';

Future<Delivery?> getDelivery(String deliveryNumber) async {
  final data = await rootBundle.loadString("lib/data/data.json");
  final dataJson = await json.decode(data);
  await Future.delayed(const Duration(milliseconds: 500));
  for (final d in dataJson) {
    if (deliveryNumber == d["deliveryNumber"]) {
      return Delivery.fromJson(d);
    }
  }
  return null;
}
