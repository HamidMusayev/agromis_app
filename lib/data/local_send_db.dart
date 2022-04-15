import 'package:aqromis_application/models/send_data_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalSendDB {
  late Database _db;

  Future<Database> get db async {
    _db = await initializeDb();
    return _db;
  }

  Future<Database> initializeDb() async {
    String dbPath = join(await getDatabasesPath(), 'offline_send.db');
    var locDb = await openDatabase(dbPath, version: 1, onCreate: createDb);
    return locDb;
  }

  void createDb(Database db, int version) async {
    await db.execute(
        'Create table send_data(PIN_DATA integer primary key, METHOD_NAME text, SEND_XML text, IS_SEND integer)');
  }

  Future<List<SendDataDB>> getDataList() async {
    Database db = await this.db;
    var result = await db.query('send_data');
    return List.generate(result.length, (i) {
      return SendDataDB.fromMap(result[i]);
    });
  }

  Future<int> insert(String methodName, String sendXML) async {
    var map = <String, dynamic>{};
    map['METHOD_NAME'] = methodName;
    map['SEND_XML'] = sendXML;
    map['IS_SEND'] = 0;

    Database db = await this.db;
    var result = await db.insert('send_data', map);
    return result;
  }

  Future<int> delete(int pinData) async {
    Database db = await this.db;
    var result = await db
        .delete('send_data', where: 'PIN_DATA =?', whereArgs: [pinData]);
    return result;
  }
}
