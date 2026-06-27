import '../entities/book_detail_entity.dart';
import '../entities/book_request_entity.dart';
import '../entities/library_entity.dart';
import '../entities/pickup_details_entity.dart';

abstract class BookRequestRepository {
  Future<BookDetailEntity> getBookById(String id);
  Future<void> createBookRequest(String bookId);
  Future<List<BookRequestEntity>> getMyBookRequests();
  Future<List<BookRequestEntity>> getAllBookRequests();
  Future<List<BookRequestEntity>> getUpcomingPickups();
  Future<void> cancelBookRequest(String id, String reason);
  Future<void> acceptBookRequest(String id, {String? notes});
  Future<void> declineBookRequest(String id, {String reason});
  Future<LibraryEntity> getLibraryDetails();
  Future<BookRequestEntity> schedulePickup(PickupDetailsEntity details);
  Future<BookRequestEntity> getRequestDetails(String id);
  Future<void> updateRequestStatus(String id, String status);
  Future<void> scheduleDelivery(
      String id,
      String name,
      String phone,
      String address,
      String pincode,
      String preferredDate,
      String preferredTime);
  Future<void> initiateReturn(String id, String returnMethod,
      {String? returnBranchId});
}
