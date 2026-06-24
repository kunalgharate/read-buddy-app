import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'my_requests_page.dart';

class BookRequestSuccessPage extends StatelessWidget {
  final String bookTitle;
  final String coverImageUrl;
  final bool fromMyRequests;

  const BookRequestSuccessPage({
    super.key,
    required this.bookTitle,
    required this.coverImageUrl,
    this.fromMyRequests = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Book cover
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: coverImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: coverImageUrl,
                        width: 160,
                        height: 220,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholder(),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(height: 10),
              // Book title
              Text(
                bookTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E2939),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Success icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF2CE07F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Request Submitted!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              const Text(
                'Your book request has been created successfully. We will review and approve it within a few hours.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Go to Home button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2CE07F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // View My Book Requests button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyRequestsPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF052E44),
                    side: const BorderSide(color: Color(0xFF052E44)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View My Book Requests',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF052E44),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 160,
      height: 220,
      color: const Color(0xFFF0F0F0),
      child: const Icon(Icons.menu_book, size: 64, color: Colors.grey),
    );
  }
}
