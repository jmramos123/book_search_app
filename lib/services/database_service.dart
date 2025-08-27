import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'favorites';
  static const String _prefsKey = 'book_favorites';

  // Get database instance (only for non-web platforms)
  static Future<Database?> get database async {
    if (kIsWeb) return null; // Return null for web
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database (only for non-web platforms)
  static Future<Database> _initDatabase() async {
    if (kIsWeb) throw UnsupportedError('SQLite not supported on web');
    
    String path = join(await getDatabasesPath(), 'book_favorites.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  // Create database tables (only for non-web platforms)
  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        authors TEXT NOT NULL,
        description TEXT,
        publishedDate TEXT,
        thumbnail TEXT,
        previewLink TEXT,
        pageCount INTEGER,
        categories TEXT,
        averageRating REAL,
        language TEXT,
        dateAdded TEXT NOT NULL
      )
    ''');
  }

  // Web-compatible methods using SharedPreferences
  static Future<List<Book>> _getFavoritesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_prefsKey);
    
    if (favoritesJson == null) return [];
    
    try {
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.map((item) => Book.fromDatabase(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _saveFavoritesToPrefs(List<Book> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final String favoritesJson = json.encode(
      favorites.map((book) => book.toJson()).toList(),
    );
    await prefs.setString(_prefsKey, favoritesJson);
  }

  // Add book to favorites (works on all platforms)
  static Future<void> addToFavorites(Book book) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
      final favorites = await _getFavoritesFromPrefs();
      
      // Remove if already exists (to avoid duplicates)
      favorites.removeWhere((b) => b.id == book.id);
      
      // Add to beginning of list
      favorites.insert(0, book);
      
      await _saveFavoritesToPrefs(favorites);
    } else {
      // Mobile implementation using SQLite
      final db = await database;
      if (db == null) return;
      
      final bookData = book.toJson();
      bookData['dateAdded'] = DateTime.now().toIso8601String();
      
      await db.insert(
        _tableName,
        bookData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Remove book from favorites (works on all platforms)
  static Future<void> removeFromFavorites(String bookId) async {
    if (kIsWeb) {
      // Web implementation
      final favorites = await _getFavoritesFromPrefs();
      favorites.removeWhere((book) => book.id == bookId);
      await _saveFavoritesToPrefs(favorites);
    } else {
      // Mobile implementation
      final db = await database;
      if (db == null) return;
      
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [bookId],
      );
    }
  }

  // Get all favorite books (works on all platforms)
  static Future<List<Book>> getFavorites() async {
    if (kIsWeb) {
      // Web implementation
      return await _getFavoritesFromPrefs();
    } else {
      // Mobile implementation
      final db = await database;
      if (db == null) return [];
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'dateAdded DESC',
      );
      
      return maps.map((map) => Book.fromDatabase(map)).toList();
    }
  }

  // Check if book is in favorites (works on all platforms)
  static Future<bool> isFavorite(String bookId) async {
    if (kIsWeb) {
      // Web implementation
      final favorites = await _getFavoritesFromPrefs();
      return favorites.any((book) => book.id == bookId);
    } else {
      // Mobile implementation
      final db = await database;
      if (db == null) return false;
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [bookId],
        limit: 1,
      );
      
      return maps.isNotEmpty;
    }
  }

  // Get favorite book by ID (works on all platforms)
  static Future<Book?> getFavoriteById(String bookId) async {
    if (kIsWeb) {
      // Web implementation
      final favorites = await _getFavoritesFromPrefs();
      try {
        return favorites.firstWhere((book) => book.id == bookId);
      } catch (e) {
        return null;
      }
    } else {
      // Mobile implementation
      final db = await database;
      if (db == null) return null;
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [bookId],
        limit: 1,
      );
      
      if (maps.isEmpty) return null;
      return Book.fromDatabase(maps.first);
    }
  }

  // Clear all favorites (works on all platforms)
  static Future<void> clearFavorites() async {
    if (kIsWeb) {
      // Web implementation
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } else {
      // Mobile implementation
      final db = await database;
      if (db == null) return;
      await db.delete(_tableName);
    }
  }

  // Get favorites count (works on all platforms)
  static Future<int> getFavoritesCount() async {
    if (kIsWeb) {
      // Web implementation
      final favorites = await _getFavoritesFromPrefs();
      return favorites.length;
    } else {
      // Mobile implementation
      final db = await database;
      if (db == null) return 0;
      final count = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
      return Sqflite.firstIntValue(count) ?? 0;
    }
  }

  // Search favorites by title or author (works on all platforms)
  static Future<List<Book>> searchFavorites(String query) async {
    final favorites = await getFavorites();
    
    if (query.trim().isEmpty) return favorites;
    
    final lowercaseQuery = query.toLowerCase();
    return favorites.where((book) {
      return book.title.toLowerCase().contains(lowercaseQuery) ||
             book.authorsString.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Close database (only for non-web platforms)
  static Future<void> close() async {
    if (kIsWeb) return; // Nothing to close on web
    
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
