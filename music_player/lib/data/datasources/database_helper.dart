import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:music_player/core/constants/app_constants.dart';
import 'package:music_player/data/models/playlist_model.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.playlistTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ${AppConstants.playlistSongsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id INTEGER NOT NULL,
        song_id INTEGER NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES ${AppConstants.playlistTable}(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<List<PlaylistModel>> getPlaylists() async {
    final db = await database;
    final maps = await db.query(AppConstants.playlistTable, orderBy: 'created_at DESC');
    return maps.map((map) => PlaylistModel.fromMap(map)).toList();
  }

  static Future<int> createPlaylist(String name) async {
    final db = await database;
    return await db.insert(AppConstants.playlistTable, {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<int> deletePlaylist(int id) async {
    final db = await database;
    await db.delete(AppConstants.playlistSongsTable, where: 'playlist_id = ?', whereArgs: [id]);
    return await db.delete(AppConstants.playlistTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> renamePlaylist(int id, String newName) async {
    final db = await database;
    return await db.update(
      AppConstants.playlistTable,
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<int>> getPlaylistSongIds(int playlistId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.playlistSongsTable,
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );
    return maps.map((m) => m['song_id'] as int).toList();
  }

  static Future<void> addSongToPlaylist(int playlistId, int songId) async {
    final db = await database;
    await db.insert(AppConstants.playlistSongsTable, {
      'playlist_id': playlistId,
      'song_id': songId,
    });
  }

  static Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    final db = await database;
    await db.delete(
      AppConstants.playlistSongsTable,
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
  }

  static Future<bool> isSongInPlaylist(int playlistId, int songId) async {
    final db = await database;
    final result = await db.query(
      AppConstants.playlistSongsTable,
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
    return result.isNotEmpty;
  }
}
