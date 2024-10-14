import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService extends ChangeNotifier {
  // Instance of FlutterBluetoothSerial
  final _flutterBluetooth = FlutterBluetoothSerial.instance;

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN; // Bluetooth state
  BluetoothConnection? _bluetoothConnection; // Bluetooth connection
  bool _isConnected = false; // Is connected to a device
  bool _isConnecting = false; // Is connecting to a device
  List<BluetoothDevice> _devicesList = []; // List of paired devices
  BluetoothDevice? _connectedDevice; // Connected device

  // Constructor
  BluetoothService() {
    // Get the current Bluetooth state
    _flutterBluetooth.state.then((value) {
      _bluetoothState = value;
      notifyListeners();
    });

    // Listen to Bluetooth state changes
    _flutterBluetooth.onStateChanged().listen((BluetoothState state) {
      _bluetoothState = state;
      notifyListeners();
    });
  }

  // Getters
  BluetoothState get bluetoothState => _bluetoothState;
  bool get isConnected => _isConnected;
  List<BluetoothDevice> get devicesList => _devicesList;
  bool get isBluetoothAvailable => _bluetoothState == BluetoothState.STATE_ON;
  bool get isConnecting => _isConnecting;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Methods
  // Discover devices
  Future<void> discoverDevices() async {
    try {
      List<BluetoothDevice> devices =
          await _flutterBluetooth.getBondedDevices();
      _devicesList = devices;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Connect to a device
  Future<void> connect(BluetoothDevice device) async {
    _isConnecting = true;
    notifyListeners();
    try {
      await BluetoothConnection.toAddress(device.address).then((value) {
        _bluetoothConnection = value;
        _isConnected = true;
        _connectedDevice = device;
        notifyListeners();
        _handleIncomingData();
      });
    } catch (e) {
      rethrow;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  // Disconnect from a device
  Future<void> disconnect() async {
    try {
      await _bluetoothConnection?.close();
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Send data to the connected device
  void sendData(String data) {
    if (_bluetoothConnection != null) {
      _bluetoothConnection!.output
          .add(Uint8List.fromList(utf8.encode("$data\r\n")));
    }
  }

  // Handle incoming data
  void _handleIncomingData() {
    _bluetoothConnection!.input!.listen((data) {
      // ignore: unused_local_variable
      String receivedData = String.fromCharCodes(data).trim();
    }).onDone(() {
      _isConnected = false;
      notifyListeners();
    });
  }

  // Enable Bluetooth
  Future<void> enableBluetooth() async {
    try {
      await _flutterBluetooth.requestEnable();
    } catch (e) {
      rethrow;
    }
  }
}
