import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../data/datasources/book_request_remote_datasource.dart';
import '../bloc/my_requests_bloc.dart';
import '../pages/approved_book_request_page.dart';
import '../pages/book_order_page.dart';
import '../pages/book_request_success_page.dart';
import '../pages/collect_from_library_page.dart';
import '../pages/delivered_request_detail_page.dart';
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

class _MyRequestsView extends StatefulWidget {
  const _MyRequestsView();

  @override
  State<_MyRequestsView> createState() => _MyRequestsViewState();
}

class _MyRequestsViewState extends State<_MyRequestsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookRequestEntity> _pending(List<BookRequestEntity> all) => all
      .where((r) =>
          r.status.toLowerCase() != 'delivered' &&
          r.status.toLowerCase() != 'returned')
      .toList();

  List<BookRequestEntity> _completed(List<BookRequestEntity> all) => all
      .where((r) =>
          r.status.toLowerCase() == 'delivered' ||
          r.status.toLowerCase() == 'returned')
      .toList();

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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF052E44),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2CE07F),
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: BlocBuilder<MyRequestsBloc, MyRequestsState>(
        builder: (context, state) {
          if (state is MyRequestsLoading || state is MyRequestsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2CE07F)),
            );
          }
          if (state is MyRequestsCancelLoading) {
            return TabBarView(
              controller: _tabController,
              children: [
                _RequestList(
                  requests: _pending(state.requests),
                  emptyMessage: 'No pending requests',
                  cancellingId: state.cancellingId,
                ),
                _RequestList(
                  requests: _completed(state.requests),
                  emptyMessage: 'No completed requests',
                  isCompleted: true,
                ),
              ],
            );
          }
          if (state is MyRequestsErrorState) {
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
            return TabBarView(
              controller: _tabController,
              children: [
                _RequestList(
                  requests: _pending(state.requests),
                  emptyMessage: 'No pending requests',
                ),
                _RequestList(
                  requests: _completed(state.requests),
                  emptyMessage: 'No completed requests',
                  isCompleted: true,
                ),
              ],
            );
          }
          if (state is MyRequestsCancelError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            });
            return TabBarView(
              controller: _tabController,
              children: [
                _RequestList(
                  requests: _pending(state.requests),
                  emptyMessage: 'No pending requests',
                ),
                _RequestList(
                  requests: _completed(state.requests),
                  emptyMessage: 'No completed requests',
                  isCompleted: true,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<BookRequestEntity> requests;
  final String emptyMessage;
  final bool isCompleted;
  final String? cancellingId;

  const _RequestList({
    required this.requests,
    required this.emptyMessage,
    this.isCompleted = false,
    this.cancellingId,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_outline
                  : Icons.menu_book_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _RequestCard(
        request: requests[index],
        isCompleted: isCompleted,
        isCancelling: cancellingId == requests[index].id,
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BookRequestEntity request;
  final bool isCompleted;
  final bool isCancelling;

  const _RequestCard({
    required this.request,
    this.isCompleted = false,
    this.isCancelling = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusLower = request.status.toLowerCase();
    final isPendingOrRequested =
        statusLower == 'requested' || statusLower == 'pending';
    final isApproved = statusLower == 'approved' || statusLower == 'accepted';
    final canCancel = isPendingOrRequested;
    final canMarkDelivered =
        statusLower == 'pickup_scheduled' || statusLower == 'shipping';

    VoidCallback? onTap;
    if (isCompleted) {
      onTap = () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeliveredRequestDetailPage(request: request),
            ),
          );
    } else if (isPendingOrRequested) {
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
    } else if (statusLower == 'returning') {
      onTap = () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeliveredRequestDetailPage(request: request),
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
          final method = enriched.fulfillmentMethod.toLowerCase();
          if (method == 'pickup') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CollectFromLibraryPage(
                  request: enriched,
                  initialTab: 0,
                ),
              ),
            );
          } else if (method == 'dropoff' || method == 'drop_off' || method == 'delivery' || method == 'shipping') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookOrderPage(request: enriched),
              ),
            );
          } else {
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
                        // Title + status chip + cancel button
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
                            const SizedBox(width: 6),
                            _statusChip(request.status),
                          ],
                        ),
                        const SizedBox(height: 4),

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
                        if (canCancel) ...[
                          const SizedBox(height: 8),
                          isCancelling
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFFF5252),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () => _confirmCancel(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEB),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xFFFF5252)
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: const Text(
                                      'Cancel Request',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFFF5252),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                        if (canMarkDelivered) ...[
                          const SizedBox(height: 8),
                          isCancelling
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF2CE07F),
                                  ),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () => _confirmDelivered(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2CE07F),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Mark as Delivered',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF052E44),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                        if ((statusLower == 'declined' ||
                            statusLower == 'rejected')) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 13, color: Color(0xFFB07D00)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    request.rejectionReason ??
                                        'Request not approved. Contact support.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7A5800),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  void _confirmDelivered(BuildContext context) {
    final isShipping = request.status.toLowerCase() == 'shipping';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isShipping ? 'Confirm Delivery' : 'Confirm Collection'),
        content: Text(
          isShipping
              ? 'Have you received the book at your delivery address?'
              : 'Have you collected the book from the library?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Yet',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MyRequestsBloc>().add(MarkAsDelivered(request.id));
            },
            child: Text(
              isShipping ? 'Yes, Received' : 'Yes, Collected',
              style: const TextStyle(
                  color: Color(0xFF052E44), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this request?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Reason for cancellation...',
                hintStyle:
                    const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                contentPadding: const EdgeInsets.all(10),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF052E44)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(context);
              context.read<MyRequestsBloc>().add(
                    CancelRequest(request.id, reason),
                  );
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(
                    color: Color(0xFF052E44), fontWeight: FontWeight.w600)),
          ),
        ],
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
      case 'delivered':
        bg = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle_outline;
        break;
      case 'approved':
      case 'accepted':
        bg = const Color(0xFFE6FAF0);
        textColor = const Color(0xFF1A7A4A);
        icon = Icons.check_circle_outline;
        break;
      case 'declined':
      case 'rejected':
      case 'cancelled':
        bg = const Color(0xFFFFEBEB);
        textColor = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      case 'returning':
        bg = const Color(0xFFE3F2FD);
        textColor = Colors.blue;
        icon = Icons.replay_outlined;
        break;
      case 'returned':
        bg = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle_outline;
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
