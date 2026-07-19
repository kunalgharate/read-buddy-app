import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/book_request_entity.dart';
import 'collect_from_library_page.dart';

class DeliveredRequestDetailPage extends StatefulWidget {
  final BookRequestEntity request;

  const DeliveredRequestDetailPage({super.key, required this.request});

  @override
  State<DeliveredRequestDetailPage> createState() =>
      _DeliveredRequestDetailPageState();
}

class _DeliveredRequestDetailPageState
    extends State<DeliveredRequestDetailPage> {
  bool _showReturnOptions = false;

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
          'Book Details',
          style: TextStyle(
            color: Color(0xFF052E44),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover + basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.request.bookCoverUrl != null &&
                          widget.request.bookCoverUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.request.bookCoverUrl!,
                          width: 100,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _coverPlaceholder(),
                          errorWidget: (_, __, ___) => _coverPlaceholder(),
                        )
                      : _coverPlaceholder(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.request.bookTitle ?? 'Unknown Book',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF052E44),
                          height: 1.3,
                        ),
                      ),
                      if (widget.request.bookAuthor != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'by ${widget.request.bookAuthor}',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF888888)),
                        ),
                      ],
                      if (widget.request.bookFormat != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _capitalize(widget.request.bookFormat!),
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF555555)),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _StatusChip(status: widget.request.status),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            // Book info
            const _SectionTitle('Book Info'),
            const SizedBox(height: 10),
            if (widget.request.donorName != null)
              _InfoRow('Donated By', widget.request.donorName!),
            if (widget.request.bookCondition != null)
              _InfoRow('Condition', _capitalize(widget.request.bookCondition!)),

            const SizedBox(height: 16),

            // Fulfillment info
            const _SectionTitle('Fulfillment'),
            const SizedBox(height: 10),
            _InfoRow(
              'Method',
              widget.request.fulfillmentMethod.isNotEmpty
                  ? _capitalize(widget.request.fulfillmentMethod)
                  : '—',
            ),

            // Pickup details
            if (widget.request.pickupUserName != null ||
                widget.request.pickupAddress != null) ...[
              const SizedBox(height: 4),
              if (widget.request.pickupUserName != null)
                _InfoRow('Pickup Name', widget.request.pickupUserName!),
              if (widget.request.pickupPhone != null)
                _InfoRow('Phone', widget.request.pickupPhone!),
              if (widget.request.pickupAddress != null)
                _InfoRow('Pickup Address', widget.request.pickupAddress!),
            ],

            // Delivery details
            if (widget.request.deliveryAddress != null) ...[
              const SizedBox(height: 4),
              _InfoRow('Delivery Address', widget.request.deliveryAddress!),
            ],

            const SizedBox(height: 16),

            // Dates
            const _SectionTitle('Dates'),
            const SizedBox(height: 10),
            _InfoRow('Requested On', _fmtDate(widget.request.requestDate)),
            if (widget.request.dueDate != null)
              _InfoRow('Due Date', _fmtDate(widget.request.dueDate)),
            if (widget.request.returnDate != null)
              _InfoRow('Return Date', _fmtDate(widget.request.returnDate)),
          ],
        ),
      ),
      bottomNavigationBar: widget.request.status.toLowerCase() == 'delivered'
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _showReturnOptions
                    ? [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CollectFromLibraryPage(
                                  request: widget.request,
                                  initialTab: 1,
                                  isReturn: true,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2CE07F),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Drop at Library',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF052E44),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CollectFromLibraryPage(
                                  request: widget.request,
                                  initialTab: 0,
                                  isReturn: true,
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF052E44),
                              side: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Schedule Home Pickup',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF052E44),
                              ),
                            ),
                          ),
                        ),
                      ]
                    : [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _showReturnOptions = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2CE07F),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Return the Book',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF052E44),
                              ),
                            ),
                          ),
                        ),
                      ],
              ),
            )
          : null,
    );
  }

  Widget _coverPlaceholder() => Container(
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.menu_book, color: Colors.grey, size: 36),
      );

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF052E44),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'returned':
        color = const Color(0xFF4CAF50);
        break;
      case 'returning':
        color = Colors.blue;
        break;
      default:
        color = const Color(0xFF4CAF50);
    }
    final label = status.toLowerCase() == 'pickup_scheduled'
        ? 'Pickup Scheduled'
        : status[0].toUpperCase() + status.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

String _fmtDate(String? s) {
  if (s == null || s.isEmpty) return '—';
  try {
    final dt = DateTime.parse(s);
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return s;
  }
}
