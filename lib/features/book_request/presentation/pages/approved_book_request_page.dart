import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../profile/presentation/blocs/profile_bloc.dart';
import '../../data/datasources/book_request_remote_datasource.dart';
import '../../domain/entities/book_request_entity.dart';
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
  late final Razorpay _razorpay;
  bool _paying = false;
  bool _paid = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _paid = widget.request.paymentStatus.toUpperCase() == 'PAID' ||
        widget.request.paymentStatus.toUpperCase() == 'FREE';
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onDeliveryPaid);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onDeliveryPayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // Creates the ₹25 delivery order and opens Razorpay checkout.
  Future<void> _payDeliveryFee() async {
    setState(() => _paying = true);
    try {
      final ds = getIt<BookRequestRemoteDataSource>();
      final res = await ds.createDeliveryPaymentOrder(widget.request.id);
      final order = res['order'] as Map;
      _razorpay.open({
        'key': res['keyId'],
        'amount': order['amount'],
        'currency': order['currency'] ?? 'INR',
        'order_id': order['id'],
        'name': 'ReadBuddy',
        'description': 'Delivery Fee',
        'prefill': const {},
        'theme': {'color': '#2CE07F'},
      });
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start payment: $e')),
        );
      }
    }
  }

  Future<void> _onDeliveryPaid(PaymentSuccessResponse response) async {
    try {
      final ds = getIt<BookRequestRemoteDataSource>();
      await ds.verifyDeliveryPayment(
        widget.request.id,
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      );
      if (!mounted) return;
      setState(() {
        _paying = false;
        _paid = true;
      });
      context.read<ProfileBloc>().add(LoadProfileEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Your book will be shipped.'),
          backgroundColor: Color(0xFF2CE07F),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment verification failed: $e')),
        );
      }
    }
  }

  void _onDeliveryPayError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _paying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message ?? 'Try again'}'),
      ),
    );
  }

  // DEV/TEST ONLY: complete the ₹25 fee via the backend demo bypass (no card).
  Future<void> _payDeliveryFeeTest() async {
    setState(() => _paying = true);
    try {
      final ds = getIt<BookRequestRemoteDataSource>();
      final res = await ds.createDeliveryPaymentOrder(widget.request.id);
      final order = res['order'] as Map;
      await ds.verifyDeliveryPayment(
        widget.request.id,
        paymentId: 'pay_demo_success_99',
        orderId: order['id'] as String,
        signature: 'demo_bypass',
      );
      if (!mounted) return;
      setState(() {
        _paying = false;
        _paid = true;
      });
      context.read<ProfileBloc>().add(LoadProfileEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful! (test)')),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Test payment failed: $e')),
        );
      }
    }
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
      'December',
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
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Book',
          style: TextStyle(
            color: AppColors.textPrimary,
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
                                color: AppColors.textPrimary,
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

                  // Show action based on fulfillment method chosen during request
                  if (req.fulfillmentMethod.toUpperCase() == 'PICKUP') ...[
                    // User chose pickup — show library details
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CollectFromLibraryPage(
                              request: req,
                              initialTab: 0,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.local_library,
                          color: AppColors.textPrimary,
                        ),
                        label: const Text(
                          'View Pickup Details',
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
                  ] else ...[
                    // User chose delivery — ₹25 delivery fee (address was
                    // already provided at request time; no re-entry needed).
                    if (_paid) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2CE07F).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2CE07F)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Color(0xFF2CE07F),
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Delivery fee paid — your book will be shipped soon.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _paying ? null : _payDeliveryFee,
                          icon: _paying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.textPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.payment,
                                  color: AppColors.textPrimary,
                                ),
                          label: Text(
                            _paying ? 'Processing…' : 'Pay ₹25 Delivery Fee',
                            style: const TextStyle(
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
                      // DEV/TEST ONLY — complete the ₹25 fee without a real card.
                      if (kDebugMode ||
                          (AppConfig.isInitialized &&
                              AppConfig.instance.isDev)) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: _paying ? null : _payDeliveryFeeTest,
                            icon: const Icon(Icons.bolt, size: 18),
                            label: const Text('Pay ₹25 (TEST)'),
                          ),
                        ),
                      ],
                    ],
                  ],
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
                      ? AppColors.textPrimary
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
                        ? AppColors.textPrimary
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
                  color: AppColors.textPrimary,
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
