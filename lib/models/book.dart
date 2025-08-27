class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String? description;
  final String? publishedDate;
  final String? thumbnail;
  final String? previewLink;
  final int? pageCount;
  final List<String>? categories;
  final double? averageRating;
  final String? language;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.description,
    this.publishedDate,
    this.thumbnail,
    this.previewLink,
    this.pageCount,
    this.categories,
    this.averageRating,
    this.language,
  });

  // Factory constructor to create Book from Google Books API JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};

    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Unknown Title',
      authors: List<String>.from(volumeInfo['authors'] ?? ['Unknown Author']),
      description: volumeInfo['description'],
      publishedDate: volumeInfo['publishedDate'],
      thumbnail: volumeInfo['imageLinks']?['thumbnail'],
      previewLink: volumeInfo['previewLink'],
      pageCount: volumeInfo['pageCount'],
      categories: volumeInfo['categories'] != null
          ? List<String>.from(volumeInfo['categories'])
          : null,
      averageRating: volumeInfo['averageRating']?.toDouble(),
      language: volumeInfo['language'],
    );
  }

  // Convert Book to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors.join(', '),
      'description': description,
      'publishedDate': publishedDate,
      'thumbnail': thumbnail,
      'previewLink': previewLink,
      'pageCount': pageCount,
      'categories': categories?.join(', '),
      'averageRating': averageRating,
      'language': language,
    };
  }

  // Factory constructor to create Book from database JSON
  factory Book.fromDatabase(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      authors: json['authors']?.split(', ') ?? ['Unknown Author'],
      description: json['description'],
      publishedDate: json['publishedDate'],
      thumbnail: json['thumbnail'],
      previewLink: json['previewLink'],
      pageCount: json['pageCount'],
      categories: json['categories']?.split(', '),
      averageRating: json['averageRating']?.toDouble(),
      language: json['language'],
    );
  }

  // Get formatted authors string
  String get authorsString => authors.join(', ');

  // Get formatted categories string
  String get categoriesString => categories?.join(', ') ?? '';

  // Check if book has thumbnail
  bool get hasThumbnail => thumbnail != null && thumbnail!.isNotEmpty;

  // Get CORS-safe thumbnail URL for web browsers
  String? get safeThumbnail {
    if (thumbnail == null) return null;
    
    // Convert HTTP to HTTPS for security
    return thumbnail!.replaceFirst('http:', 'https:');
  }

  // Get alternative thumbnail URL without CORS proxy
  String? get directThumbnail {
    if (thumbnail == null) return null;
    return thumbnail!.replaceFirst('http:', 'https:');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
