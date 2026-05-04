import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../data/datasources/book_request_remote_datasource.dart';
import '../bloc/my_requests_bloc.dart';
import '../pages/approved_book_request_page.dart';
import '../pages/book_request_success_page.dart';
import '../../../../core/di/injection.dart' as di;

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MyRequestsBloc>()..add(LoadMyRequests()),
      child: const _MyRequestsView(),
    );
  }
}

class _MyRequestsView extends StatelessWidget {
  const _MyRequestsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Requests',
          style: TextStyle(
            color: Color(0xFF052E44),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<MyRequestsBloc, MyRequestsState>(
        builder: (context, state) {
          if (state is MyRequestsLoading || state is MyRequestsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2CE07F)),
            );
          }
          if (state is MyRequestsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  // const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<MyRequestsBloc>().add(LoadMyRequests()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CE07F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Retry',
                        style: TextStyle(color: Color(0xFF052E44))),
                  ),
                ],
              ),
            );
          }
          if (state is MyRequestsLoaded) {
            if (state.requests.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No book requests yet.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            return _buildList(state.requests);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(List requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No book requests yet.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _RequestCard(request: requests[index]),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BookRequestEntity request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final statusLower = request.status.toLowerCase();
    final isPendingOrRequested =
        statusLower == 'requested' || statusLower == 'pending';
    final isApproved =
        statusLower == 'approved' || statusLower == 'accepted';

    VoidCallback? onTap;
    if (isPendingOrRequested) {
      onTap = () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookRequestSuccessPage(
                bookTitle: request.bookTitle ?? 'Unknown Book',
                coverImageUrl: request.bookCoverUrl ?? '',
                fromMyRequests: true,
              ),
            ),
          );
    } else if (isApproved) {
      onTap = () async {
        BookRequestEntity enriched = request;
        if (request.bookId != null && request.bookId!.isNotEmpty) {
          try {
            final ds = di.getIt<BookRequestRemoteDataSource>();
            final book = await ds.getBookById(request.bookId!);
            enriched = BookRequestEntity(
              id: request.id,
              userId: request.userId,
              status: request.status,
              fulfillmentMethod: request.fulfillmentMethod,
              paymentStatus: request.paymentStatus,
              requestDate: request.requestDate,
              dueDate: request.dueDate,
              returnDate: request.returnDate,
              bookId: book.id,
              bookTitle: book.title,
              bookCoverUrl: book.coverImageUrl,
              bookFormat: book.format,
              donorName: book.owner.name,
              bookCondition: book.condition,
            );
          } catch (_) {}
        }
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ApprovedBookRequestPage(
                request: enriched,
                initialTab: 0,
              ),
            ),
          );
        }
      };
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Column(
        children: [
          // Main content row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: request.bookCoverUrl != null &&
                          request.bookCoverUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: request.bookCoverUrl!,
                          width: 90,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _placeholder(),
                          errorWidget: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + status chip top-right
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              request.bookTitle ?? 'Unknown Book',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF052E44),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // const SizedBox(width: 8),
                          _statusChip(request.status),
                        ],
                      ),
                      // const SizedBox(height: 8),

                      // Book type (format) as plain text
                      if (request.bookFormat != null &&
                          request.bookFormat!.isNotEmpty)
                        Text(
                          _capitalize(request.bookFormat!),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF555555),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      // const SizedBox(height: 8),

                      // Donated by
                      Text(
                        request.donorName != null
                            ? 'Donated by - ${request.donorName}'
                            : 'Donated by - Unknown',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF262626),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.menu_book, color: Colors.grey, size: 36),
    );
  }

  Widget _statusChip(String status) {
    final label = _capitalize(status);
    Color bg;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        bg = const Color(0xFFE6FAF0);
        textColor = const Color(0xFF1A7A4A);
        icon = Icons.check_circle_outline;
        break;
      case 'declined':
      case 'rejected':
        bg = const Color(0xFFFFEBEB);
        textColor = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      case 'returning':
        bg = const Color(0xFFE3F2FD);
        textColor = Colors.blue;
        icon = Icons.replay_outlined;
        break;
      default:
        bg = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFB07D00);
        icon = Icons.hourglass_top_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
