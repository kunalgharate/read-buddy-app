import '../../domain/entities/borrow_order_entity.dart';

class OrderBookItemModel extends OrderBookItem {
  const OrderBookItemModel({
    required super.id,
    required super.bookId,
    required super.bookTitle,
    required super.bookAuthor,
    required super.bookCoverUrl,
    required super.bookPrice,
    required super.bookPages,
    required super.status,
  });

  factory OrderBookItemModel.fromJson(Map<String, dynamic> json) {
    // Each order item is a BookRequest doc whose `bookId` is populated to a
    // book object { _id, title, author, coverImageUrl, price, pages }. Read the
    // book fields from that nested object, falling back to any flat fields for
    // backward compatibility.
    final book = json['bookId'] is Map<String, dynamic>
        ? json['bookId'] as Map<String, dynamic>
        : null;

    final rawPrice = book?['price'] ?? json['bookPrice'] ?? 0;
    final rawPages = book?['pages'] ?? json['bookPages'] ?? 0;

    return OrderBookItemModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      bookId: book?['_id']?.toString() ??
          (json['bookId'] is String ? json['bookId'] as String : ''),
      bookTitle:
          (book?['title'] ?? json['bookTitle'])?.toString() ?? 'Unknown Book',
      bookAuthor: (book?['author'] ?? json['bookAuthor'])?.toString() ?? '',
      bookCoverUrl:
          (book?['coverImageUrl'] ?? json['bookCoverUrl'])?.toString() ?? '',
      bookPrice: (rawPrice is num)
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice.toString()) ?? 0,
      bookPages:
          rawPages is int ? rawPages : int.tryParse(rawPages.toString()) ?? 0,
      status: json['status']?.toString() ?? 'pending',
    );
  }

  /// Build a model from a plain domain entity (used for safe serialization).
  factory OrderBookItemModel.fromEntity(OrderBookItem entity) {
    return OrderBookItemModel(
      id: entity.id,
      bookId: entity.bookId,
      bookTitle: entity.bookTitle,
      bookAuthor: entity.bookAuthor,
      bookCoverUrl: entity.bookCoverUrl,
      bookPrice: entity.bookPrice,
      bookPages: entity.bookPages,
      status: entity.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'bookTitle': bookTitle,
        'bookAuthor': bookAuthor,
        'bookCoverUrl': bookCoverUrl,
        'bookPrice': bookPrice,
        'bookPages': bookPages,
        'status': status,
      };
}

class BorrowOrderModel extends BorrowOrderEntity {
  const BorrowOrderModel({
    required super.id,
    required super.bookRequests,
    required super.totalBookValue,
    required super.budgetLimit,
    required super.status,
    super.fulfillmentMethod,
    super.address,
    super.libraryId,
    required super.paymentStatus,
    required super.deliveryFee,
    super.dueDate,
    super.rejectionReason,
    required super.createdAt,
  });

  factory BorrowOrderModel.fromJson(Map<String, dynamic> json) {
    final bookRequestsList = (json['bookRequests'] as List? ?? [])
        .map(
          (item) => OrderBookItemModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return BorrowOrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      bookRequests: bookRequestsList,
      totalBookValue: (json['totalBookValue'] ?? 0).toDouble(),
      budgetLimit: (json['budgetLimit'] ?? 500).toDouble(),
      status: _parseStatus(json['status']?.toString() ?? 'draft'),
      fulfillmentMethod:
          _parseFulfillmentMethod(json['fulfillmentMethod']?.toString()),
      address: json['address']?.toString(),
      libraryId: json['libraryId']?.toString(),
      paymentStatus:
          _parsePaymentStatus(json['paymentStatus']?.toString() ?? 'PENDING'),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      rejectionReason: json['rejectionReason']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static BorrowOrderStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return BorrowOrderStatus.draft;
      case 'submitted':
        return BorrowOrderStatus.submitted;
      case 'approved':
        return BorrowOrderStatus.approved;
      case 'rejected':
        return BorrowOrderStatus.rejected;
      case 'cancelled':
        return BorrowOrderStatus.cancelled;
      case 'delivered':
        return BorrowOrderStatus.delivered;
      case 'returned':
        return BorrowOrderStatus.returned;
      default:
        return BorrowOrderStatus.draft;
    }
  }

  static FulfillmentMethod? _parseFulfillmentMethod(String? method) {
    if (method == null) return null;
    switch (method.toUpperCase()) {
      case 'DELIVERY':
        return FulfillmentMethod.DELIVERY;
      case 'PICKUP':
        return FulfillmentMethod.PICKUP;
      default:
        return null;
    }
  }

  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return PaymentStatus.PAID;
      default:
        return PaymentStatus.PENDING;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookRequests': bookRequests
            .map(
              (item) => item is OrderBookItemModel
                  ? item.toJson()
                  : OrderBookItemModel.fromEntity(item).toJson(),
            )
            .toList(),
        'totalBookValue': totalBookValue,
        'budgetLimit': budgetLimit,
        'status': status.name,
        'fulfillmentMethod': fulfillmentMethod?.name,
        'address': address,
        'libraryId': libraryId,
        'paymentStatus': paymentStatus.name,
        'deliveryFee': deliveryFee,
        'dueDate': dueDate?.toIso8601String(),
        'rejectionReason': rejectionReason,
        'createdAt': createdAt.toIso8601String(),
      };
}
