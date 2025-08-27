import 'package:flutter/material.dart';

class CorsSafeImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget Function()? placeholderBuilder;
  final String? fallbackTitle;

  const CorsSafeImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.placeholderBuilder,
    this.fallbackTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Convert HTTP to HTTPS for security
    final secureUrl = imageUrl.replaceFirst('http:', 'https:');
    
    return Image.network(
      secureUrl,
      width: width,
      height: height,
      fit: fit,
      // Silently handle errors without showing console messages
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    if (placeholderBuilder != null) {
      return placeholderBuilder!();
    }

    // Create a colored placeholder based on the fallback title or URL
    final text = fallbackTitle ?? 'Book';
    final colorIndex = text.hashCode % 6;
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
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, color: Colors.white, size: 24),
          if (fallbackTitle != null) ...[
            const SizedBox(height: 2),
            Text(
              fallbackTitle!.substring(
                0, 
                fallbackTitle!.length > 6 ? 6 : fallbackTitle!.length
              ),
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
        ],
      ),
    );
  }
}
