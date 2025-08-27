import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../widgets/cors_safe_image.dart';
import 'package:flutter/foundation.dart';


class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final isFavorite = await DatabaseService.isFavorite(widget.book.id);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        await DatabaseService.removeFromFavorites(widget.book.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        await DatabaseService.addToFavorites(widget.book);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _toggleFavorite,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book header with image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildBookCover(),
                ),
                const SizedBox(width: 16),

                // Basic info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.book.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Authors
                      Text(
                        'By ${widget.book.authorsString}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),

                      // Published date
                      if (widget.book.publishedDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.book.publishedDate!,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],

                      // Page count
                      if (widget.book.pageCount != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.book, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.book.pageCount} pages',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],

                      // Rating
                      if (widget.book.averageRating != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < widget.book.averageRating!.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              widget.book.averageRating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Categories
            if (widget.book.categories != null &&
                widget.book.categories!.isNotEmpty) ...[
              Text(
                'Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.book.categories!.map((category) {
                  return Chip(
                    label: Text(category, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.blue[50],
                    side: BorderSide(color: Colors.blue[200]!),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Description
            if (widget.book.description != null &&
                widget.book.description!.isNotEmpty) ...[
              Text(
                'Description',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.book.description!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Additional info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (widget.book.language != null) ...[
                      _buildInfoRow(
                        'Language',
                        widget.book.language!.toUpperCase(),
                      ),
                    ],

                    _buildInfoRow('Book ID', widget.book.id),

                    if (widget.book.previewLink != null) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Open preview link in browser
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Preview link feature coming soon!',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.preview),
                        label: const Text('Preview Book'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Favorite button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleFavorite,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.white : null,
                      ),
                label: Text(
                  _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFavorite ? Colors.red : null,
                  foregroundColor: _isFavorite ? Colors.white : null,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCover() {
    if (!widget.book.hasThumbnail) {
      return _buildPlaceholder();
    }

    String imageUrl = widget.book.thumbnail!;

    // Same fix you used in BookCard
    if (kIsWeb && imageUrl.contains('books.google.com')) {
      final encoded = Uri.encodeComponent(imageUrl);
      imageUrl = 'https://calm-night-e9ec.rangulegamer.workers.dev/?url=$encoded';
    }

    return CorsSafeImage(
      imageUrl: imageUrl,
      width: 120,
      height: 160,
      fit: BoxFit.cover,
      fallbackTitle: widget.book.title,
      placeholderBuilder: _buildPlaceholder,
    );
  }

  Widget _buildPlaceholder() {
    // Create a colored placeholder based on the book title
    final colorIndex = widget.book.title.hashCode % 6;
    final colors = [
      Colors.red[300]!,
      Colors.teal[300]!,
      Colors.blue[300]!,
      Colors.orange[300]!,
      Colors.green[300]!,
      Colors.amber[300]!,
    ];
    final color = colors[colorIndex];

    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.book.title.length > 15
                  ? '${widget.book.title.substring(0, 15)}...'
                  : widget.book.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
