import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService extends ChangeNotifier {
  // Instance of FlutterBluetoothSerial
  final _flutterBluetooth = FlutterBluetoothSerial.instance;

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? _bluetoothConnection;
  bool _isConnected = false;
  bool _isConnecting = false;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _connectedDevice;

  BluetoothService() {
    _flutterBluetooth.state.then((value) {
      _bluetoothState = value;
      notifyListeners();
    });

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

  Future<void> disconnect() async {
    try {
      await _bluetoothConnection?.close();
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void sendData(String data) {
    if (_bluetoothConnection != null) {
      _bluetoothConnection!.output
          .add(Uint8List.fromList(utf8.encode("$data\r\n")));
    }
  }

  void _handleIncomingData() {
    _bluetoothConnection!.input!.listen((data) {
      // ignore: unused_local_variable
      String receivedData = String.fromCharCodes(data).trim();
    }).onDone(() {
      _isConnected = false;
      notifyListeners();
    });
  }

  Future<void> enableBluetooth() async {
    try {
      await _flutterBluetooth.requestEnable();
    } catch (e) {
      rethrow;
    }
  }
}
