import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/book_request_entity.dart';
import 'book_order_page.dart';
import 'collect_from_library_page.dart';

class ApprovedBookRequestPage extends StatefulWidget {
  final BookRequestEntity request;
  final int initialTab;

  // initial tab 0 for book request tab and 1 for book return tab
  const ApprovedBookRequestPage({
    super.key,
    required this.request,
    this.initialTab = 0,
  });

  @override
  State<ApprovedBookRequestPage> createState() =>
      _ApprovedBookRequestPageState();
}

class _ApprovedBookRequestPageState extends State<ApprovedBookRequestPage> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2939)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Book',
          style: TextStyle(
            color: Color(0xFF1E2939),
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Tab row ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _TabRow(
              selected: _selectedTab,
              initialTab: widget.initialTab,
              onChanged: (i) => setState(() => _selectedTab = i),
            ),
          ),

          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Book info row ──────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: req.bookCoverUrl != null &&
                                req.bookCoverUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: req.bookCoverUrl!,
                                width: 110,
                                height: 150,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _coverPlaceholder(),
                                errorWidget: (_, __, ___) =>
                                    _coverPlaceholder(),
                              )
                            : _coverPlaceholder(),
                      ),
                      const SizedBox(width: 16),

                      // Text details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              req.bookTitle ?? 'Unknown Book',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2939),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Donated By ${req.donorName ?? 'Unknown'}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              req.bookFormat != null &&
                                      req.bookFormat!.isNotEmpty
                                  ? '${_capitalize(req.bookFormat!)}, Educational'
                                  : 'Educational',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Info table card ────────────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Book Conditions',
                          value: req.bookCondition != null &&
                                  req.bookCondition!.isNotEmpty
                              ? _capitalize(req.bookCondition!)
                              : 'Good',
                          showDivider: true,
                        ),
                        _InfoRow(
                          label: 'Issue Date',
                          value: _formatDate(req.requestDate),
                          showDivider: true,
                        ),
                        _InfoRow(
                          label: 'Return Date',
                          value: _formatDate(req.dueDate),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Deliver to me button ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookOrderPage(request: req),
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
                        'Deliver to me',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E2939),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Collect from library button ────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CollectFromLibraryPage(
                            request: req,
                            initialTab: 0,
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E2939),
                        side: const BorderSide(
                            color: Color(0xFFCCCCCC), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Collect from library',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E2939),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 110,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.menu_book, size: 40, color: Colors.grey),
    );
  }
}

// ─── Tab row ────────────────────────────────────────────────────────────────

class _TabRow extends StatelessWidget {
  final int selected;
  final int initialTab;
  final ValueChanged<int> onChanged;

  const _TabRow({
    required this.selected,
    required this.initialTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'Get Book',
            icon: Icons.menu_book_outlined,
            isSelected: selected == 0,
            isDisabled: initialTab != 0,
            onTap: () => onChanged(0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TabButton(
            label: 'Return Book',
            icon: Icons.menu_book_outlined,
            isSelected: selected == 1,
            isDisabled: initialTab != 1,
            onTap: () => onChanged(1),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDisabled
              ? const Color(0xFFF0F0F0)
              : isSelected
                  ? const Color(0xFF2CE07F)
                  : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDisabled
                ? const Color(0xFFE0E0E0)
                : isSelected
                    ? const Color(0xFF2CE07F)
                    : const Color(0xFFDDDDDD),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDisabled
                  ? const Color(0xFFCCCCCC)
                  : isSelected
                      ? const Color(0xFF1E2939)
                      : const Color(0xFFAAAAAA),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? const Color(0xFFCCCCCC)
                    : isSelected
                        ? const Color(0xFF1E2939)
                        : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info table row ──────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF444444),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E2939),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
      ],
    );
  }
}
