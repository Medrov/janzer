import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:janzer/DBHelper.dart';
import 'package:janzer/database_model.dart';
import 'package:janzer/database_screen.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MapsDefaultScreen extends StatefulWidget {
  @override
  _MapsDefaultScreenState createState() => _MapsDefaultScreenState();
}

class _MapsDefaultScreenState extends State<MapsDefaultScreen>
    with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();
  final islocationpermission = false;

  static const LatLng _center = const LatLng(55.7504461, 37.6174943);
  MapType _currentMapType = MapType.normal;
  Set<Marker> _markers = Set();
  LatLng _lastMapPosition = _center;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = true;
  bool _hasValidMime = false;
  FileType _pickingType;
  TextEditingController _controllerText = new TextEditingController();
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
  String readPath;

  @override
  void initState() {
    super.initState();
    showAllMarkers();
    _controllerText.addListener(() => _extension = _controllerText.text);
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse)
        .then(_updateStatus);
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Widget _getFAB() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      child: SpeedDial(
        animatedIcon: AnimatedIcons.menu_arrow,
        animatedIconTheme: IconThemeData(size: 22),
        backgroundColor: Colors.blueAccent,
        visible: true,
        curve: Curves.bounceIn,
        children: [
          // FAB 1
          SpeedDialChild(
              child: Icon(Icons.shuffle),
              backgroundColor: Colors.amber,
              onTap: () {
               showAllMarkers();
              },
              label: 'Обновить',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: Colors.amber),
          // FAB 2
          SpeedDialChild(
              child: Icon(Icons.cloud_download),
              backgroundColor: Colors.deepPurpleAccent,
              onTap: () async {
                bool checker = false;
                var state = await _openFileExplorer(checker);
                if(state){
                  _read(readPath);
                }
              },
              label: 'Загрузить карту',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: Colors.deepPurpleAccent)
        ],
      ),
    );
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
    var dbHelper = DBHelper();
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
    databaseModel.longitude = longitude.toString();
    databaseModel.latitude = latitude.toString();
    dbHelper.addNewContact(databaseModel);
  }

  void gpsFinal() {
    var rng = new Random();
    var rnglatitude = rng.nextDouble() * 0.05;
    var rnglongitude = rng.nextDouble() * 0.05;
    List _masForUsingTime = _masForUsing[1].split(",");
    moduleDate = _masForUsingTime[1];
    moduleTime = _masForUsingTime[2];
    moduleDay = _masForUsingTime[3];
    print(moduleDate);
    print(moduleTime);
    print(moduleDay);
    List _masForUsingFinal = _masForUsing[2].split(":");
    List _masForUsingFinalCordinates = _masForUsingFinal[1].split(";");
    latitude = double.parse(_masForUsingFinalCordinates[0]) + rnglatitude;
    longitude = double.parse(_masForUsingFinalCordinates[1]) + rnglongitude;
    print(latitude);
    print(longitude);
  }

  void navigateToMap(String path) async {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (BuildContext context) => MapsScreen(
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('count');
    for (int i = 0; i < count; i++) {
      prefs.setDouble('latitude', latitude);
      prefs.setDouble('longitude', longitude);
    }
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

  Future<bool> _openFileExplorer(bool loadPath ) async {
    loadPath = false;
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
      setState(() {
        loadPath = true;
        print("This shit work");
      });
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType, fileExtension: _extension);
          setState(() {
            readPath = _paths["janzer.txt"];
            print(readPath);
          });
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
              type: _pickingType, fileExtension: _extension);
          setState(() async {
            _dataTxt = await OpenFile.open(_paths);
            readPath = _path;
            print(readPath);
          });
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) {
        setState(() async{
          print("Hey, Man");
          _loadingPath = false;
          loadPath = _loadingPath;
          _fileName = _path != null
              ? _path.split('/').last
              : _paths != null ? _paths.keys.toString() : '...';
        });
      }
    }
    return loadPath;
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

  void showAllMarkers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('count');
    var dbHelper = new DBHelper();
    for (int i = 0; i < count; i++) {
      double latitude = await dbHelper.getLatitude(i);
      double longitude = await dbHelper.getLatitude(i);
      final MarkerId markerId =
          MarkerId("${latitude.toString()}, ${longitude.toString()}");
      final Marker resultMarker = Marker(
        markerId: markerId,
        draggable: true,
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
        position: LatLng(latitude, longitude),
      );
      markers[markerId] = resultMarker;
      _markers.add(resultMarker);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: _currentMapType,
            onMapCreated: _onMapCreated,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              Factory<OneSequenceGestureRecognizer>(
                  () => ScaleGestureRecognizer())
            ].toSet(),
            compassEnabled: true,
            onCameraMove: _onCameraMove,
            markers: Set<Marker>.of(markers.values),
            // trackCameraPosition: true,
            zoomGesturesEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 10.0,
            ),
          ),
          _getFAB()
        ],
      ),
    );
  }
}

