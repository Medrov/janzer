import 'dart:async';
import 'dart:io' as io;

import 'package:janzer/database_model.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  static Database db_instance;

  final String TABLE_NAME = "DatabaseModel";

  Future<Database> get db async {
    if (db_instance == null) db_instance = await initDB();
    return db_instance;
  }

  initDB() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "maps_database.db");
    var db = await openDatabase(path, version: 3, onCreate: onCreateFunc);
    return db;
  }


  void onCreateFunc(Database db, int version) async {
    await db.execute('CREATE TABLE $TABLE_NAME'
        '(id INTEGER PRIMARY KEY,'
        'realTime TEXT, '
        'moduleDate TEXT, '
        'moduleTime TEXT, '
        'moduleDay TEXT, '
        'gpsCoordinates TEXT, '
        'gpsSatellites TEXT, '
        'gpsTime TEXT, '
        'gpsDate TEXT, '
        'temperature TEXT, '
        'pressure TEXT, '
        'humidity TEXT, '
        'dust TEXT, '
        'zivert TEXT, '
        'longitude TEXT, '
        'latitude TEXT )');

  }

  //getData
  Future<List<DatabaseModel>> getContacts() async {
    var db_connection = await db;
    List<Map> list = await db_connection.rawQuery('SELECT * FROM $TABLE_NAME');
    List<DatabaseModel> databaseModelS = new List();
    for (int i = 0; i < list.length; i++) {
      DatabaseModel databaseModel = new DatabaseModel();
      databaseModel.id = list[i]['id'];
      databaseModel.realTime = list[i]['realTime'];
      databaseModel.moduleDate = list[i]['moduleDate'];
      databaseModel.moduleTime = list[i]['moduleTime'];
      databaseModel.moduleDay = list[i]['moduleDay'];
      databaseModel.gpsCoordinates = list[i]['systemTime'];
      databaseModel.gpsSatellites = list[i]['gpsSatellites'];
      databaseModel.gpsTime = list[i]['gpsTime'];
      databaseModel.gpsDate = list[i]['gpsDate'];
      databaseModel.temperature = list[i]['temperature'];
      databaseModel.pressure = list[i]['pressure'];
      databaseModel.humidity = list[i]['humidity'];
      databaseModel.dust = list[i]['dust'];
      databaseModel.sievert = list[i]['zivert'];
      databaseModel.longitude = list[i]['longitude'];
      databaseModel.latitude = list[i]['latitude'];

      databaseModelS.add(databaseModel);
    }

    return databaseModelS;
  }
  Future<double> getLongitude(int index) async {
    var dbConnection = await db;
    List<Map> list = await dbConnection.rawQuery('SELECT * FROM $TABLE_NAME');
    double longitude = double.parse(list[index]['longitude']);
    return longitude;

  }
  Future<double> getLatitude(int index) async {
    var dbConnection = await db;
    List<Map> list = await dbConnection.rawQuery('SELECT * FROM $TABLE_NAME');
    double latitude = double.parse(list[index]['latitude']);
    return latitude;
  }

  void addNewContact(DatabaseModel databaseModel) async {
    var db_connection = await db;
    List<Map> list = await db_connection.rawQuery('SELECT * FROM $TABLE_NAME');
    int count = list.length;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('count', count);
    String query = 'INSERT INTO '
        '$TABLE_NAME(realTime, '
        'moduleDate, '
        'moduleTime, '
        'moduleDay, '
        'gpsCoordinates, '
        'gpsSatellites, '
        'gpsTime, '
        'gpsDate, '
        'temperature, '
        'temperature, '
        'pressure, '
        'dust, '
        'zivert, '
        'longitude, '
        'latitude) '
        'VALUES( \'${databaseModel.realTime}\','
        '\'${databaseModel.moduleDate}\', '
        '\'${databaseModel.moduleTime}\','
        '\'${databaseModel.moduleDay}\','
        '\'${databaseModel.gpsCoordinates}\', '
        '\'${databaseModel.gpsSatellites}\','
        '\'${databaseModel.gpsTime}\','
        '\'${databaseModel.gpsDate}\','
        '\'${databaseModel.temperature}\', '
        '\'${databaseModel.pressure}\', '
        '\'${databaseModel.humidity}\','
        '\'${databaseModel.dust}\','
        '\'${databaseModel.sievert}\','
        '\'${databaseModel.longitude}\','
        '\'${databaseModel.latitude}\')';
    await db_connection.transaction((transition) async {
      return await transition.rawInsert(query);
    });
  }

  void updateContact(DatabaseModel databaseModel) async {
    var db_connection = await db;
    String query =
        'UPDATE $TABLE_NAME SET name ='
        '\'${databaseModel.realTime}\','
        '\'${databaseModel.moduleDate}\', '
        '\'${databaseModel.moduleTime}\','
        '\'${databaseModel.moduleDay}\','
        '\'${databaseModel.gpsCoordinates}\', '
        '\'${databaseModel.gpsSatellites}\','
        '\'${databaseModel.gpsTime}\','
        '\'${databaseModel.gpsDate}\','
        '\'${databaseModel.temperature}\', '
        '\'${databaseModel.pressure}\', '
        '\'${databaseModel.humidity}\','
        '\'${databaseModel.dust}\','
        '\'${databaseModel.sievert}\','
        '\'${databaseModel.longitude}\','
        '\'${databaseModel.latitude}\' WHERE id = ${databaseModel.id}';
    await db_connection.transaction((transition) async {
      return await transition.rawQuery(query);
    });
  }

  void deleteContact(DatabaseModel databaseModel) async {
    var db_connection = await db;
    String query = 'DELETE FROM $TABLE_NAME WHERE id = ${databaseModel.id}';
    await db_connection.transaction((transition) async {
      return await transition.rawQuery(query);
    });
  }
}
