import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import 'bluetooth_settings_view.dart';
import '../settings/settings_view.dart';

import 'package:permission_handler/permission_handler.dart';

class DataView extends StatefulWidget {
  const DataView({super.key});

  static const routeName = '/';

  @override
  State<DataView> createState() => _DataViewState();
}

class _DataViewState extends State<DataView> {
  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              Navigator.restorablePushNamed(
                  context, BluetoothSettingsView.routeName);
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(bluetoothService.isConnected
                ? "Estás conectado"
                : "No estás conectado"),
            const Text('Data View'),
          ],
        ),
      ),
    );
  }
}
