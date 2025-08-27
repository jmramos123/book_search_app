import 'package:flutter/material.dart';
import '../models/book.dart';
import 'cors_safe_image.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final Widget? trailing;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildThumbnail(),
              ),
              const SizedBox(width: 12),

              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Authors
                    Text(
                      book.authorsString,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Published date
                    if (book.publishedDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Published: ${book.publishedDate}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],

                    // Categories
                    if (book.categories != null &&
                        book.categories!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.categoriesString,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Rating
                    if (book.averageRating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          Text(
                            book.averageRating!.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing widget (e.g., favorite button)
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (!book.hasThumbnail) {
      return _buildPlaceholder();
    }

    return CorsSafeImage(
      imageUrl: book.thumbnail!,
      width: 60,
      height: 80,
      fit: BoxFit.cover,
      fallbackTitle: book.title,
      placeholderBuilder: _buildPlaceholder,
    );
  }

  Widget _buildPlaceholder() {
    // Create a colored placeholder based on the book title
    final colorIndex = book.title.hashCode % 6;
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
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, color: Colors.white, size: 24),
          const SizedBox(height: 2),
          Text(
            book.title.substring(0, book.title.length > 6 ? 6 : book.title.length),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
