import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kurir/models/delivery.dart';
import 'package:kurir/pages/delivery_points.dart';
import 'package:kurir/models/delivery_provider.dart';
import 'package:provider/provider.dart';

class _StopItem extends StatelessWidget {
  final int index;
  const _StopItem({required this.index});

  @override
  Widget build(BuildContext context) {
    var stop =
        context.select<DeliveryProvider, Stop>((p) => p.delivery.stops[index]);

    var timeWindow =
        context.select<DeliveryProvider, ({String date, String time})>(
            (p) => p.getTimeWindow(index));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.circle,
            size: 16,
            color: Colors.blueGrey,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  stop.address,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Text(
                  "Time Window ±15 min",
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  timeWindow.time,
                  style: const TextStyle(fontSize: 22),
                ),
                Text(
                  timeWindow.date,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_circle_up_rounded),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_circle_down_rounded),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class DeliveryRoutesPage extends StatefulWidget {
  const DeliveryRoutesPage({super.key});

  @override
  State<DeliveryRoutesPage> createState() => _DeliveryRoutesPageState();
}

class _DeliveryRoutesPageState extends State<DeliveryRoutesPage> {
  late final Timer _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print("berdetak");
      context
          .read<DeliveryProvider>()
          .updateTime(DateTime.timestamp().millisecondsSinceEpoch);
    });
  }

  @override
  void dispose() {
    print("dispose");
    _timer.cancel();
    super.dispose();
  }

  void _onStartClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeliveryPointsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Delivery Routes"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Delivery Number",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        context.select<DeliveryProvider, String>(
                            (p) => p.delivery.deliveryNumber),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Builder(builder: (context) {
                    var formatedDateTime = context.select<DeliveryProvider,
                        ({String date, String time})>((p) => p.getStartTime());
                    return Column(
                      children: [
                        const Text(
                          "Delivery Time",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          formatedDateTime.time,
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                          formatedDateTime.date,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: context.select<DeliveryProvider, int>(
                    (p) => p.delivery.stops.length),
                itemBuilder: (context, index) => _StopItem(
                  index: index,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _onStartClick,
              child: const Text("Start Delivery"),
            ),
          ],
        ),
      ),
    );
  }
}
