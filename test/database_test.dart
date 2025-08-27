import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:book_search_app/models/book.dart';
import 'package:book_search_app/services/database_service.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Service Tests', () {
    late Book testBook;

    setUp(() {
      testBook = Book(
        id: 'test_book_1',
        title: 'Test Book',
        authors: ['Test Author'],
        description: 'A test book for testing purposes',
        publishedDate: '2024',
        thumbnail: 'https://example.com/thumbnail.jpg',
      );
    });

    test('should add book to favorites', () async {
      // Add book to favorites
      await DatabaseService.addToFavorites(testBook);

      // Check if book is in favorites
      final isFavorite = await DatabaseService.isFavorite(testBook.id);
      expect(isFavorite, true);

      // Clean up
      await DatabaseService.removeFromFavorites(testBook.id);
    });

    test('should remove book from favorites', () async {
      // Add book first
      await DatabaseService.addToFavorites(testBook);

      // Remove book
      await DatabaseService.removeFromFavorites(testBook.id);

      // Check if book is removed
      final isFavorite = await DatabaseService.isFavorite(testBook.id);
      expect(isFavorite, false);
    });

    test('should get all favorites', () async {
      // Add book to favorites
      await DatabaseService.addToFavorites(testBook);

      // Get all favorites
      final favorites = await DatabaseService.getFavorites();
      expect(favorites.isNotEmpty, true);
      expect(favorites.any((book) => book.id == testBook.id), true);

      // Clean up
      await DatabaseService.clearFavorites();
    });

    test('should search favorites', () async {
      // Add book to favorites
      await DatabaseService.addToFavorites(testBook);

      // Search for the book
      final searchResults = await DatabaseService.searchFavorites('Test');
      expect(searchResults.isNotEmpty, true);
      expect(searchResults.first.title, testBook.title);

      // Clean up
      await DatabaseService.clearFavorites();
    });
  });
}
