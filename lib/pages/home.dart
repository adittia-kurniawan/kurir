import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kurir/data/api_services.dart' as api;
import 'package:kurir/pages/delivery_routes.dart';
import 'package:kurir/models/delivery_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final numberController = TextEditingController();
  String? _numberError;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOldDelivery();
    });
  }

  void _continueDelivery() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeliveryRoutesPage(),
      ),
    );
  }

  Future<void> _checkOldDelivery() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(path.join(dir.path, "current_data.json"));
      final jsonData = await file.readAsString();
      final currentData = json.decode(jsonData);
      var delivery = await api.getDelivery(currentData["deliveryNumber"]);
      if (delivery == null) {
        return;
      }
      int stopIndex = currentData["currentStopIndex"];
      final expectedFinishTime =
          List<int>.from(currentData["expectedFinishTime"]);
      final timeWindows = List<int>.from(currentData["timeWindows"]);
      delivery.startTime = currentData["startTime"];
      delivery.finishTime = currentData["finishTime"];
      final stopsTemp = List<Map<String, dynamic>>.from(currentData["stops"]);
      var stops = stopsTemp.map(
        (s) {
          String name = s["name"];
          var stop = delivery.stops.firstWhere((s) => s.name == name);
          stop.stopStartTime = s["stopStartTime"];
          stop.stopEndTime = s["stopEndTime"];
          return stop;
        },
      ).toList();
      delivery.stops = stops;
      if (!context.mounted) {
        return;
      }
      context.read<DeliveryProvider>().continueDelivery(
            delivery,
            stopIndex,
            expectedFinishTime,
            timeWindows,
          );
    } catch (e) {
      /**/
    }
  }

  Future<void> _onSubmitClick() async {
    setState(() {
      _isLoading = true;
    });

    var delivery = await api.getDelivery(numberController.text);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (delivery == null) {
      setState(() {
        _numberError = "Delivery is not Found!";
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _numberError = null;
      _isLoading = false;
    });

    var orders = prefs.getStringList("Orders-${delivery.deliveryNumber}");

    if (orders != null) {
      var stops = orders
          .map(
            (name) => delivery.stops.firstWhere((stop) => stop.name == name),
          )
          .toList();
      delivery.stops = stops;
    }
    if (!context.mounted) {
      return;
    }
    context.read<DeliveryProvider>().setNewDelivery(delivery);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeliveryRoutesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Delivery Number"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(),
            TextField(
              controller: numberController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.blueAccent,
                        ),
                      )
                    : null,
                border: const OutlineInputBorder(),
                hintText: "Enter Delivery Number",
                errorText: _numberError,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                context.select<DeliveryProvider, bool>(
                        (p) => p.deliveryStatus != DeliveryStatus.empty)
                    ? ElevatedButton(
                        onPressed: _continueDelivery,
                        child: const Text("Continue Delivery"),
                      )
                    : const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _onSubmitClick,
                  child: const Text("Submit New Delivery"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
