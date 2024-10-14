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
  // Requesting permissions
  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  Color _currentColor = Colors.blue; // Default color
  Timer? _debounce; // Debounce timer

  // Convert a Color object to a hexadecimal string
  String _colorToHex(Color color) {
    return color.value.toRadixString(16).padLeft(8, '0').substring(2);
  }

  // Show a color picker dialog
  void _selectColor() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text('Selecciona un color'),
            content: ColorPicker(
              pickerColor: _currentColor,
              hexInputBar: true,
              labelTypes: const [ColorLabelType.rgb, ColorLabelType.hex],
              enableAlpha: false,
              // Update the current color when it changes
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
                // Send the selected color to the device
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
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "COLOR PICKER",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ),
                // Display the connection status
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: RichText(
                      text: TextSpan(
                    text: "Conexión: ",
                    style: Theme.of(context).textTheme.headlineSmall,
                    children: [
                      TextSpan(
                        text: bluetoothService.isConnected
                            ? "Estás conectado"
                            : "No estás conectado",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: bluetoothService.isConnected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                  )),
                ),
                // Display the selected color
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Color elegido:",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ),
                ),
                // Display the color preview
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      color: _currentColor,
                    ),
                  ),
                ),
                // Button to open the color picker dialog
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: ElevatedButton(
                    onPressed: _selectColor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Text(
                      "Selecciona un color nuevo",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
