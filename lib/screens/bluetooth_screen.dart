import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:janzer/bluetooth/background_collecting_task.dart';
import 'package:janzer/bluetooth/chat_page.dart';
import 'package:janzer/bluetooth/discovery_page.dart';
import 'package:janzer/bluetooth/select_bonded_device_page.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() { _bluetoothState = state; });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() { _address = address; });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() { _name = name; });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            SwitchListTile(
              title: const Text('Включить Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async { // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }
                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: const Text('Состояние Bluetooth'),
              subtitle: Text(_bluetoothState.toString()),
              trailing: RaisedButton(
                child: const Text('Настройки'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            ListTile(
              title: const Text('Локальный адрес телефона'),
              subtitle: Text(_address),
            ),
            ListTile(
              title: const Text('Локальное имя телефона'),
              subtitle: Text(_name),
              onLongPress: null,
            ),
            ListTile(
                title: _discoverableTimeoutSecondsLeft == 0 ? const Text("Видимость") : Text("Видимость на $_discoverableTimeoutSecondsLeft сек"),
                trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _discoverableTimeoutSecondsLeft != 0,
                        onChanged: null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          print('Discoverable requested');
                          final int timeout = await FlutterBluetoothSerial.instance.requestDiscoverable(60);
                          if (timeout < 0) {
                            print('Discoverable mode denied');
                          }
                          else {
                            print('Discoverable mode acquired for $timeout seconds');
                          }
                          setState(() {
                            _discoverableTimeoutTimer?.cancel();
                            _discoverableTimeoutSecondsLeft = timeout;
                            _discoverableTimeoutTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
                              setState(() {
                                if (_discoverableTimeoutSecondsLeft < 0) {
                                  FlutterBluetoothSerial.instance.isDiscoverable.then((isDiscoverable) {
                                    if (isDiscoverable) {
                                      print("Discoverable after timeout... might be infinity timeout :F");
                                      _discoverableTimeoutSecondsLeft += 1;
                                    }
                                  });
                                  timer.cancel();
                                  _discoverableTimeoutSecondsLeft = 0;
                                }
                                else {
                                  _discoverableTimeoutSecondsLeft -= 1;
                                }
                              });
                            });
                          });
                        },
                      )
                    ]
                )
            ),

            Divider(),
            ListTile(
                title: const Text('Обнаружение и подключение устройств')
            ),
            SwitchListTile(
              title: const Text('Автоматически подбор пин-кода'),
              subtitle: const Text('Пин-код: 1234'),
              value: _autoAcceptPairingRequests,
              onChanged: (bool value) {
                setState(() {
                  _autoAcceptPairingRequests = value;
                });
                if (value) {
                  FlutterBluetoothSerial.instance.setPairingRequestHandler((BluetoothPairingRequest request) {
                    print("Trying to auto-pair with Pin 1234");
                    if (request.pairingVariant == PairingVariant.Pin) {
                      return Future.value("1234");
                    }
                    return null;
                  });
                }
                else {
                  FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
                }
              },
            ),
            ListTile(
              title: RaisedButton(
                  child: const Text('Поиск устройств'),
                  onPressed: () async {
                    final BluetoothDevice selectedDevice = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) { return DiscoveryPage(); })
                    );

                    if (selectedDevice != null) {
                      print('Discovery -> selected ' + selectedDevice.address);
                    }
                    else {
                      print('Discovery -> no device selected');
                    }
                  }
              ),
            ),
            ListTile(
              title: RaisedButton(
                child: const Text('Подключиться к устройству'),
                onPressed: () async {
                  final BluetoothDevice selectedDevice = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) { return SelectBondedDevicePage(checkAvailability: false); })
                  );

                  if (selectedDevice != null) {
                    print('Connect -> selected ' + selectedDevice.address);
                    _startChat(context, selectedDevice);
                  }
                  else {
                    print('Connect -> no device selected');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) { return ChatPage(server: server); }));
  }

}
