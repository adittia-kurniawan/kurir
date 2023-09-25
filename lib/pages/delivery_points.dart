import 'package:flutter/material.dart';
import 'package:kurir/models/delivery_provider.dart';
import 'package:provider/provider.dart';

class DeliveryPointsPage extends StatefulWidget {
  const DeliveryPointsPage({super.key});

  @override
  State<DeliveryPointsPage> createState() => _DeliveryPointsPageState();
}

class _DeliveryPointsPageState extends State<DeliveryPointsPage> {
  void _onReorderClick() {
    Navigator.pop(context);
  }

  void _onFinishCurrentStopClick() {
    context.read<DeliveryProvider>().finishCurrentStop();
  }

  void _onFinishDeliveryClick() {
    context.read<DeliveryProvider>().finishDelivery();
    Navigator.pop(context);
  }

  @override
  void deactivate() {
    context.read<DeliveryProvider>().reorderStops();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Delivery Point"),
      ),
      body: Builder(builder: (context) {
        var timeWindow = context.select<
            DeliveryProvider,
            ({
              TimeWindowT current,
              TimeWindowT? next
            })>((p) => p.getCurrentStopTimeWindow());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timeWindow.current.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    Text(
                      timeWindow.current.address,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Time Window ±15 min",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      timeWindow.current.time,
                      style: const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    Text(
                      timeWindow.current.date,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: timeWindow.next == null
                  ? const SizedBox()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timeWindow.next!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          timeWindow.next!.address,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Time Window ±15 min",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          timeWindow.next!.time,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          timeWindow.next!.date,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: timeWindow.next == null
                    ? _onFinishDeliveryClick
                    : _onFinishCurrentStopClick,
                child: Text(timeWindow.next == null
                    ? "Finish Delivery"
                    : "Finish Current Stop"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
              child: timeWindow.next == null
                  ? null
                  : ElevatedButton(
                      onPressed: _onReorderClick,
                      child: const Text("Reorder Stops"),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
