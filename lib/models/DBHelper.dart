import 'dart:async';
import 'dart:io' as io;
import 'package:alpha/models/Modules.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get fdb async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "hr.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE messages(id INTEGER , sender INTEGER, reciver INTEGER, seen INTEGER, refId INTEGER, date TEXT, descr TEXT )"); //PRIMARY KEY
  }

  void delete() async {
    var dbClient = await fdb;
    await dbClient.transaction((txn) async {
      return await txn.execute('delete from messages');
    });
  }

  void update(int sender) async {
    var dbClient = await fdb;
    await dbClient.transaction((txn) async {
      return await txn.execute(
          'UPDATE messages SET seen = \'1\' WHERE sender = \'$sender\' OR reciver = \'$sender\'');
    });
  }

  Future<List<Mssage>> getMessages() async {
    var dbClient = await fdb;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM messages');

    List<Mssage> messages = [];
    for (int i = 0; i < list.length; i++) {
      messages.add(new Mssage(
        id: int.parse('${list[i]["id"]}'),
        refId: int.parse('${list[i]["refId"]}'),
        seen: int.parse('${list[i]["seen"]}'),
        sender: int.parse('${list[i]["sender"]}'),
        reciver: int.parse('${list[i]["reciver"]}'),
        date: DateTime.parse('${list[i]["date"]}'),
        descr: '${list[i]["descr"]}',
      ));
    }
    print(messages.length);
    return messages;
  }

  Future<void> savemessage(Mssage message) async {
    var dbClient = await fdb;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO messages(id, sender, reciver, seen, refId, date, descr ) VALUES(' +
              '\'${message.id}\'        , ' +
              '\'${message.sender}\'    , ' +
              '\'${message.reciver}\'   , ' +
              '\'${message.seen}\'      , ' +
              '\'${message.refId}\'     , ' +
              '\'${message.date}\'      , ' +
              '\'${message.descr}\'       ' +
              ')');
    });
  }
}
