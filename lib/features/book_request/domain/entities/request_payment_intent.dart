/// Payment intent returned by the backend when initiating the ₹25 delivery
/// fee for a book request. `amount` is in paise, matching the Razorpay SDK
/// expectation (e.g. 2500 paise = ₹25).
class RequestPaymentIntent {
  final String razorpayKey;
  final String orderId;
  final int amount;
  final String currency;
  final String bookRequestId;

  const RequestPaymentIntent({
    required this.razorpayKey,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.bookRequestId,
  });
}