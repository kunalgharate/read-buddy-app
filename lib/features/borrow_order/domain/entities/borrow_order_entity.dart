import 'package:equatable/equatable.dart';

enum BorrowOrderStatus {
  draft,
  submitted,
  approved,
  rejected,
  cancelled,
  delivered,
  returned,
}

enum FulfillmentMethod {
  // ignore: constant_identifier_names
  DELIVERY,
  // ignore: constant_identifier_names
  PICKUP,
}

enum PaymentStatus {
  // ignore: constant_identifier_names
  PENDING,
  // ignore: constant_identifier_names
  PAID,
}

class OrderBookItem extends Equatable {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookCoverUrl;
  final double bookPrice;
  final int bookPages;
  final String status;

  const OrderBookItem({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCoverUrl,
    required this.bookPrice,
    required this.bookPages,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        bookId,
        bookTitle,
        bookAuthor,
        bookCoverUrl,
        bookPrice,
        bookPages,
        status,
      ];
}

class BorrowOrderEntity extends Equatable {
  final String id;
  final List<OrderBookItem> bookRequests;
  final double totalBookValue;
  final double budgetLimit;
  final BorrowOrderStatus status;
  final FulfillmentMethod? fulfillmentMethod;
  final String? address;
  final String? libraryId;
  final PaymentStatus paymentStatus;
  final double deliveryFee;
  final DateTime? dueDate;
  final String? rejectionReason;
  final DateTime createdAt;

  const BorrowOrderEntity({
    required this.id,
    required this.bookRequests,
    required this.totalBookValue,
    required this.budgetLimit,
    required this.status,
    this.fulfillmentMethod,
    this.address,
    this.libraryId,
    required this.paymentStatus,
    required this.deliveryFee,
    this.dueDate,
    this.rejectionReason,
    required this.createdAt,
  });

  double get remainingBudget => budgetLimit - totalBookValue;

  @override
  List<Object?> get props => [
        id,
        bookRequests,
        totalBookValue,
        budgetLimit,
        status,
        fulfillmentMethod,
        address,
        libraryId,
        paymentStatus,
        deliveryFee,
        dueDate,
        rejectionReason,
        createdAt,
      ];
}
