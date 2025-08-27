import 'package:flutter_test/flutter_test.dart';
import 'package:book_search_app/services/google_books_service.dart';

void main() {
  group('Google Books Service Tests', () {
    test('should search for books', () async {
      // Search for Flutter books
      final books = await GoogleBooksService.searchBooks('flutter');
      
      expect(books.isNotEmpty, true);
      expect(books.first.title.isNotEmpty, true);
      expect(books.first.authors.isNotEmpty, true);
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('should handle empty search query', () async {
      final books = await GoogleBooksService.searchBooks('');
      expect(books.isEmpty, true);
    });

    test('should search by author', () async {
      final books = await GoogleBooksService.searchByAuthor('J.K. Rowling');
      expect(books.isNotEmpty, true);
    }, timeout: const Timeout(Duration(seconds: 15)));
  });
}
