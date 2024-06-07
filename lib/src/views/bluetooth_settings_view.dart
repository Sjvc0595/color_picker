import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class BluetoothSettingsView extends StatefulWidget {
  const BluetoothSettingsView({super.key});

  static const routeName = '/bluetooth_settings_view';

  @override
  State<BluetoothSettingsView> createState() => _BluetoothSettingsViewState();
}

class _BluetoothSettingsViewState extends State<BluetoothSettingsView> {
  final List<Permission> permissions = [
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
  ];

  @override
  void initState() {
    _requestPermissions();
    super.initState();
  }

  bool _isEverythingGranted = false;

  void _requestPermissions() async {
    // Requesting permissions
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    // Checking permissions status
    var locationStatus = await Permission.location.status;
    var bluetoothStatus = await Permission.bluetooth.status;
    var bluetoothScanStatus = await Permission.bluetoothScan.status;
    var bluetoothConnectStatus = await Permission.bluetoothConnect.status;

    // Checking if all permissions are granted
    if (locationStatus == PermissionStatus.granted &&
        bluetoothStatus == PermissionStatus.granted &&
        bluetoothScanStatus == PermissionStatus.granted &&
        bluetoothConnectStatus == PermissionStatus.granted) {
      setState(() {
        _isEverythingGranted = true;
      });
    } else {
      setState(() {
        _isEverythingGranted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Settings'),
      ),
      body: _isEverythingGranted
          ? !bluetoothService.isBluetoothAvailable
              ? _BluetoothOff(bluetoothService: bluetoothService)
              : _DevicesList(bluetoothService: bluetoothService)
          : const _NoPermissions(),
    );
  }
}

class _NoPermissions extends StatelessWidget {
  const _NoPermissions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No se han concedido todos los permisos'),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text('Abrir ajustes de la aplicación'),
          ),
        ],
      ),
    );
  }
}

class _DevicesList extends StatelessWidget {
  const _DevicesList({
    required this.bluetoothService,
  });

  final BluetoothService bluetoothService;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await bluetoothService.discoverDevices();
            },
            child: ListView.builder(
              itemCount: bluetoothService.devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      bluetoothService.devicesList[index].name ?? "Unknown"),
                  subtitle: Text(bluetoothService.devicesList[index].address),
                  onTap: () async {
                    try {
                      await bluetoothService
                          .connect(bluetoothService.devicesList[index]);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ),
        const Text(
            "Si no ves ningún dispositivo, comprueba los dispositivos enlazados en ajustes"),
      ],
    );
  }
}

class _BluetoothOff extends StatelessWidget {
  const _BluetoothOff({
    required this.bluetoothService,
  });

  final BluetoothService bluetoothService;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text('El Bluetooth no está encendido'),
          const Icon(Icons.bluetooth_disabled),
          ElevatedButton(
            onPressed: () async {
              await bluetoothService.enableBluetooth();
            },
            child: const Text("Encender Bluetooth"),
          )
        ],
      ),
    );
  }
}
