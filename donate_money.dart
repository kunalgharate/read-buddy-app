import 'package:flutter/material.dart';

class MoneyDonationScreen extends StatefulWidget {
  const MoneyDonationScreen({super.key});

  @override
  State<MoneyDonationScreen> createState() => _MoneyDonationScreenState();
}

class _MoneyDonationScreenState extends State<MoneyDonationScreen> {
  final TextEditingController _amountController = TextEditingController();
  double selectedAmount = 500.0; // Changed default amount to 500.0

  // Predefined quick add amounts
  final List<double> quickAmounts = [500, 1000, 1500, 2000];

  @override
  void initState() {
    super.initState();
    _amountController.text = selectedAmount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color from image
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar background color from image
        elevation: 0, // No shadow for AppBar
        centerTitle: true, // Center the title
        title: const Text(
          'Donate money',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 28, // Adjusted font size to match image
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(right: 5, top: 10),
                    child: Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 28, // Adjusted font size to match image
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  hintText: '0', // Placeholder if no initial amount
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedAmount = double.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: quickAmounts.map((amount) {
                return Expanded( // Use Expanded to distribute space evenly
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAmount = amount;
                        _amountController.text = amount.toStringAsFixed(0);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: amount == quickAmounts.last ? 0 : 10), // Add margin between buttons
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedAmount == amount ? Colors.grey[100] : Colors.white, // Greyish background for selected
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedAmount == amount ? Colors.blue[700]! : Colors.grey[300]!,
                          width: selectedAmount == amount ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        '+ ₹${amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedAmount == amount ? Colors.black87 : Colors.black87, // Text color
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, // White background as per image
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.grey, // Grey icon as per image
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can add up to ₹1999999.00', // Adjusted text as per image
                      style: TextStyle(
                        color: Colors.black87, // Darker grey text
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAmount > 0
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Add Money Confirmation'),
                            content: Text(
                                'Are you sure you want to add ₹${selectedAmount.toStringAsFixed(0)} to your wallet?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Process adding money
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '₹${selectedAmount.toStringAsFixed(0)} added to your wallet!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700], // Green button color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  elevation: 2, // Subtle shadow
                ),
                child: const Text(
                  'Donate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}