class MapsScreen extends StatefulWidget {
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

  MapsScreen(
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
  State<MapsScreen> createState() => MapsScreenState();
}

class MapsScreenState extends State<MapsScreen>
    with SingleTickerProviderStateMixin {
  Set<Marker> allMarkers = Set();
  GoogleMapController _controller;
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

  Future<void> showAllMarkers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('count');
    var dbHelper = new DBHelper();
    for (int i = 0; i < count; i++) {
      double latitude = await dbHelper.getLatitude(i);
      double longitude = await dbHelper.getLatitude(i);
      Marker resultMarker = Marker(
        markerId: MarkerId("${latitude.toString()}, ${longitude.toString()}"),
        draggable: true,
        onTap: () {
          _showModal();
        },
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
        position: LatLng(latitude, longitude),
      );
      allMarkers.add(resultMarker);
    }
  }

  void _showModal() {
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
                  child: Text("Данные о месте",
                      textAlign: TextAlign.center,
                      style:
                          new TextStyle(fontSize: 21.0, color: Colors.black)),
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
                              child: Text(
                                '${sets[index]}',
                                style: new TextStyle(color: Colors.white),
                              ),
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

  Future<List<DatabaseModel>> getContactsFromDB() async {
    var dbHelper = DBHelper();
    Future<List<DatabaseModel>> contacts = dbHelper.getContacts();
    return contacts;
  }

  @override
  void initState() {
    sets[0] = "Дата: " + widget.moduleDate;
    sets[1] = "Время: " + widget.moduleTime;
    switch (widget.moduleDay) {
      case "Mon":
        sets[2] = "День недели: Понедельник";
        break;
      case "Tue":
        sets[2] = "День недели: Вторник";
        break;
      case "Wed":
        sets[2] = "День недели: Среда";
        break;
      case "Thu":
        sets[2] = "День недели: Четверг";
        break;
      case "Fri":
        sets[2] = "День недели: Пятница";
        break;
      case "Sat":
        sets[2] = "День недели: Суббота";
        break;
      case "Sun":
        sets[2] = "День недели: Воскресенье";
        break;
    }
    sets[2] = "День недели: Пятница";
    sets[3] = "Широта: " + widget.latitude.toString();
    sets[4] = "Долгота: " + (widget.longitude * 1).toString();
    List _masForGpsSatellites = widget.gpsSatellites.split(":");
    List _masForGpsTime = widget.gpsTime.split(":");
    List _masForGpsDate = widget.gpsDate.split(":");
    List _masForTemperature = widget.temperature.split(":");
    List _masForPressure = widget.pressure.split(":");
    List _masForHumidity = widget.humidity.split(":");
    List _masForDust = widget.dust.split(":");
    List _masForSievert = widget.sievert.split(":");
    sets[5] = "GPS-Satellites: " + _masForGpsSatellites[1];
    sets[6] = "GPS-Time: " + _masForGpsTime[1];
    sets[7] = "GPS-Date: " + _masForGpsDate[1];
    sets[8] = "Температура: " + _masForTemperature[1];
    sets[9] = "Давление: " + _masForPressure[1];
    sets[10] = "Влажность: " + _masForHumidity[1];
    sets[11] = "Коэффицент пыли: " + _masForDust[1];
    sets[12] = "Радиоционный фон: " + _masForSievert[1];
    // TODO: implement initState
    super.initState();
    print(allMarkers.length);
  }

  void showInSnackBar(String value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    showInSnackBar(widget.path);
    showAllMarkers();
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps'),
      ),
      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            compassEnabled: true,
            initialCameraPosition:
                CameraPosition(target: LatLng(0, 0), zoom: 12.0),
            markers: Set.from(allMarkers),
            onMapCreated: mapCreated,
          ),
        ),
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 32.0),
              child: InkWell(
                onTap: movetoNewYork,
                child: Container(
                  height: 55.0,
                  width: 55.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.deepPurpleAccent),
                  child: Icon(Icons.open_in_browser, color: Colors.white),
                ),
              ),
            )),
        Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 24.0, 32.0),
              child: FloatingActionButton(
                onPressed: movetoNewYork,
                backgroundColor: Colors.amber,
                child: Icon(Icons.shuffle, color: Colors.white),
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
