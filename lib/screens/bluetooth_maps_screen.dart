import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:janzer/db/DBHelper.dart';
import 'package:janzer/db/database_model.dart';
import 'package:janzer/screens/database_screen.dart';
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
import 'package:intl/intl.dart';
class ListStructure {
  dynamic key;
  dynamic values;

  ListStructure(this.key, this.values);
}

class MapsBluetoothScreen extends StatefulWidget {
  final String text;
  final int count;
  MapsBluetoothScreen({Key key, @required this.text,  @required this.count}) : super(key: key);
  @override
  _MapsBluetoothScreenState createState() => _MapsBluetoothScreenState();
}

class _MapsBluetoothScreenState extends State<MapsBluetoothScreen>
    with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();
  final islocationpermission = false;
  static const LatLng _center = const LatLng(55.7504461, 37.6174943);
  MapType _currentMapType = MapType.normal;
  Set<Marker> _markers = Set();
  LatLng _lastMapPosition = _center;
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
  List _masForUsing;
  double latitude;
  double longitude;
  String realTime, moduleDate, moduleTime, moduleDay,
      gpsCoordinates, gpsSatellites, gpsTime, gpsDate,
      temperature, pressure, humidity, dust, sievert;
  int id;
  var numberOfLines;
  String readPath;
  int countOfDB;
  Map<double, double> coordinates = new Map();
  Map<int, double> coordinatesLatitude = new Map();
  Map<int, double> coordinatesLongitude = new Map();
  List<ListStructure> list = new List<ListStructure>();
  String selectedDateStart = "";
  String selectedDateFinish = "";
  DateTime calendar = new DateTime.now();
  var today;

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

  @override
  void initState() {
    super.initState();
    setMarkers();
    _controllerText.addListener(() => _extension = _controllerText.text);
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse)
        .then(_updateStatus);
    _askPermission();
    today = DateFormat('yyyy-MM-dd').format(calendar);
    print(today);

  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }



  void showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) => new Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0.0,
        child: new Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: 32.0,
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              margin: EdgeInsets.only(top: 16.0),
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16.0,
                    offset: const Offset(0.0, 16.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  Text(
                    "Информация",
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueAccent),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "Не удалось загрузить данные, аппарат не может найти спутники!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      color: Colors.blueAccent,
                      onPressed: () {
                        Navigator.of(context).pop(); // To close the dialog
                      },
                      child: Text(
                        "ОК",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        onPress: (){
          gpsHelper(widget.text, widget.count);
        },
      ),
    );
  }

  void gpsHelper(String text, int count) async {
    List _masForUsingTime,
        _masForUsingFinal,
        _masForUsingFinalCordinates,
        _masForGpsSatellites,
        _masForGpsTime,
        _masForGpsDate,
        _masForTemperature,
        _masForPressure,
        _masForHumidity,
        _masForDust,
        _masForSievert;
    var rng = new Random();
    var rnglatitude = rng.nextDouble() * 0.036;
    var rnglongitude = rng.nextDouble() * 0.05;
    LineSplitter ls = new LineSplitter();
    _masForUsing = ls.convert(text);
    for (int i = 0; i < 11; i++) print(_masForUsing[i]);
    _masForUsingTime = _masForUsing[1].split(",");
    moduleDate = _masForUsingTime[1];
    moduleTime = _masForUsingTime[2];
    moduleDay = _masForUsingTime[3];
    if (moduleDay == " Mon")
      moduleDay = "Понедельник";
    else if (moduleDay == " Tue")
      moduleDay = "Вторник";
    else if (moduleDay == " Wed")
      moduleDay = "Среда";
    else if (moduleDay == " Thu")
      moduleDay = "Четверг";
    else if (moduleDay == " Fri")
      moduleDay = "Пятница";
    else if (moduleDay == " Sat")
      moduleDay = "Суббота";
    else if (moduleDay == " Sun") moduleDay = "Воскресенье";
    print(moduleDate);
    print(moduleTime);
    print(moduleDay);
    _masForUsingFinal = _masForUsing[2].split(":");
    _masForUsingFinalCordinates = _masForUsingFinal[1].split(";");

    if (_masForUsingFinalCordinates[0] == " x" &&
        _masForUsingFinalCordinates[1] == " x") {
      return showAlert();
    } else {
      latitude = double.parse(_masForUsingFinalCordinates[0]) + rnglatitude;
      longitude = double.parse(_masForUsingFinalCordinates[1]) + rnglongitude;
      _masForGpsSatellites = _masForUsing[3].split(":");
      _masForGpsTime = _masForUsing[4].split(":");
      _masForGpsDate = _masForUsing[5].split(":");
      _masForTemperature = _masForUsing[6].split(":");
      _masForPressure = _masForUsing[7].split(":");
      _masForHumidity = _masForUsing[8].split(":");
      _masForDust = _masForUsing[9].split(":");
      _masForSievert = _masForUsing[10].split(":");
      gpsSatellites = _masForGpsSatellites[1];
      gpsTime = _masForGpsTime[1];
      gpsDate = _masForGpsDate[1];
      temperature = _masForTemperature[1];
      pressure = _masForPressure[1];
      humidity = _masForHumidity[1];
      dust = _masForDust[1];
      sievert = _masForSievert[1];
      print(latitude);
      print(longitude);
      sumbitContact();
    }
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

  void _showModal(int index) {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
            future: getContactsFromDB(),
            builder: (context, snapshot) {
              if (snapshot.data != null && snapshot.hasData) {
                var snapshots = [
                  "Дата: " + snapshot.data[index].moduleDate,
                  "Время: " + snapshot.data[index].moduleTime,
                  "День недели: " + snapshot.data[index].moduleDay,
                  "Широта: " + snapshot.data[index].latitude,
                  "Долгота: " + snapshot.data[index].longitude,
                  "GPS-Satellites: " + snapshot.data[index].gpsSatellites,
                  "GPS-Time: " + snapshot.data[index].gpsTime,
                  "GPS-Date: " + snapshot.data[index].gpsDate,
                  "Температура: " + snapshot.data[index].temperature,
                  "Давление: " + snapshot.data[index].pressure,
                  "Влажность: " + snapshot.data[index].humidity,
                  "Коэффицент пыли: " + snapshot.data[index].dust,
                  "Радиоционный фон: " + snapshot.data[index].sievert,
                ];
                return Container(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Данные о месте",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontSize: 21.0, color: Colors.black)),
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
                                          padding: EdgeInsets.fromLTRB(
                                              16.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            '${snapshots[index]}',
                                            style:
                                            new TextStyle(color: Colors.white),
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
              }
              return new Container(
                alignment: AlignmentDirectional.center,
                child: new CircularProgressIndicator(),
              );
            });
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {}

  void setMarkers() async {
    var dbHelper = new DBHelper();
    var notes = await dbHelper.getContacts();
    List<Marker> markers = notes.map((n) {
      double latitude = double.parse(n.latitude);
      double longitude = double.parse(n.longitude);
      print(latitude);
      print(longitude);
      LatLng point = LatLng(latitude, longitude);
      MarkerId markerId = MarkerId("${n.latitude}, ${n.longitude}");
      return Marker(
          markerId: markerId,
          draggable: true,
          icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
          position: point,
          onTap: () {
            _showModal(n.id - 1);
          });
    }).toList();
    setState(() {
      _markers.clear();
      notes.asMap().forEach((index, value) => _markers.add(markers[index]));
      print(_markers);
    });
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
            compassEnabled: true,
            onCameraMove: _onCameraMove,
            markers: _markers,
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
