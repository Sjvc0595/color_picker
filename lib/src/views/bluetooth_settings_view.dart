import 'package:flutter/material.dart';

class BluetoothSettingsView extends StatelessWidget {
  const BluetoothSettingsView({super.key});

  static const routeName = '/bluetooth_settings_view';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Settings'),
      ),
      body: ListView.builder(
          restorationId: 'bluetoothSettingsView',
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Item $index'),
              onTap: () {},
            );
          }),
    );
  }
}
