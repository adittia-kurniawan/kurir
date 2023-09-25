import 'package:flutter/material.dart';
import 'package:kurir/pages/delivery_points.dart';
import 'package:kurir/models/delivery_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StopItem extends StatelessWidget {
  final int index;
  final bool isDone;
  const _StopItem({required this.index, required this.isDone});

  @override
  Widget build(BuildContext context) {
    var time = isDone
        ? context.select<DeliveryProvider, TimeWindowT>(
            (p) => p.getStopFinishTime(index))
        : context.select<DeliveryProvider, TimeWindowT>(
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
                  time.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  time.address,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  isDone ? "Stop Finish Time" : "Time Window ±15 min",
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  time.time,
                  style: const TextStyle(fontSize: 22),
                ),
                Text(
                  time.date,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          isDone
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context
                            .read<DeliveryProvider>()
                            .moveStop(index, index - 1);
                      },
                      icon: const Icon(Icons.arrow_circle_up_rounded),
                    ),
                    IconButton(
                      onPressed: () {
                        context
                            .read<DeliveryProvider>()
                            .moveStop(index, index + 1);
                      },
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
  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    print("deactivate");
    context.read<DeliveryProvider>().stopReorder();
    super.deactivate();
  }

  void _onStartClick() {
    context.read<DeliveryProvider>().startDelivery();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeliveryPointsPage(),
      ),
    );
  }

  void _onSubmitOrderClick() {
    context.read<DeliveryProvider>().stopReorder();
    Navigator.pop(context);
  }

  Future<void> _onSaveOrderClick() async {
    var orders = context.read<DeliveryProvider>().orders;
    var deliveryNumber = context.read<DeliveryProvider>().deliveryNumber;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("Orders-$deliveryNumber", orders);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Order Saved"),
      duration: Duration(seconds: 1),
    ));
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
        child: Builder(builder: (context) {
          var isDone = context.select<DeliveryProvider, bool>(
              (p) => p.deliveryStatus == DeliveryStatus.done);
          return Column(
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
                              (p) => p.deliveryNumber),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Builder(builder: (context) {
                      var formatedDateTime = context.select<
                          DeliveryProvider,
                          ({
                            String date,
                            String time
                          })>((p) => p.getStartTime());
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
                  itemCount:
                      context.select<DeliveryProvider, int>((p) => p.stopCount),
                  itemBuilder: (context, index) => _StopItem(
                    index: index,
                    isDone: isDone,
                  ),
                ),
              ),
              isDone
                  ? const SizedBox.shrink()
                  : ElevatedButton(
                      onPressed: _onSaveOrderClick,
                      child: const Text("Save Order"),
                    ),
              ElevatedButton(
                onPressed: isDone ? _onSubmitOrderClick : _onStartClick,
                child: Text(isDone ? "Submit Stop order" : "Start Delivery"),
              ),
            ],
          );
        }),
      ),
    );
  }
}
