import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/donate/data/datasources/donate_remote_datasource.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';

class DonateMoneyPage extends StatefulWidget {
  const DonateMoneyPage({super.key});

  @override
  State<DonateMoneyPage> createState() => _DonateMoneyPageState();
}

class _DonateMoneyPageState extends State<DonateMoneyPage> {
  int _selectedPlan = 100; // default ₹100/year
  late final Razorpay _razorpay;
  bool _processing = false;
  String? _currentOrderId;
  int _currentAmount = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    setState(() => _processing = true);

    try {
      final datasource = getIt<DonateRemoteDataSource>();
      final result = await datasource.initiateMoneyDonation(_selectedPlan);

      _currentOrderId = result['orderId'] as String;
      _currentAmount = _selectedPlan;
      final razorpayKey = result['razorpayKey'] as String;

      final options = {
        'key': razorpayKey,
        'amount': (_selectedPlan * 100).toString(), // paise
        'currency': 'INR',
        'order_id': _currentOrderId,
        'name': 'ReadBuddy',
        'description': 'Prime Membership - 1 Year',
        'prefill': {},
        'theme': {'color': '#2CE07F'},
      };

      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initiate payment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final datasource = getIt<DonateRemoteDataSource>();
      await datasource.verifyMoneyDonation(
        razorpayOrderId: response.orderId ?? _currentOrderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        amount: _currentAmount,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 28),
                SizedBox(width: 8),
                Expanded(child: Text('Welcome to Prime! 🎉')),
              ],
            ),
            content: const Text(
              'Your Prime Membership is now active for 1 year.\n\n'
              'You now have full access to:\n'
              '• Borrow physical books\n'
              '• Read eBooks\n'
              '• Listen to Audiobooks\n'
              '• Watch Videobooks\n\n'
              'Thank you for supporting ReadBuddy!',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  // Refresh profile so home screen knows user is now Prime
                  context.read<ProfileBloc>().add(LoadProfileEvent());
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Start Exploring'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment verification failed: $e')),
        );
      }
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Payment failed: ${response.message ?? 'Please try again'}'),
      ),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet: ${response.walletName}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Prime'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade600,
                    Colors.amber.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'ReadBuddy Prime',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Unlock full access to borrow, read, listen & watch',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Benefits
            const Text(
              'Prime Benefits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _benefitRow(
                Icons.menu_book, 'Borrow physical books from libraries'),
            _benefitRow(Icons.chrome_reader_mode, 'Read eBooks (PDF & EPUB)'),
            _benefitRow(Icons.headphones, 'Listen to Audiobooks'),
            _benefitRow(Icons.play_circle, 'Watch Videobooks'),
            _benefitRow(Icons.all_inclusive, 'Unlimited access for 1 year'),
            const SizedBox(height: 24),

            // How to get Prime
            const Text(
              'How to Get Prime',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📚 Option 1: Donate a Book',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Donate any book to our library network. Once approved by admin, you get Prime for free!',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '💳 Option 2: Buy Membership',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Purchase Prime Membership starting at ₹100/year and get instant access.',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pricing
            const Text(
              'Select Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _planCard(100, '1 Year', 'Best value for readers', true),
            const SizedBox(height: 32),

            // Buy button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _processing ? null : _initiatePayment,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _processing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Buy Prime — ₹$_selectedPlan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Terms and pricing note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: AppColors.textHint),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Important Information',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• This is a membership purchase, not a donation.\n'
                    '• Membership is valid for 1 year from the date of purchase.\n'
                    '• Pricing is introductory and may be revised in future years.\n'
                    '• No auto-renewal — you choose to renew manually.\n'
                    '• Refund policy as per ReadBuddy terms of service.\n'
                    '• Payment processed securely via Razorpay.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard(int price, String duration, String subtitle, bool selected) {
    return InkWell(
      onTap: () => setState(() => _selectedPlan = price),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.amber.shade700 : AppColors.border,
            width: selected ? 2 : 1,
          ),
          color: selected ? Colors.amber.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.star, color: Colors.amber.shade700),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    duration,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₹$price',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
