import 'package:flutter/material.dart';
import 'package:kurir/pages/delivery_points.dart';
import 'package:kurir/models/delivery_provider.dart';
import 'package:provider/provider.dart';

class _StopItem extends StatelessWidget {
  final int index;
  final DeliveryStatus deliveryStatus;
  const _StopItem(
      {super.key, required this.index, required this.deliveryStatus});

  @override
  Widget build(BuildContext context) {
    var time = deliveryStatus == DeliveryStatus.done
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
                  deliveryStatus == DeliveryStatus.done
                      ? "Stop Finish Time"
                      : "Time Window ±15 min",
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
          deliveryStatus == DeliveryStatus.reorder
              ? Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context
                            .read<DeliveryProvider>()
                            .moveStopPosition(index, index - 1);
                      },
                      icon: const Icon(Icons.arrow_circle_up_rounded),
                    ),
                    IconButton(
                      onPressed: () {
                        context
                            .read<DeliveryProvider>()
                            .moveStopPosition(index, index + 1);
                      },
                      icon: const Icon(Icons.arrow_circle_down_rounded),
                    )
                  ],
                )
              : const SizedBox.shrink(),
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
    //var deliveryStatus =
    //    Provider.of<DeliveryProvider>(context, listen: false).deliveryStatus;
    //print("pindah gak $deliveryStatus");
    //if (deliveryStatus == DeliveryStatus.running) {
    //  Navigator.push(
    //    context,
    //    MaterialPageRoute(
    //      builder: (context) => const DeliveryPointsPage(),
    //    ),
    //  );
    //}
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

  void _onContinueClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeliveryPointsPage(),
      ),
    );
  }

  void _onSubmitStopOrderClick() {
    context.read<DeliveryProvider>().finishDeliverySubmitStopOrder();
    Navigator.pop(context);
  }

  Future<void> _onSaveOrderClick() async {
    context.read<DeliveryProvider>().saveOrders();
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
          var deliveryStatus = context.select<DeliveryProvider, DeliveryStatus>(
              (p) => p.deliveryStatus);
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
                child: deliveryStatus == DeliveryStatus.reorder
                    ? ReorderableListView.builder(
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) {
                            newIndex = newIndex - 1;
                          }
                          context
                              .read<DeliveryProvider>()
                              .moveStopPosition(oldIndex, newIndex);
                        },
                        shrinkWrap: true,
                        itemCount: context
                            .select<DeliveryProvider, int>((p) => p.stopCount),
                        itemBuilder: (context, index) => _StopItem(
                          key: Key("$index"),
                          index: index,
                          deliveryStatus: deliveryStatus,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: context
                            .select<DeliveryProvider, int>((p) => p.stopCount),
                        itemBuilder: (context, index) => _StopItem(
                          key: Key("$index"),
                          index: index,
                          deliveryStatus: deliveryStatus,
                        ),
                      ),
              ),
              deliveryStatus == DeliveryStatus.reorder
                  ? ElevatedButton(
                      onPressed: _onSaveOrderClick,
                      child: const Text("Save Order"),
                    )
                  : const SizedBox.shrink(),
              ElevatedButton(
                onPressed: switch (deliveryStatus) {
                  DeliveryStatus.done => _onSubmitStopOrderClick,
                  DeliveryStatus.reorder => _onStartClick,
                  _ => _onContinueClick,
                },
                child: Text(
                  switch (deliveryStatus) {
                    DeliveryStatus.done => "Submit Stop Order",
                    DeliveryStatus.reorder => "Start Delivery",
                    _ => "Continue Delivery",
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
