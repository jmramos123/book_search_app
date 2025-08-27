import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static const int _maxResults = 20;

  // Provide the API key via --dart-define at runtime/build time.
  // Example: flutter run -d edge --dart-define=GOOGLE_BOOKS_API_KEY=ABC123
  // If none provided, _apiKey will be empty and calls will be unauthenticated.
  static const String _apiKey =
      String.fromEnvironment('GOOGLE_BOOKS_API_KEY', defaultValue: '');

  // Helper to append key when present
  static String _withKey(String url) {
    if (_apiKey.isEmpty) return url;
    // URL already contains query params in our usage, so append with '&'
    return '$url&key=$_apiKey';
  }

  // Search for books using Google Books API
  static Future<List<Book>> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final encodedQuery = Uri.encodeComponent(query);
      var url = '$_baseUrl?q=$encodedQuery&maxResults=$_maxResults';
      url = _withKey(url);

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        return items.map((item) => Book.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'Search request timed out. Please check your internet connection.',
        );
      }
      throw Exception('Failed to search books: $e');
    }
  }

  // Get book details by ID
  static Future<Book> getBookDetails(String bookId) async {
    try {
      var url = '$_baseUrl/$bookId';
      url = _withKey(url);

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception('Failed to get book details: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'Request timed out. Please check your internet connection.',
        );
      }
      throw Exception('Failed to get book details: $e');
    }
  }

  // Search books by author
  static Future<List<Book>> searchByAuthor(String author) async {
    return searchBooks('inauthor:$author');
  }

  // Search books by category
  static Future<List<Book>> searchByCategory(String category) async {
    return searchBooks('subject:$category');
  }

  // Search books by title
  static Future<List<Book>> searchByTitle(String title) async {
    return searchBooks('intitle:$title');
  }
}
