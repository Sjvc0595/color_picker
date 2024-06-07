import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import 'bluetooth_settings_view.dart';
import '../settings/settings_view.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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

  Color _currentColor = Colors.blue;

  void _selectColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona un color'),
          content: ColorPicker(
            pickerColor: _currentColor,
            hexInputBar: true,
            labelTypes: const [ColorLabelType.rgb, ColorLabelType.hex],
            enableAlpha: false,
            onColorChanged: (color) {
              setState(() {
                _currentColor = color;
              });
              final bluetoothService =
                  Provider.of<BluetoothService>(context, listen: false);
              if (bluetoothService.isConnected) {
                bluetoothService
                    .sendData(color.value.toRadixString(16).padLeft(8, '0'));
              }
            },
            pickerAreaHeightPercent: 0.8,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final bluetoothService =
                    Provider.of<BluetoothService>(context, listen: false);
                if (bluetoothService.isConnected) {
                  bluetoothService.sendData(
                      _currentColor.value.toRadixString(16).padLeft(8, '0'));
                }
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
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
            const Text("Color elegido:"),
            SizedBox(
              width: 300,
              height: 300,
              child: Container(
                color: _currentColor,
              ),
            ),
            ElevatedButton(
              onPressed: _selectColor,
              child: const Text("Selecciona un color nuevo"),
            )
          ],
        ),
      ),
    );
  }
}
