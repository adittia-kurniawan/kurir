import 'package:flutter/material.dart';
import 'package:kurir/data/api_services.dart' as api;
import 'package:kurir/pages/delivery_routes.dart';
import 'package:kurir/models/delivery_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final numberController = TextEditingController();
  String? _numberError;
  var _isLoading = false;

  Future<void> _onSubmitClick() async {
    setState(() {
      _isLoading = true;
    });
    var delivery = await api.getDelivery(numberController.text);
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
    if (!context.mounted) {
      return;
    }
    context.read<DeliveryProvider>().startReorder(delivery);
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
            ElevatedButton(
              onPressed: _onSubmitClick,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
