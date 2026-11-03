import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../library/domain/entities/library_entity.dart'
    as library_feature;
import '../../../library/domain/usecases/library_usecases.dart';
import '../../domain/entities/book_request_entity.dart';
import 'collect_from_library_page.dart';

/// Read-only view of everything the user needs to collect an approved book:
/// which library to visit, its address/contact/hours and the scheduled pickup
/// slot. Previously the "View Pickup Details" button opened the pickup
/// scheduling form, which hid the actual details and looked like a wrong screen.
class PickupDetailsPage extends StatefulWidget {
  final BookRequestEntity request;

  const PickupDetailsPage({super.key, required this.request});

  @override
  State<PickupDetailsPage> createState() => _PickupDetailsPageState();
}

class _PickupDetailsPageState extends State<PickupDetailsPage> {
  bool _loading = false;
  library_feature.LibraryEntity? _library;
  bool _libraryLoadFailed = false;

  bool get _hasScheduledPickup =>
      (widget.request.pickupDate ?? '').trim().isNotEmpty ||
      (widget.request.pickupTime ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    final id = widget.request.libraryId;
    if (id == null || id.isEmpty) return;

    setState(() {
      _loading = true;
      _libraryLoadFailed = false;
    });

    try {
      final library = await getIt<GetLibraryById>()(id);
      if (!mounted) return;
      setState(() {
        _library = library;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _libraryLoadFailed = true;
        _loading = false;
      });
    }
  }

  void _openScheduling() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CollectFromLibraryPage(request: widget.request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final libraryName = _library?.name ??
        (request.libraryName?.trim().isNotEmpty == true
            ? request.libraryName!.trim()
            : null);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pickup Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bookHeader(request),
            const SizedBox(height: 20),

            // ── Library ──────────────────────────────────────────────────
            _sectionTitle('Pickup Library'),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              _libraryCard(request, libraryName),
            if (_libraryLoadFailed)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Could not load the full library details.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadLibrary,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ── Schedule ─────────────────────────────────────────────────
            _sectionTitle('Pickup Schedule'),
            const SizedBox(height: 10),
            _InfoCard(
              children: [
                _InfoRow(
                  label: 'Date',
                  value: _formatDate(request.pickupDate) ??
                      (_hasScheduledPickup ? '—' : 'Not scheduled yet'),
                ),
                if ((request.pickupTime ?? '').trim().isNotEmpty)
                  _InfoRow(label: 'Time', value: request.pickupTime!.trim()),
                _InfoRow(
                  label: 'Status',
                  value: _capitalize(request.status),
                ),
                if (_hasScheduledPickup)
                  const _InfoRow(
                    label: 'Note',
                    value: 'Show this request at the library counter.',
                  ),
              ],
            ),

            // ── Contact person ───────────────────────────────────────────
            if ((request.pickupUserName ?? '').trim().isNotEmpty ||
                (request.pickupPhone ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('Pickup Contact'),
              const SizedBox(height: 10),
              _InfoCard(
                children: [
                  if ((request.pickupUserName ?? '').trim().isNotEmpty)
                    _InfoRow(
                      label: 'Name',
                      value: request.pickupUserName!.trim(),
                    ),
                  if ((request.pickupPhone ?? '').trim().isNotEmpty)
                    _InfoRow(
                      label: 'Phone',
                      value: request.pickupPhone!.trim(),
                    ),
                ],
              ),
            ],

            if (!_hasScheduledPickup) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _openScheduling,
                  icon: const Icon(
                    Icons.schedule,
                    color: AppColors.textPrimary,
                  ),
                  label: const Text(
                    'Schedule Pickup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2CE07F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Pieces ──────────────────────────────────────────────────────────────

  Widget _bookHeader(BookRequestEntity request) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              request.bookCoverUrl != null && request.bookCoverUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: request.bookCoverUrl!,
                      width: 80,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _coverPlaceholder(),
                      errorWidget: (_, __, ___) => _coverPlaceholder(),
                    )
                  : _coverPlaceholder(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.bookTitle ?? 'Unknown Book',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              if ((request.bookAuthor ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'by ${request.bookAuthor!.trim()}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2CE07F).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2CE07F).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  _capitalize(request.status),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2CE07F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _libraryCard(BookRequestEntity request, String? libraryName) {
    final library = _library;
    if (library == null && libraryName == null) {
      final pickupAddress = (request.pickupAddress ?? '').trim();
      if (pickupAddress.isEmpty) {
        return const _InfoCard(
          children: [
            _InfoRow(
              label: 'Library',
              value: 'Library details unavailable',
            ),
          ],
        );
      }
      return _InfoCard(
        children: [
          const _InfoRow(label: 'Library', value: 'Pickup location'),
          _InfoRow(label: 'Address', value: pickupAddress),
        ],
      );
    }

    return _InfoCard(
      children: [
        _InfoRow(label: 'Name', value: libraryName ?? 'Library'),
        if (library != null && library.address.fullAddress.trim().isNotEmpty)
          _InfoRow(label: 'Address', value: library.address.fullAddress),
        if (library != null && library.contactNumber.trim().isNotEmpty)
          _InfoRow(label: 'Phone', value: library.contactNumber.trim()),
        if (library != null && library.openHours.trim().isNotEmpty)
          _InfoRow(label: 'Hours', value: library.openHours.trim()),
        if (library == null && (request.pickupAddress ?? '').trim().isNotEmpty)
          _InfoRow(label: 'Address', value: request.pickupAddress!.trim()),
      ],
    );
  }

  Widget _coverPlaceholder() => Container(
        width: 80,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.menu_book, color: Colors.grey, size: 30),
      );

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E2939),
        ),
      );

  String? _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return raw.trim();
    final date = raw.trim().endsWith('Z') ? parsed.toUtc() : parsed;
    const months = [
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
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
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
