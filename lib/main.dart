import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:janzer/DBHelper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:async';

import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'The Janzer',
      home: FilePickerDemo(),
    ),
  );
}

class FilePickerDemo extends StatefulWidget {
  @override
  _FilePickerDemoState createState() => new _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FilePickerDemo> {
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = true;
  bool _hasValidMime = false;
  FileType _pickingType;
  TextEditingController _controller = new TextEditingController();
  PermissionStatus _status;
  String _dataTxt = 'Unknown';
  List _masForUsing;
  double latitude;
  double longitude;
  String realTime,
      moduleDate,
      moduleTime,
      moduleDay,
      gpsCoordinates,
      gpsSatellites,
      gpsTime,
      gpsDate,
      temperature,
      pressure,
      humidity,
      dust,
      sievert;
  int id;
  var numberOfLines;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse)
        .then(_updateStatus);
  }

  void gpsHelper(String text, int count) async {
    LineSplitter ls = new LineSplitter();
    _masForUsing = ls.convert(text);
    realTime = _masForUsing[1];
    gpsCoordinates = _masForUsing[2];
    gpsSatellites = _masForUsing[3];
    gpsTime = _masForUsing[4];
    gpsDate = _masForUsing[5];
    temperature = _masForUsing[6];
    pressure = _masForUsing[7];
    humidity = _masForUsing[8];
    dust = _masForUsing[9];
    sievert = _masForUsing[10];
    print(_masForUsing[0]);
    print(_masForUsing[1]);
    print(_masForUsing[2]);
    print(_masForUsing[3]);
    print(_masForUsing[4]);
    print(_masForUsing[5]);
    print(_masForUsing[6]);
    print(_masForUsing[7]);
    print(_masForUsing[8]);
    print(_masForUsing[9]);
    print(_masForUsing[10]);
    print(_masForUsing[11]);
  }

  void sumbitContact() {
    var databaseModel = DatabaseModel();
    databaseModel.realTime = realTime;
    databaseModel.moduleDate = moduleDate;
    databaseModel.moduleTime = moduleTime;
    databaseModel.moduleDay = moduleDay;
    databaseModel.pressure = pressure;
    databaseModel.gpsCoordinates = gpsCoordinates;
    databaseModel.gpsSatellites = gpsSatellites;
    databaseModel.gpsTime = gpsTime;
    databaseModel.gpsDate = gpsDate;
    databaseModel.temperature = temperature;
    databaseModel.humidity = humidity;
    databaseModel.dust = dust;
    databaseModel.sievert = sievert;
    var dbHelper = DBHelper();
    dbHelper.addNewContact(databaseModel);
  }

  void gpsFinal() {
    List _masForUsingTime = _masForUsing[1].split(",");
    moduleDate = _masForUsingTime[1];
    moduleTime = _masForUsingTime[2];
    moduleDay = _masForUsingTime[3];
    print(moduleDate);
    print(moduleTime);
    print(moduleDay);
    List _masForUsingFinal = _masForUsing[2].split(":");
    List _masForUsingFinalCordinates = _masForUsingFinal[1].split(";");
    latitude = double.parse(_masForUsingFinalCordinates[0]);
    longitude = double.parse(_masForUsingFinalCordinates[1]);
    print(latitude);
    print(longitude);
  }

  void _openFileExplorer() async {
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType, fileExtension: _extension);
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
              type: _pickingType, fileExtension: _extension);
          print(_path + " Hey");
          setState(() async {
            _dataTxt = await OpenFile.open(_paths);
          });
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null ? _paths.keys.toString() : '...';
      });
    }
  }

  void navigateToMap(String path) async {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (BuildContext context) => MapSample(
                path: path,
                latitude: latitude,
                longitude: longitude,
                realTime: realTime,
                moduleDate: moduleDate,
                moduleTime: moduleTime,
                moduleDay: moduleDay,
                gpsCoordinates: gpsCoordinates,
                gpsSatellites: gpsSatellites,
                gpsTime: gpsTime,
                gpsDate: gpsDate,
                temperature: temperature,
                pressure: pressure,
                humidity: humidity,
                dust: dust,
                sievert: sievert,
              )),
    );
    _askPermission();
  }

  Future<void> _read(String path) async {
    String text;
    try {
      final file = File(path);
      numberOfLines = file.readAsLinesSync().length;
      print(numberOfLines.toString() + " this full part of this shit");
      _masForUsing = new List(numberOfLines);

      text = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    setState(() {
      _dataTxt = text;
      gpsHelper(_dataTxt, numberOfLines);
      gpsFinal();
      sumbitContact();
    });
  }

  Future<void> openFile(String filePath) async {
    final message = await OpenFile.open(filePath);
    setState(() {
      _dataTxt = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('The Janzer'),
        ),
        body: new Center(
            child: new Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: new SingleChildScrollView(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 100.0),
                  child: _pickingType == FileType.CUSTOM
                      ? new TextFormField(
                          maxLength: 15,
                          autovalidate: true,
                          controller: _controller,
                          decoration:
                              InputDecoration(labelText: 'File extension'),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            RegExp reg = new RegExp(r'[^a-zA-Z0-9]');
                            if (reg.hasMatch(value)) {
                              _hasValidMime = false;
                              return 'Invalid format';
                            }
                            _hasValidMime = true;
                            return null;
                          },
                        )
                      : new Container(),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: new RaisedButton(
                    onPressed: () => _openFileExplorer(),
                    child: new Text("Открыть файл"),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: new RaisedButton(
                    onPressed: () => navigateToMap(_path),
                    child: new Text("Перейти к картам"),
                  ),
                ),
                new Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                    child: Column(
                      children: <Widget>[Text(_dataTxt.toString())],
                    )),
                new Builder(
                  builder: (BuildContext context) => _loadingPath
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: const CircularProgressIndicator())
                      : _path != null || _paths != null
                          ? new Container(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: new Scrollbar(
                                  child: new ListView.separated(
                                itemCount: _paths != null && _paths.isNotEmpty
                                    ? _paths.length
                                    : 1,
                                itemBuilder: (BuildContext context, int index) {
                                  final bool isMultiPath =
                                      _paths != null && _paths.isNotEmpty;
                                  final String name = 'File $index: ' +
                                      (isMultiPath
                                          ? _paths.keys.toList()[index]
                                          : _fileName ?? '...');
                                  final path = isMultiPath
                                      ? _paths.values.toList()[index].toString()
                                      : _path;

                                  return new ListTile(
                                    title: new Text(
                                      name,
                                    ),
                                    subtitle: new Text(path),
                                    onTap: () {
                                      //openFile(path);
                                      _read(path);
                                    },
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        new Divider(),
                              )),
                            )
                          : new Container(),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  void _updateStatus(PermissionStatus value) {
    if (value != _status) {
      setState(() {
        _status = value;
      });
    }
  }

  void _askPermission() {
    PermissionHandler().requestPermissions([
      PermissionGroup.locationWhenInUse,
      PermissionGroup.location
    ]).then(_onStatusRequested);
    PermissionHandler().requestPermissions([PermissionGroup.location]).then(
        _onStatusRequested);
  }

  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> value) {
    final status = value[PermissionGroup.locationWhenInUse];
    final statusLoc = value[PermissionGroup.location];
    if (status != PermissionStatus.granted &&
        statusLoc != PermissionStatus.granted) {
      PermissionHandler().openAppSettings();
    } else {
      _updateStatus(status);
      _updateStatus(statusLoc);
    }
  }
}

class MapSample extends StatefulWidget {
  final String path;
  double latitude;
  double longitude;
  String realTime,
      moduleDate,
      moduleTime,
      moduleDay,
      gpsCoordinates,
      gpsSatellites,
      gpsTime,
      gpsDate,
      temperature,
      pressure,
      humidity,
      dust,
      sievert;

  MapSample(
      {Key key,
      @required this.path,
      @required this.latitude,
      @required this.longitude,
      @required this.realTime,
      @required this.moduleDate,
      @required this.moduleTime,
      @required this.moduleDay,
      @required this.gpsCoordinates,
      @required this.gpsSatellites,
      @required this.gpsTime,
      @required this.gpsDate,
      @required this.temperature,
      @required this.pressure,
      @required this.humidity,
      @required this.dust,
      @required this.sievert})
      : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  List<Marker> allMarkers = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapController _controller;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController controller;
  var dbHelper = DBHelper();
  var icons = [
    Icons.timelapse,
    Icons.date_range,
    Icons.timeline,
    Icons.today,
    Icons.gps_fixed,
    Icons.satellite,
    Icons.av_timer,
    Icons.center_focus_weak,
    Icons.present_to_all,
    Icons.device_hub,
    Icons.data_usage,
    Icons.assistant_photo,
    Icons.assistant_photo
  ];
  var sets = new List(13);


  void _showModal() {
    int count = dbHelper.TABLE_NAME.length;
    print(count.toString() + " This is count");

    Future<void> future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                      "Данные о месте",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontSize: 21.0,
                          color: Colors.black
                      )),
                ),
                Container(
                    child: Column(
                  children: List.generate(13, (int index) {
                    return Card(
                      color: Colors.lightBlueAccent,
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: <Widget>[
                            Icon(icons[index], color: Colors.white),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                              child: Text('${sets[index]}', style: new TextStyle(color: Colors.white),),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ))
              ],
            ),
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {}

  @override
  void initState() {
    sets[0] = "Дата: "+ widget.moduleDate;
    sets[1] = "Время: "+ widget.moduleTime;
//    switch(widget.moduleDay){
//      case "Mon":
//        sets[2] = "День недели: Понедельник";
//        break;
//      case "Tue":
//        sets[2] = "День недели: Вторник";
//        break;
//      case "Wed":
//        sets[2] = "День недели: Среда";
//        break;
//      case "Thu":
//        sets[2] = "День недели: Четверг";
//        break;
//      case "Fri":
//        sets[2] = "День недели: Пятница";
//        break;
//      case "Sat":
//        sets[2] = "День недели: Суббота";
//        break;
//      case "Sun":
//        sets[2] = "День недели: Воскресенье";
//        break;
//    }
    sets[2] = "День недели: Пятница";
    sets[3] = "Широта: "+ widget.latitude.toString();
    sets[4] = "Долгота: "+ (widget.longitude * 1).toString();
    List _masForGpsSatellites = widget.gpsSatellites.split(":");
    List _masForGpsTime = widget.gpsTime.split(":");
    List _masForGpsDate = widget.gpsDate.split(":");
    List _masForTemperature = widget.temperature.split(":");
    List _masForPressure = widget.pressure.split(":");
    List _masForHumidity = widget.humidity.split(":");
    List _masForDust = widget.dust.split(":");
    List _masForSievert = widget.sievert.split(":");
    sets[5] = "GPS-Satellites: "+_masForGpsSatellites[1];
    sets[6] = "GPS-Time: "+_masForGpsTime[1];
    sets[7] = "GPS-Date: "+_masForGpsDate[1];
    sets[8] = "Температура: "+_masForTemperature[1];
    sets[9] = "Давление: "+_masForPressure[1];
    sets[10] = "Влажность: "+_masForHumidity[1];
    sets[11] = "Коэффицент пыли: "+_masForDust[1];
    sets[12] = "Радиоционный фон: "+_masForSievert[1];
    // TODO: implement initState
    super.initState();
    allMarkers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: true,
        onTap: () {
          _showModal();
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        position: LatLng(widget.latitude, widget.longitude)));
  }

  void showInSnackBar(String value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    showInSnackBar(widget.path);
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps'),
      ),
      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(0, 0), zoom: 12.0),
            markers: Set.from(allMarkers),
            onMapCreated: mapCreated,
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: InkWell(
                onTap: movetoNewYork,
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.green),
                  child: Icon(Icons.forward, color: Colors.white),
                ),
              ),
            )),
        Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: InkWell(
                onTap: movetoNewScreen,
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.cyan),
                  child: Icon(Icons.map, color: Colors.white),
                ),
              ),
            )),
      ]),
    );
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  movetoNewScreen() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => DatabaseScreen()));
  }
  movetoAllPoints() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => DatabaseScreen()));
  }
  movetoNewYork() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(widget.latitude, widget.longitude), zoom: 12.0),
    ));
  }

}

