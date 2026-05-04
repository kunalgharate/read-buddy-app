import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/book_request_entity.dart';
import '../bloc/admin_requests_bloc.dart';

class AdminBookRequestsPage extends StatelessWidget {
  const AdminBookRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminRequestsBloc>()..add(LoadAllRequests()),
      child: const _AdminBookRequestsView(),
    );
  }
}

class _AdminBookRequestsView extends StatefulWidget {
  const _AdminBookRequestsView();

  @override
  State<_AdminBookRequestsView> createState() => _AdminBookRequestsViewState();
}

class _AdminBookRequestsViewState extends State<_AdminBookRequestsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Tab filter helpers ────────────────────────────────────────────────

  List<BookRequestEntity> _filter(List<BookRequestEntity> all, String status) =>
      all.where((r) => r.status.toLowerCase() == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Requests',
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
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Pickups'),
            Tab(text: 'Deliveries'),
            Tab(text: 'Delivered'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: BlocConsumer<AdminRequestsBloc, AdminRequestsState>(
        listener: (context, state) {
          if (state is AdminRequestActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF2CE07F),
              behavior: SnackBarBehavior.floating,
            ));
          }
          if (state is AdminRequestActionError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (context, state) {
          if (state is AdminRequestsLoading || state is AdminRequestsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2CE07F)),
            );
          }
          if (state is AdminRequestsError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<AdminRequestsBloc>().add(LoadAllRequests()),
            );
          }

          List<BookRequestEntity> all = [];
          String? actionId;

          if (state is AdminRequestsLoaded) {
            all = state.requests;
          } else if (state is AdminRequestActionLoading) {
            all = state.requests;
            actionId = state.actionId;
          } else if (state is AdminRequestActionSuccess) {
            all = state.requests;
          } else if (state is AdminRequestActionError) {
            all = state.requests;
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _GenericList(
                requests: _filter(all, 'requested'),
                actionId: actionId,
                emptyMessage: 'No pending requests',
                emptyIcon: Icons.hourglass_empty_outlined,
                onTap: (r) => _showDetailSheet(context, r, 'Pending Request'),
              ),
              _GenericList(
                requests: _filter(all, 'pickup_scheduled'),
                actionId: actionId,
                emptyMessage: 'No upcoming pickups',
                emptyIcon: Icons.event_available_outlined,
                onTap: (r) => _showDetailSheet(context, r, 'Pickup Details'),
              ),
              _GenericList(
                requests: _filter(all, 'shipping'),
                actionId: actionId,
                emptyMessage: 'No upcoming deliveries',
                emptyIcon: Icons.local_shipping_outlined,
                onTap: (r) => _showDetailSheet(context, r, 'Delivery Details'),
              ),
              _GenericList(
                requests: _filter(all, 'delivered'),
                actionId: actionId,
                emptyMessage: 'No delivered requests',
                emptyIcon: Icons.check_circle_outline,
                onTap: (r) => _showDetailSheet(context, r, 'Delivered'),
              ),
              _GenericList(
                requests: all,
                actionId: actionId,
                emptyMessage: 'No requests found',
                emptyIcon: Icons.menu_book_outlined,
                onTap: (r) => _showDetailSheet(context, r, 'Request Details'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDetailSheet(
      BuildContext context, BookRequestEntity r, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, controller) => _DetailSheet(
          request: r,
          title: title,
          scrollController: controller,
        ),
      ),
    );
  }
}

// ─── Generic list used by all tabs ────────────────────────────────────────

class _GenericList extends StatelessWidget {
  final List<BookRequestEntity> requests;
  final String? actionId;
  final String emptyMessage;
  final IconData emptyIcon;
  final void Function(BookRequestEntity) onTap;

  const _GenericList({
    required this.requests,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onTap,
    this.actionId,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return _EmptyState(message: emptyMessage, icon: emptyIcon);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _RequestCard(
        request: requests[i],
        isActioning: actionId == requests[i].id,
        onTap: () => onTap(requests[i]),
      ),
    );
  }
}

