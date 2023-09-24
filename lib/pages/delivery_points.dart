import 'package:flutter/material.dart';

class DeliveryPointsPage extends StatefulWidget {
  const DeliveryPointsPage({super.key});

  @override
  State<DeliveryPointsPage> createState() => _DeliveryPointsPageState();
}

class _DeliveryPointsPageState extends State<DeliveryPointsPage> {
  void _onReorderClick() {
    Navigator.pop(context);
  }

  void _onFinishClick() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Delivery Point"),
      ),
      body: Column(
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
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "stop_1",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    "Gondangdia",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "00:00:00",
                    style: TextStyle(
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    "2023-09-23",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "stop_2",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "Cikini",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "00:00:00",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Text(
                  "2023-09-23",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Finish Current Stop"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
            child: ElevatedButton(
              onPressed: _onReorderClick,
              child: const Text("Reorder Stops"),
            ),
          ),
        ],
      ),
    );
  }
}
