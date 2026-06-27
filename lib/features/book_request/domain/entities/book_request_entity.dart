import 'package:equatable/equatable.dart';

class BookRequestEntity extends Equatable {
  final String id;
  final String? userId;
  final String status;
  final String fulfillmentMethod;
  final String paymentStatus;
  final String requestDate;
  final String? dueDate;
  final String? returnDate;
  final String? returnPaymentStatus;
  final String? returnCondition;
  final String? bookId;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCoverUrl;
  final String? bookFormat;
  final String? donorName;
  final String? userName;
  final String? bookCondition;
  final String? deliveryAddress;
  final String? deliveryName;
  final String? deliveryPhone;
  final String? deliveryPincode;
  final String? deliveryPreferredDate;
  final String? deliveryPreferredTime;
  final String? userEmail;
  final String? pickupUserName;
  final String? pickupPhone;
  final String? pickupAddress;
  final String? pickupDate;
  final String? pickupTime;
  final String? rejectionReason;

  const BookRequestEntity({
    required this.id,
    this.userId,
    required this.status,
    required this.fulfillmentMethod,
    required this.paymentStatus,
    required this.requestDate,
    this.dueDate,
    this.returnDate,
    this.returnPaymentStatus,
    this.returnCondition,
    this.bookId,
    this.bookTitle,
    this.bookAuthor,
    this.bookCoverUrl,
    this.bookFormat,
    this.donorName,
    this.userName,
    this.bookCondition,
    this.deliveryAddress,
    this.deliveryName,
    this.deliveryPhone,
    this.deliveryPincode,
    this.deliveryPreferredDate,
    this.deliveryPreferredTime,
    this.userEmail,
    this.pickupUserName,
    this.pickupPhone,
    this.pickupAddress,
    this.pickupDate,
    this.pickupTime,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        fulfillmentMethod,
        paymentStatus,
        requestDate,
        dueDate,
        returnDate,
        returnPaymentStatus,
        returnCondition,
        bookId,
        bookTitle,
        bookAuthor,
        bookCoverUrl,
        bookFormat,
        donorName,
        bookCondition,
        userName,
        deliveryAddress,
        deliveryName,
        deliveryPhone,
        deliveryPincode,
        deliveryPreferredDate,
        deliveryPreferredTime,
        userEmail,
        pickupUserName,
        pickupPhone,
        pickupAddress,
        pickupDate,
        pickupTime,
        rejectionReason,
      ];
}