class DatabaseModel {
  DatabaseModel();

  String realTime,
      moduleDate,
      moduleTime,
      moduleDay,
      gpsCoordinates,
      gpsSatellites,
      gpsTime,
      gpsDate,
      temperature,
      pressure,
      humidity,
      dust,
      sievert;
  int id;
}

class DatabaseScreen extends StatefulWidget {
  @override
  _DatabaseScreenState createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  void _closeModallBD(void value) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: const Text('The Janzer'),
      ),
      body: new Container(
        child: FutureBuilder<List<DatabaseModel>>(
            future: getContactsFromDB(),
            builder: (context, snapshot) {
              if (snapshot.data != null && snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return new Card(
                        child: InkWell(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.star, color: Colors.lightBlue),
                              Text("Место номер ${index + 1}.")
                            ],
                          ),
                          onTap: () {
                            Future<void> future = showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  child: Wrap(
                                    children: <Widget>[
                                      Container(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          snapshot.data[index].pressure,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            future.then((void value) => _closeModallBD(value));
                          },
                        ),
                      );
                    });
              }
              return new Container(
                alignment: AlignmentDirectional.center,
                child: new CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}

Future<List<DatabaseModel>> getContactsFromDB() async {
  var dbHelper = DBHelper();
  Future<List<DatabaseModel>> contacts = dbHelper.getContacts();
  return contacts;
}
