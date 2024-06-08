import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import 'bluetooth_settings_view.dart';
import '../settings/settings_view.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'dart:async';

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
  Timer? _debounce;

  String _colorToHex(Color color) {
    return color.value.toRadixString(16).padLeft(8, '0').substring(2);
  }

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

              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                final bluetoothService =
                    Provider.of<BluetoothService>(context, listen: false);
                if (bluetoothService.isConnected) {
                  bluetoothService.sendData(_colorToHex(_currentColor));
                }
              });
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
                  bluetoothService.sendData(_colorToHex(_currentColor));
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (bluetoothService.isConnected) {
                      bluetoothService.sendData("1");
                    }
                  },
                  child: const Text("Encender"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (bluetoothService.isConnected) {
                      bluetoothService.sendData("0");
                    }
                  },
                  child: const Text("Apagar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
