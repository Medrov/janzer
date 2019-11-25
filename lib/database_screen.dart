import 'package:flutter/material.dart';
import 'package:janzer/DBHelper.dart';
import 'package:janzer/database_model.dart';
class DatabaseScreen extends StatefulWidget {
  @override
  _DatabaseScreenState createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  void _closeModallBD(void value) {}
  var icons = [
    Icons.timelapse,
    Icons.date_range,
    Icons.timeline,
    Icons.landscape,
    Icons.cloud,
    Icons.today,
    Icons.gps_fixed,
    Icons.av_timer,
    Icons.center_focus_weak,
    Icons.present_to_all,
    Icons.device_hub,
    Icons.data_usage,
    Icons.assistant_photo,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Janzer"),
        backgroundColor: Colors.blueAccent,
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
                          child: Container(
                            height: 170.0,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(16.0, 4.0, 8.0, 8.0),
                                      child: Text(
                                        'Место номер: ${index + 1}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontFamily: 'Century Gothic',
                                          fontSize: 20.0,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(16.0, 4.0, 8.0, 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Text(
                                                snapshot.data[index].moduleDate,
                                                style: TextStyle(
                                                  color: Theme.of(context).primaryColor,
                                                  fontFamily: 'Century Gothic',
                                                  fontSize: 17.0,
                                                  height: 1.5,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  snapshot.data[index].moduleDay+", " + snapshot.data[index].moduleTime,
                                                  style: TextStyle(
                                                    color: Theme.of(context).primaryColor,
                                                    fontFamily: 'Century Gothic',
                                                    fontSize: 17.0,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 16.0),
                                          child: Icon(Icons.date_range,
                                              size: 29.0,
                                              color: Theme.of(context).primaryColor),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(4.0, 4.0, 16.0, 16.0),
                                          child: Icon(Icons.center_focus_weak,
                                              size: 29.0,
                                              color: Theme.of(context).primaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            var snapshots = [
                            "Дата: "+ snapshot.data[index].moduleDate,
                            "Время: "+ snapshot.data[index].moduleTime,
                            "День недели: " + snapshot.data[index].moduleDay,
                            "Широта: " + snapshot.data[index].latitude,
                            "Долгота: " + snapshot.data[index].longitude,
                            "GPS-Satellites: "+ snapshot.data[index].gpsSatellites,
                            "GPS-Time: "+ snapshot.data[index].gpsTime,
                            "GPS-Date: "+ snapshot.data[index].gpsDate,
                            "Температура: "+ snapshot.data[index].temperature,
                            "Давление: "+ snapshot.data[index].pressure,
                            "Влажность: "+ snapshot.data[index].humidity,
                            "Коэффицент пыли: "+ snapshot.data[index].dust,
                            "Радиоционный фон: "+ snapshot.data[index].sievert,
                            ];
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
                                                          child: Text('${snapshots[index]}', style: new TextStyle(color: Colors.white),),
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
