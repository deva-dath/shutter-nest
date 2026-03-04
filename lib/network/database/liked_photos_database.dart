import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';

const String _tableLikedPhotos = 'liked_photos';
const String _columnId = 'id';
const String _columnPhotoJson = 'photo_json';

/// SQLite database for liked photos. One table: id (PK), photo_json.
class LikedPhotosDatabase {
  LikedPhotosDatabase._();
  static final LikedPhotosDatabase instance = LikedPhotosDatabase._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shutter_nest_liked.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableLikedPhotos (
            $_columnId TEXT PRIMARY KEY,
            $_columnPhotoJson TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertPhoto(UnsplashPhoto photo) async {
    final db = await database;
    await db.insert(
      _tableLikedPhotos,
      {
        _columnId: photo.id,
        _columnPhotoJson: jsonEncode(photo.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removePhoto(String id) async {
    final db = await database;
    await db.delete(_tableLikedPhotos, where: '$_columnId = ?', whereArgs: [id]);
  }

  Future<List<UnsplashPhoto>> getAllPhotos() async {
    final db = await database;
    final rows = await db.query(_tableLikedPhotos, orderBy: '$_columnId ASC');
    final list = <UnsplashPhoto>[];
    for (final row in rows) {
      try {
        final json = jsonDecode(row[_columnPhotoJson] as String) as Map<String, dynamic>;
        list.add(UnsplashPhoto.fromJson(json));
      } catch (_) {
        // Skip malformed row
      }
    }
    return list;
  }

  Future<bool> isLiked(String id) async {
    final db = await database;
    final rows = await db.query(
      _tableLikedPhotos,
      columns: [_columnId],
      where: '$_columnId = ?',
      whereArgs: [id],
    );
    return rows.isNotEmpty;
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
