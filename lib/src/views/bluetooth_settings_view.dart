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
        title: const Text(
          'Bluetooth Settings',
          style: TextStyle(fontSize: 36),
        ),
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
          // Padding(
          //   padding: const EdgeInsets.all(10),
          //   child: Text('El Bluetooth no está encendido',
          //       style: Theme.of(context).textTheme.bodyMedium),
          // ),
          // Padding(
          //         padding: const EdgeInsets.all(20),
          //         child: ElevatedButton(
          //           style: ElevatedButton.styleFrom(
          //             minimumSize: const Size(333, 0),
          //             padding: const EdgeInsets.symmetric(vertical: 8),
          //             backgroundColor: Theme.of(context).colorScheme.error,
          //           ),
          //           onPressed: () async {
          //             await bluetoothService.disconnect();
          //           },
          //           child: Text(
          //             "Desconectar",
          //             style: TextStyle(
          //               color: Theme.of(context).colorScheme.onError,
          //             ),
          //           ),
          //         ),
          //       ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'No se han concedido todos los permisos',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(333, 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                openAppSettings();
              },
              child: const Text('Abrir ajustes de la aplicación'),
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          if (bluetoothService.isConnecting) const LinearProgressIndicator(),
          if (bluetoothService.isConnected)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      text: "Conectado a: ",
                      style: Theme.of(context).textTheme.headlineSmall,
                      children: [
                        TextSpan(
                          text: bluetoothService.connectedDevice?.name ??
                              bluetoothService.connectedDevice?.address,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(333, 0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      await bluetoothService.disconnect();
                    },
                    child: Text(
                      "Desconectar",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (!bluetoothService.isConnected)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await bluetoothService.discoverDevices();
                },
                child: ListView.builder(
                  itemCount: bluetoothService.devicesList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(bluetoothService.devicesList[index].name ??
                          "Unknown"),
                      subtitle:
                          Text(bluetoothService.devicesList[index].address),
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
          Text(
            "Si no ves ningún dispositivo, comprueba los dispositivos enlazados en ajustes",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.bluetooth_disabled,
              size: 165,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('El Bluetooth no está encendido',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(333, 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                await bluetoothService.enableBluetooth();
              },
              child: const Text("Encender Bluetooth"),
            ),
          )
        ],
      ),
    );
  }
}
