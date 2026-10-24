import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/core/utils/date_formatter.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:read_buddy_app/features/reviews/presentation/widgets/write_review_entry.dart';
import '../../data/datasources/book_request_remote_datasource.dart';
import '../../domain/entities/book_request_entity.dart';
import '../widgets/shipment_tracking_widget.dart';
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
      appBar: AppBar(
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
                            fontSize: 13,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                      if (widget.request.bookFormat != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _capitalize(widget.request.bookFormat!),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF555555),
                          ),
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
                widget.request.pickupAddress != null ||
                widget.request.libraryName != null) ...[
              const SizedBox(height: 4),
              if (widget.request.libraryName != null)
                _InfoRow('Pickup Library', widget.request.libraryName!),
              if (widget.request.pickupUserName != null)
                _InfoRow('Pickup Name', widget.request.pickupUserName!),
              if (widget.request.pickupPhone != null)
                _InfoRow('Phone', widget.request.pickupPhone!),
              if (widget.request.pickupAddress != null)
                _InfoRow('Pickup Address', widget.request.pickupAddress!),
            ],

            // Delivery details — original borrow delivery, hidden once a
            // return has been initiated (return details shown below instead)
            if (widget.request.deliveryAddress != null &&
                widget.request.returnMethod == null) ...[
              const SizedBox(height: 4),
              _InfoRow('Delivery Address', widget.request.deliveryAddress!),
            ],

            // Return details — driven by returnMethod (mirrors web ShowReturnDetails)
            if (widget.request.returnMethod != null) ...[
              const SizedBox(height: 16),
              const _SectionTitle('Return Details'),
              const SizedBox(height: 10),
              ..._buildReturnDetails(widget.request),
            ],

            // Shipment tracking — shown for shipping/delivered/returning
            if (['shipping', 'delivered', 'returning']
                .contains(widget.request.status.toLowerCase()))
              ShipmentTrackingWidget(requestId: widget.request.id),

            const SizedBox(height: 16),

            // Dates
            const _SectionTitle('Dates'),
            const SizedBox(height: 10),
            _InfoRow('Requested On', _fmtDate(widget.request.requestDate)),
            if (widget.request.dueDate != null)
              _InfoRow('Due Date', _fmtDate(widget.request.dueDate)),
            if (widget.request.returnDate != null)
              _InfoRow('Return Date', _fmtDate(widget.request.returnDate)),

            // Extension guidance — there is no extension endpoint, so this is
            // instructions-only and mirrors the FAQ wording.
            if (widget.request.status.toLowerCase() == 'delivered' &&
                (widget.request.dueDate ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              _ExtensionCard(
                requestId: widget.request.id,
                dueDate: widget.request.dueDate!,
              ),
            ],

            // Write a review — the widget queries the eligibility endpoint and
            // shows a 'Write a review' button when the user is eligible and
            // has not yet reviewed, or an 'Edit your review' button when a
            // review already exists. It renders nothing otherwise.
            if (widget.request.bookId != null &&
                widget.request.bookId!.isNotEmpty)
              WriteReviewEntry(bookId: widget.request.bookId!),
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
                              side: const BorderSide(
                                color: Color(0xFFCCCCCC),
                                width: 1.5,
                              ),
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

  /// Builds return detail rows based on [returnMethod].
  /// Mirrors the web ShowReturnDetails: DROP_OFF shows the drop-off branch +
  /// 'Free' payment; PICKUP shows the pickup address + real payment status.
  List<Widget> _buildReturnDetails(BookRequestEntity r) {
    final isDropOff = r.returnMethod == 'DROP_OFF';
    final rows = <Widget>[
      _InfoRow('Return Method', isDropOff ? 'Drop Off' : 'Pickup'),
      _InfoRow('Return Status', _capitalize(r.status)),
      _InfoRow('Payment Status', _returnPaymentLabel(r.returnPaymentStatus)),
    ];

    if (r.returnScheduledDate != null) {
      rows.add(_InfoRow('Scheduled Date', _fmtDate(r.returnScheduledDate)));
    }
    if (r.returnScheduledSlot != null && r.returnScheduledSlot!.isNotEmpty) {
      rows.add(_InfoRow('Time Slot', r.returnScheduledSlot!));
    }

    if (isDropOff) {
      // Show the drop-off library branch name when we have it (the branch is
      // the request's selected library), else a generic label.
      final branchName = (r.returnBranchName?.isNotEmpty == true)
          ? r.returnBranchName
          : ((r.returnBranchId == r.libraryId &&
                  r.libraryName?.isNotEmpty == true)
              ? r.libraryName
              : null);
      rows.add(
        _InfoRow(
          'Return Branch',
          (r.returnBranchId != null && r.returnBranchId!.isNotEmpty)
              ? (branchName ?? 'Library branch')
              : 'Return library branch details unavailable',
        ),
      );
    } else {
      // Home pickup — show the address submitted during the pickup payment
      // (returnPickupAddress); fall back to the older pickupDetails/address
      // mapping for legacy records.
      final pickupAddress = (r.returnPickupAddress?.isNotEmpty == true)
          ? r.returnPickupAddress
          : r.pickupAddress;
      if (pickupAddress != null && pickupAddress.isNotEmpty) {
        rows.add(_InfoRow('Pickup Address', pickupAddress));
      }
    }
    return rows;
  }

  String _returnPaymentLabel(String? status) {
    switch (status) {
      case 'PAID':
        return 'Paid';
      case 'FREE':
        return 'Free';
      default:
        return 'Pending';
    }
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
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtensionCard extends StatefulWidget {
  final String requestId;
  final String dueDate;

  const _ExtensionCard({
    required this.requestId,
    required this.dueDate,
  });

  @override
  State<_ExtensionCard> createState() => _ExtensionCardState();
}

class _ExtensionCardState extends State<_ExtensionCard> {
  bool _extending = false;
  bool _extended = false;
  String? _newDueDate;

  Future<void> _extend() async {
    if (_extending || _extended) return;
    setState(() => _extending = true);
    try {
      final ds = getIt<BookRequestRemoteDataSource>();
      await ds.extendBookRequest(widget.requestId);
      if (!mounted) return;

      final current =
          DateFormatter.parseRequestDateOnly(widget.dueDate) ?? DateTime.now();
      final updated = current.add(const Duration(days: 30));
      setState(() {
        _extended = true;
        _newDueDate =
            '${updated.year.toString().padLeft(4, '0')}-${updated.month.toString().padLeft(2, '0')}-${updated.day.toString().padLeft(2, '0')}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Due date extended by 30 days!'),
          backgroundColor: Color(0xFF2CE07F),
        ),
      );
      context.read<ProfileBloc>().add(LoadProfileEvent());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Extension request failed: ${ErrorHandler.getErrorMessage(e)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _extending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDueDate = _newDueDate ?? widget.dueDate;
    final formatted = DateFormatter.formatRequestDate(activeDueDate);
    final isDueNow = DateFormatter.isDueOnOrBeforeToday(activeDueDate);
    final message = _extended
        ? 'Your return due date has been extended to $formatted.'
        : isDueNow
            ? 'Your due date is $formatted. Need more time? Request a 30-day extension below.'
            : 'Return by $formatted. Need more time? Extensions are available below.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2CE07F).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF2CE07F).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.schedule, size: 18, color: Color(0xFF2CE07F)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF555555),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: (_extending || _extended) ? null : _extend,
              icon: _extending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2CE07F),
                      ),
                    )
                  : Icon(
                      _extended ? Icons.check : Icons.more_time,
                      size: 18,
                      color: const Color(0xFF2CE07F),
                    ),
              label: Text(
                _extended
                    ? 'Extended (+30 Days)'
                    : _extending
                        ? 'Extending…'
                        : 'Extend Due Date (+30 Days)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2CE07F),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2CE07F)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
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
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

String _fmtDate(String? s) => DateFormatter.formatRequestDate(s);
