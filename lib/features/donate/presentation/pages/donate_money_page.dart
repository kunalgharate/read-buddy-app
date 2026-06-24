import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/donate/data/datasources/donate_remote_datasource.dart';

class DonateMoneyPage extends StatefulWidget {
  const DonateMoneyPage({super.key});

  @override
  State<DonateMoneyPage> createState() => _DonateMoneyPageState();
}

class _DonateMoneyPageState extends State<DonateMoneyPage> {
  int? _selectedAmount;
  final _customCtrl = TextEditingController();
  late final Razorpay _razorpay;
  bool _processing = false;
  String? _currentOrderId;
  int _currentAmount = 0;

  static const _presetAmounts = [100, 200, 500, 1000];

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
    _customCtrl.dispose();
    super.dispose();
  }

  int get _amount {
    if (_selectedAmount != null) return _selectedAmount!;
    final custom = int.tryParse(_customCtrl.text.trim());
    return custom ?? 0;
  }

  Future<void> _initiatePayment() async {
    final amount = _amount;
    if (amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Minimum donation is ₹100 for Prime membership')),
      );
      return;
    }

    setState(() => _processing = true);

    try {
      final datasource = getIt<DonateRemoteDataSource>();
      final result = await datasource.initiateMoneyDonation(amount);

      _currentOrderId = result['orderId'] as String;
      _currentAmount = amount;
      final razorpayKey = result['razorpayKey'] as String;

      final options = {
        'key': razorpayKey,
        'amount': (amount * 100).toString(),
        'currency': 'INR',
        'order_id': _currentOrderId,
        'name': 'ReadBuddy',
        'description': 'Donation for Prime Membership',
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
      if (mounted) {
        setState(() => _processing = false);
      }
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
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Thank You!')
              ],
            ),
            content: Text(
                'Your donation of ₹$_currentAmount was successful.\nYou are now a Prime member for 1 year! 🎉'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Continue'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Payment failed: ${response.message ?? 'Unknown error'}')),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('External wallet selected: ${response.walletName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donate Money'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support ReadBuddy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Donate ₹100 or more to become a Prime member for 1 year and unlock full access to all books.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text('Select Amount',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _presetAmounts.map((amt) {
                final selected = _selectedAmount == amt;
                return ChoiceChip(
                  label: Text('₹$amt',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : Colors.black87,
                      )),
                  selected: selected,
                  selectedColor: const Color(0xFF2CE07F),
                  onSelected: (_) => setState(() {
                    _selectedAmount = amt;
                    _customCtrl.clear();
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _customCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Or enter custom amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() => _selectedAmount = null),
            ),
            const SizedBox(height: 8),
            const Text('Minimum ₹100 required for Prime membership',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _processing ? null : _initiatePayment,
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2CE07F)),
                child: _processing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Donate ₹${_amount > 0 ? _amount : '---'}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
