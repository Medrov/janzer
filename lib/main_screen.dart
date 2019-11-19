//import 'dart:convert';
//import 'package:flutter/material.dart';
//import 'package:file_picker/file_picker.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:janzer/DBHelper.dart';
//import 'package:janzer/database_model.dart';
//import 'package:janzer/fancy_tab_bar.dart';
//import 'package:janzer/maps_screen.dart';
//import 'dart:async';
//import 'dart:io';
//import 'package:open_file/open_file.dart';
//import 'package:flutter/services.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'dart:math';
//
//import 'package:shared_preferences/shared_preferences.dart';
//
//class MainScreen extends StatefulWidget {
//  @override
//  _MainScreenState createState() => _MainScreenState();
//}
//
//class _MainScreenState extends State<MainScreen> {
//  String _fileName;
//  String _path;
//  Map<String, String> _paths;
//  String _extension;
//  bool _loadingPath = false;
//  bool _multiPick = true;
//  bool _hasValidMime = false;
//  FileType _pickingType;
//  TextEditingController _controller = new TextEditingController();
//  PermissionStatus _status;
//  String _dataTxt = 'Unknown';
//  List _masForUsing;
//  double latitude;
//  double longitude;
//  String realTime,
//      moduleDate,
//      moduleTime,
//      moduleDay,
//      gpsCoordinates,
//      gpsSatellites,
//      gpsTime,
//      gpsDate,
//      temperature,
//      pressure,
//      humidity,
//      dust,
//      sievert;
//  int id;
//  var numberOfLines;
//
//
//  @override
//  void initState() {
//    super.initState();
//    _controller.addListener(() => _extension = _controller.text);
//    PermissionHandler()
//        .checkPermissionStatus(PermissionGroup.locationWhenInUse)
//        .then(_updateStatus);
//  }
//
//  void gpsHelper(String text, int count) async {
//    LineSplitter ls = new LineSplitter();
//    _masForUsing = ls.convert(text);
//    realTime = _masForUsing[1];
//    gpsCoordinates = _masForUsing[2];
//    gpsSatellites = _masForUsing[3];
//    gpsTime = _masForUsing[4];
//    gpsDate = _masForUsing[5];
//    temperature = _masForUsing[6];
//    pressure = _masForUsing[7];
//    humidity = _masForUsing[8];
//    dust = _masForUsing[9];
//    sievert = _masForUsing[10];
//    print(_masForUsing[0]);
//    print(_masForUsing[1]);
//    print(_masForUsing[2]);
//    print(_masForUsing[3]);
//    print(_masForUsing[4]);
//    print(_masForUsing[5]);
//    print(_masForUsing[6]);
//    print(_masForUsing[7]);
//    print(_masForUsing[8]);
//    print(_masForUsing[9]);
//    print(_masForUsing[10]);
//    print(_masForUsing[11]);
//  }
//
//  void sumbitContact() {
//    var databaseModel = DatabaseModel();
//    var dbHelper = DBHelper();
//    databaseModel.realTime = realTime;
//    databaseModel.moduleDate = moduleDate;
//    databaseModel.moduleTime = moduleTime;
//    databaseModel.moduleDay = moduleDay;
//    databaseModel.pressure = pressure;
//    databaseModel.gpsCoordinates = gpsCoordinates;
//    databaseModel.gpsSatellites = gpsSatellites;
//    databaseModel.gpsTime = gpsTime;
//    databaseModel.gpsDate = gpsDate;
//    databaseModel.temperature = temperature;
//    databaseModel.humidity = humidity;
//    databaseModel.dust = dust;
//    databaseModel.sievert = sievert;
//    databaseModel.longitude = longitude.toString();
//    databaseModel.latitude = latitude.toString();
//    dbHelper.addNewContact(databaseModel);
//  }
//
//  void gpsFinal() {
//    var rng = new Random();
//    var rnglatitude = rng.nextDouble()*0.05;
//    var rnglongitude = rng.nextDouble()*0.05;
//    List _masForUsingTime = _masForUsing[1].split(",");
//    moduleDate = _masForUsingTime[1];
//    moduleTime = _masForUsingTime[2];
//    moduleDay = _masForUsingTime[3];
//    print(moduleDate);
//    print(moduleTime);
//    print(moduleDay);
//    List _masForUsingFinal = _masForUsing[2].split(":");
//    List _masForUsingFinalCordinates = _masForUsingFinal[1].split(";");
//    latitude = double.parse(_masForUsingFinalCordinates[0])+rnglatitude;
//    longitude = double.parse(_masForUsingFinalCordinates[1])+rnglongitude;
//    print(latitude);
//    print(longitude);
//  }
//
//  void _openFileExplorer() async {
//    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
//      setState(() => _loadingPath = true);
//      try {
//        if (_multiPick) {
//          _path = null;
//          _paths = await FilePicker.getMultiFilePath(
//              type: _pickingType, fileExtension: _extension);
//        } else {
//          _paths = null;
//          _path = await FilePicker.getFilePath(
//              type: _pickingType, fileExtension: _extension);
//          print(_path + " Hey");
//          setState(() async {
//            _dataTxt = await OpenFile.open(_paths);
//          });
//        }
//      } on PlatformException catch (e) {
//        print("Unsupported operation" + e.toString());
//      }
//      if (!mounted) return;
//      setState(() {
//        _loadingPath = false;
//        _fileName = _path != null
//            ? _path.split('/').last
//            : _paths != null ? _paths.keys.toString() : '...';
//      });
//    }
//  }
//
//  void navigateToMap(String path) async {
//    Navigator.of(context).push(
//      MaterialPageRoute(
//          builder: (BuildContext context) => MapsScreen(
//            path: path,
//            latitude: latitude,
//            longitude: longitude,
//            realTime: realTime,
//            moduleDate: moduleDate,
//            moduleTime: moduleTime,
//            moduleDay: moduleDay,
//            gpsCoordinates: gpsCoordinates,
//            gpsSatellites: gpsSatellites,
//            gpsTime: gpsTime,
//            gpsDate: gpsDate,
//            temperature: temperature,
//            pressure: pressure,
//            humidity: humidity,
//            dust: dust,
//            sievert: sievert,
//          )),
//    );
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    int count = prefs.getInt('count');
//    for(int i = 0; i <count; i++){
//      prefs.setDouble('latitude', latitude);
//      prefs.setDouble('longitude', longitude);
//    }
//    _askPermission();
//  }
//
//  Future<void> _read(String path) async {
//    String text;
//    try {
//      final file = File(path);
//      numberOfLines = file.readAsLinesSync().length;
//      print(numberOfLines.toString() + " this full part of this shit");
//      _masForUsing = new List(numberOfLines);
//
//      text = await file.readAsString();
//    } catch (e) {
//      print("Couldn't read file");
//    }
//    setState(() {
//      _dataTxt = text;
//      gpsHelper(_dataTxt, numberOfLines);
//      gpsFinal();
//      sumbitContact();
//    });
//  }
//
//  Future<void> openFile(String filePath) async {
//    final message = await OpenFile.open(filePath);
//    setState(() {
//      _dataTxt = message;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return SafeArea(
//      child:  Scaffold(
//        body: new Center(
//            child: new Padding(
//              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//              child: new SingleChildScrollView(
//                child: new Column(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    new ConstrainedBox(
//                      constraints: BoxConstraints.tightFor(width: 100.0),
//                      child: _pickingType == FileType.CUSTOM
//                          ? new TextFormField(
//                        maxLength: 15,
//                        autovalidate: true,
//                        controller: _controller,
//                        decoration:
//                        InputDecoration(labelText: 'File extension'),
//                        keyboardType: TextInputType.text,
//                        textCapitalization: TextCapitalization.none,
//                        validator: (value) {
//                          RegExp reg = new RegExp(r'[^a-zA-Z0-9]');
//                          if (reg.hasMatch(value)) {
//                            _hasValidMime = false;
//                            return 'Invalid format';
//                          }
//                          _hasValidMime = true;
//                          return null;
//                        },
//                      )
//                          : new Container(),
//                    ),
//                    new Padding(
//                      padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
//                      child: new RaisedButton(
//                        onPressed: () => _openFileExplorer(),
//                        child: new Text("Открыть файл"),
//                      ),
//                    ),
//                    new Padding(
//                      padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
//                      child: new RaisedButton(
//                        onPressed: () => navigateToMap(_path),
//                        child: new Text("Перейти к картам"),
//                      ),
//                    ),
//                    new Padding(
//                        padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
//                        child: Column(
//                          children: <Widget>[Text(_dataTxt.toString())],
//                        )),
//                    new Builder(
//                      builder: (BuildContext context) => _loadingPath
//                          ? Padding(
//                          padding: const EdgeInsets.only(bottom: 10.0),
//                          child: const CircularProgressIndicator())
//                          : _path != null || _paths != null
//                          ? new Container(
//                        padding: const EdgeInsets.only(bottom: 30.0),
//                        height: MediaQuery.of(context).size.height * 0.50,
//                        child: new Scrollbar(
//                            child: new ListView.separated(
//                              itemCount: _paths != null && _paths.isNotEmpty
//                                  ? _paths.length
//                                  : 1,
//                              itemBuilder: (BuildContext context, int index) {
//                                final bool isMultiPath =
//                                    _paths != null && _paths.isNotEmpty;
//                                final String name = 'File $index: ' +
//                                    (isMultiPath
//                                        ? _paths.keys.toList()[index]
//                                        : _fileName ?? '...');
//                                final path = isMultiPath
//                                    ? _paths.values.toList()[index].toString()
//                                    : _path;
//
//                                return new ListTile(
//                                  title: new Text(
//                                    name,
//                                  ),
//                                  subtitle: new Text(path),
//                                  onTap: () {
//                                    //openFile(path);
//                                    _read(path);
//                                  },
//                                );
//                              },
//                              separatorBuilder:
//                                  (BuildContext context, int index) =>
//                              new Divider(),
//                            )),
//                      )
//                          : new Container(),
//                    ),
//                  ],
//                ),
//              ),
//            )),
//      ),
//    );
//  }
//
//  void _updateStatus(PermissionStatus value) {
//    if (value != _status) {
//      setState(() {
//        _status = value;
//      });
//    }
//  }
//
//  void _askPermission() {
//    PermissionHandler().requestPermissions([
//      PermissionGroup.locationWhenInUse,
//      PermissionGroup.location
//    ]).then(_onStatusRequested);
//    PermissionHandler().requestPermissions([PermissionGroup.location]).then(
//        _onStatusRequested);
//  }
//
//  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> value) {
//    final status = value[PermissionGroup.locationWhenInUse];
//    final statusLoc = value[PermissionGroup.location];
//    if (status != PermissionStatus.granted &&
//        statusLoc != PermissionStatus.granted) {
//      PermissionHandler().openAppSettings();
//    } else {
//      _updateStatus(status);
//      _updateStatus(statusLoc);
//    }
//  }
//}
//
//
//
