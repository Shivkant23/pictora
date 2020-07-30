import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pictora/src/model/album.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  static const String TABLE = 'pictora';
  static const String ID = 'id';
  static const String URL = 'url';
  static const String STATUS = 'status';
  static const String DB_NAME = 'pictora.db';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + DB_NAME;
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    try {
      await db.execute(
          "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT, $URL TEXT, $STATUS TEXT)");
    } catch (e) {
      print("Exception noteTable: - $e");
    }
  }

  Future<List<Album>> getAlbums() async {
    Database db = await this.database;
    List<Map> maps = await db.query(TABLE, columns: [ID, URL, STATUS]);
    List<Album> albums = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        albums.add(Album.fromJson(maps[i]));
      }
    }
    return albums;
  }

  Future<int> insertImageData(Album album) async {
    Database db = await this.database;
    var result = await db.insert(TABLE, album.toJson());
    return result;
  }

  Future<int> updateImageData(Album album) async {
    Database db = await this.database;
    var result = await db
        .update(TABLE, album.toJson(), where: '$ID = ?', whereArgs: [album.id]);
    return result;
  }

  Future<int> deleteImageData(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $TABLE WHERE $ID = $id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    print('List of table in sqflite');
    (await db.query('sqlite_master', columns: ['type', 'name'])).forEach((row) {
      print(row.values);
    });
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $TABLE');
    int result = Sqflite.firstIntValue(x);
    print(result);
    return result;
  }

  Future<void> truncateTable() async {
    Database db = await this.database;
    return await db.delete(TABLE);
  }

  Future close() async {
    Database db = await this.database;
    db.close();
  }

  Future<List<Album>> getAlbumsNotSyncServer() async {
    Database db = await this.database;
    // List<Map> maps = await db.query(TABLE, columns: [ID, URL, STATUS]);
    // print(maps);
    List<Map> maps = await db.rawQuery("SELECT * FROM $TABLE where $STATUS = 'OFFLINE'");
    
    List<Album> albums = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        albums.add(Album.fromJson(maps[i]));
      }
    }
    return albums;
  }
}