import '../../domain/entities/book_request_entity.dart';

class BookRequestModel extends BookRequestEntity {
  const BookRequestModel({
    required super.id,
    super.userId,
    required super.status,
    required super.fulfillmentMethod,
    required super.paymentStatus,
    required super.requestDate,
    super.dueDate,
    super.returnDate,
    super.returnPaymentStatus,
    super.returnCondition,
    super.bookId,
    super.bookTitle,
    super.bookAuthor,
    super.bookCoverUrl,
    super.bookFormat,
    super.donorName,
    super.userName,
    super.bookCondition,
    super.deliveryAddress,
    super.deliveryName,
    super.deliveryPhone,
    super.deliveryPincode,
    super.deliveryPreferredDate,
    super.deliveryPreferredTime,
    super.userEmail,
    super.pickupUserName,
    super.pickupPhone,
    super.pickupAddress,
    super.pickupDate,
    super.pickupTime,
    super.rejectionReason,
  });

  factory BookRequestModel.fromJson(Map<String, dynamic> json) {
    // bookId can be null, a plain String id, or a populated Map
    final book = json['bookId'] is Map<String, dynamic>
        ? json['bookId'] as Map<String, dynamic>
        : null;

    // userId can be a plain String or a populated Map
    final userObj = json['userId'] is Map<String, dynamic>
        ? json['userId'] as Map<String, dynamic>
        : null;

    // donorId can be null, a plain String, or a populated Map
    final donorObj = json['donorId'] is Map<String, dynamic>
        ? json['donorId'] as Map<String, dynamic>
        : null;

    // pickupDetails nested object from schedule-pickup response
    final pickupDetails = json['pickupDetails'] is Map<String, dynamic>
        ? json['pickupDetails'] as Map<String, dynamic>
        : null;

    // deliveryDetails nested object from schedule-delivery response
    final deliveryDetails = json['deliveryDetails'] is Map<String, dynamic>
        ? json['deliveryDetails'] as Map<String, dynamic>
        : null;

    return BookRequestModel(
      id: json['_id'] ?? '',
      userId:
          userObj?['_id'] ?? (json['userId'] is String ? json['userId'] : null),
      status: json['status'] ?? '',
      fulfillmentMethod: json['fulfillmentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      // new API uses createdAt, old used requestDate
      requestDate: json['requestDate'] ?? json['createdAt'] ?? '',
      dueDate: json['dueDate'],
      returnDate: json['returnDate'],
      returnPaymentStatus: json['returnPaymentStatus'],
      returnCondition: json['returnCondition'],
      // book fields — only populated when bookId is a full object
      bookId:
          book?['_id'] ?? (json['bookId'] is String ? json['bookId'] : null),
      bookTitle: book?['title'],
      bookAuthor: book?['author'],
      bookCoverUrl: book?['coverImageUrl'],
      bookFormat: book?['format'],
      bookCondition: book?['condition'],
      donorName: donorObj?['name'],
      userName: userObj?['name'],
      userEmail: userObj?['email'],
      deliveryAddress:
          json['address'] is String ? json['address'] as String : null,
      deliveryName: deliveryDetails?['name'],
      deliveryPhone: deliveryDetails?['phone'],
      deliveryPincode: deliveryDetails?['pincode'],
      deliveryPreferredDate: deliveryDetails?['preferredDate'],
      deliveryPreferredTime: deliveryDetails?['preferredTime'],
      // pickup fields — from pickupDetails object or root level
      pickupUserName: pickupDetails?['userName'] ?? json['userName'],
      pickupPhone: pickupDetails?['phoneNumber'] ?? json['phoneNumber'],
      pickupAddress: pickupDetails?['address'] ?? json['address'],
      pickupDate: pickupDetails?['pickupDate'] ?? json['pickupDate'],
      pickupTime: pickupDetails?['pickupTime'] ?? json['pickupTime'],
      rejectionReason: json['rejectionReason'] ?? json['reason'],
    );
  }
}