// ─── Request Card ──────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final BookRequestEntity request;
  final bool isActioning;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.isActioning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = request.status.toLowerCase() == 'requested';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverImage(url: request.bookCoverUrl, width: 80, height: 110),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name + format badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          request.userName ?? request.userId ?? 'Unknown User',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF052E44),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _FormatBadge(format: request.bookFormat ?? ''),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Book title
                  Text(
                    request.bookTitle ?? 'Unknown Book',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF444444)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (request.bookAuthor != null)
                    Text(
                      'by ${request.bookAuthor}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF888888)),
                    ),
                  const SizedBox(height: 6),
                  // Status chip + action buttons
                  if (isPending)
                    isActioning
                        ? const SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF2CE07F)),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _OutlineBtn(
                                  label: 'Decline',
                                  onTap: () => context
                                      .read<AdminRequestsBloc>()
                                      .add(DeclineRequest(request.id)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FilledBtn(
                                  label: 'Approve',
                                  onTap: () => context
                                      .read<AdminRequestsBloc>()
                                      .add(AcceptRequest(request.id)),
                                ),
                              ),
                            ],
                          )
                  else
                    Row(
                      children: [
                        _StatusChip(status: request.status),
                        const Spacer(),
                        _StatusUpdateButton(
                          requestId: request.id,
                          currentStatus: request.status,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Sheet Detail ───────────────────────────────────────────────────

class _DetailSheet extends StatelessWidget {
  final BookRequestEntity request;
  final String title;
  final ScrollController scrollController;

  const _DetailSheet({
    required this.request,
    required this.title,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF052E44),
          ),
        ),
        const SizedBox(height: 16),

        // Book row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverImage(url: request.bookCoverUrl, width: 80, height: 110),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.bookTitle ?? 'Unknown Book',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF052E44),
                    ),
                  ),
                  if (request.bookAuthor != null)
                    Text('by ${request.bookAuthor}',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF888888))),
                  if (request.bookFormat != null)
                    Text(_capitalize(request.bookFormat!),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888))),
                  if (request.bookCondition != null)
                    Text('Condition: ${_capitalize(request.bookCondition!)}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888))),
                  const SizedBox(height: 6),
                  _StatusChip(status: request.status),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(color: Color(0xFFEEEEEE)),
        const SizedBox(height: 16),

        // User details
        const Text('User Details',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF052E44))),
        const SizedBox(height: 10),
        _DetailTile(
            label: 'Name',
            value: request.userName ?? request.userId ?? '—'),

        // Pickup details — only after approved
        if (request.status.toLowerCase() != 'requested' &&
            (request.pickupUserName != null || request.pickupPhone != null)) ...[
          const SizedBox(height: 8),
          const Text('Pickup Details',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF052E44))),
          const SizedBox(height: 10),
          if (request.pickupUserName != null)
            _DetailTile(label: 'Pickup Name', value: request.pickupUserName!),
          if (request.pickupPhone != null)
            _DetailTile(label: 'Phone', value: request.pickupPhone!),
          if (request.pickupAddress != null)
            _DetailTile(label: 'Address', value: request.pickupAddress!),
        ],

        // Delivery details — only after approved
        if (request.status.toLowerCase() != 'requested' &&
            request.deliveryAddress != null) ...[
          const SizedBox(height: 8),
          const Text('Delivery Details',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF052E44))),
          const SizedBox(height: 10),
          _DetailTile(label: 'Address', value: request.deliveryAddress!),
          _DetailTile(label: 'Payment', value: request.paymentStatus),
        ],

        // Dates
        const SizedBox(height: 8),
        const Text('Dates',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF052E44))),
        const SizedBox(height: 10),
        _DetailTile(
            label: 'Request Date', value: _fmtDate(request.requestDate)),
        if (request.pickupDate != null)
          _DetailTile(
              label: 'Pickup Date', value: _fmtDate(request.pickupDate)),
        if (request.pickupTime != null)
          _DetailTile(label: 'Pickup Time', value: request.pickupTime!),
        if (request.dueDate != null)
          _DetailTile(label: 'Due Date', value: _fmtDate(request.dueDate)),
        // Return info — only relevant after delivery
        if (request.status.toLowerCase() == 'delivered' ||
            request.status.toLowerCase() == 'returning') ...[
          if (request.returnDate != null)
            _DetailTile(
                label: 'Return Date', value: _fmtDate(request.returnDate)),
          if (request.returnCondition != null)
            _DetailTile(
                label: 'Return Condition',
                value: _capitalize(request.returnCondition!)),
        ],
      ],
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────────

class _StatusUpdateButton extends StatelessWidget {
  final String requestId;
  final String currentStatus;

  const _StatusUpdateButton(
      {required this.requestId, required this.currentStatus});

  List<(String, String)> get _options {
    switch (currentStatus.toLowerCase()) {
      case 'pickup_scheduled':
        return [('delivered', 'Mark as Delivered')];
      case 'shipping':
        return [('delivered', 'Mark as Delivered')];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = _options;
    if (options.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      onSelected: (status) => context
          .read<AdminRequestsBloc>()
          .add(UpdateRequestStatus(requestId, status)),
      itemBuilder: (_) => options
          .map((o) => PopupMenuItem(
                value: o.$1,
                child: Text(o.$2,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF052E44))),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update',
                style: TextStyle(fontSize: 12, color: Color(0xFF444444))),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 16, color: Color(0xFF444444)),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF888888))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2939),
                )),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  const _CoverImage(
      {required this.url, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url != null && url!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (_, __) => _placeholder(),
              errorWidget: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.menu_book, color: Colors.grey, size: 28),
      );
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  static const _colors = {
    'approved': Color(0xFF2CE07F),
    'accepted': Color(0xFF2CE07F),
    'pickup_scheduled': Color(0xFF2196F3),
    'shipping': Color(0xFF2196F3),
    'delivered': Color(0xFF4CAF50),
    'declined': Color(0xFFFF5252),
    'rejected': Color(0xFFFF5252),
    'requested': Color(0xFFFF9800),
    'pending': Color(0xFFFF9800),
    'returning': Color(0xFF9C27B0),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status.toLowerCase()] ?? const Color(0xFF888888);
    final label = status.toLowerCase() == 'pickup_scheduled'
        ? 'Pickup Scheduled'
        : status[0].toUpperCase() + status.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  final String format;
  const _FormatBadge({required this.format});

  @override
  Widget build(BuildContext context) {
    final l = format.toLowerCase();
    final label = l.contains('ebook') || l.contains('e-book')
        ? 'E-Book'
        : l.contains('audio')
            ? 'Audio'
            : l.contains('pdf')
                ? 'PDF'
                : 'Physical';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2CE07F),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF052E44))),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF262626),
        side: const BorderSide(color: Color(0xFFCCCCCC)),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: const Size(0, 34),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF262626))),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilledBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2CE07F),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: const Size(0, 34),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF052E44))),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2CE07F),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Retry',
                style: TextStyle(color: Color(0xFF052E44))),
          ),
        ],
      ),
    );
  }
}

String _fmtDate(String? s) {
  if (s == null || s.isEmpty) return '—';
  try {
    final dt = DateTime.parse(s);
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return s;
  }
}
