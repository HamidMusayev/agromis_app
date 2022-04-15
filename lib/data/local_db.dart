import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDB {
  late Database _db;

  Future<Database> get db async {
    _db = await initializeDb();
    return _db;
  }

  Future<Database> initializeDb() async {
    String dbPath = join(await getDatabasesPath(), 'offline.db');
    var locDb = await openDatabase(dbPath, version: 1, onCreate: createDb);
    return locDb;
  }

  void createDb(Database db, int version) async {
    await db.execute(
        'Create table receive_data(PIN_DATA integer primary key, METHOD_NAME text, SEND_XML text, RESULT_XML text)');
  }

  Future<String?> getData(String methodName, String sendXML) async {
    Database db = await this.db;
    var result = await db.query('receive_data',
        where: 'METHOD_NAME=? and SEND_XML=?',
        whereArgs: [methodName, sendXML]);

    return result[0]['RESULT_XML'].toString();
  }

  Future<int> insert(
      String methodName, String sendXML, String resultXML) async {
    var map = <String, dynamic>{};
    map['METHOD_NAME'] = methodName;
    map['SEND_XML'] = sendXML;
    map['RESULT_XML'] = resultXML;

    Database db = await this.db;
    var result = await db.insert('receive_data', map);
    return result;
  }

  Future<int> update(
      String methodName, String sendXML, String resultXML) async {
    var map = <String, dynamic>{};
    map['METHOD_NAME'] = methodName;
    map['SEND_XML'] = sendXML;
    map['RESULT_XML'] = resultXML;

    Database db = await this.db;
    var result = await db.update('receive_data', map,
        where: 'METHOD_NAME=?', whereArgs: [methodName]);
    return result;
  }

  Future<int> delete(int id) async {
    Database db = await this.db;
    var result =
        await db.delete('receive_data', where: 'PIN_DATA =?', whereArgs: [id]);
    return result;
  }

  Future<void> updateOrInsert(
      String methodName, String sendXML, String resultXML) async {
    Database db = await this.db;
    var result = await db.query('receive_data',
        where: 'METHOD_NAME=? and SEND_XML=?',
        whereArgs: [methodName, sendXML]);
    if (result.isEmpty) {
      await insert(methodName, sendXML, resultXML);
    } else {
      await update(methodName, sendXML, resultXML);
    }
  }
}
