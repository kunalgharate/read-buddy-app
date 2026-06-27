import '../../domain/entities/book_detail_entity.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/entities/library_entity.dart';
import '../../domain/entities/pickup_details_entity.dart';
import '../../domain/repositories/book_request_repository.dart';
import '../datasources/book_request_remote_datasource.dart';

class BookRequestRepositoryImpl implements BookRequestRepository {
  final BookRequestRemoteDataSource remoteDataSource;

  BookRequestRepositoryImpl(this.remoteDataSource);

  @override
  Future<BookDetailEntity> getBookById(String id) async {
    return await remoteDataSource.getBookById(id);
  }

  @override
  Future<String> createBookRequest(
    String bookId,
    String fulfillmentMethod, {
    String? deliveryName,
    String? deliveryPhone,
    String? deliveryAddress,
    String? deliveryPincode,
    String? deliveryPreferredDate,
  }) async {
    return await remoteDataSource.createBookRequest(
      bookId,
      fulfillmentMethod,
      deliveryName: deliveryName,
      deliveryPhone: deliveryPhone,
      deliveryAddress: deliveryAddress,
      deliveryPincode: deliveryPincode,
      deliveryPreferredDate: deliveryPreferredDate,
    );
  }

  @override
  Future<List<BookRequestEntity>> getMyBookRequests() async {
    return await remoteDataSource.getMyBookRequests();
  }

  @override
  Future<List<BookRequestEntity>> getAllBookRequests() async {
    return await remoteDataSource.getAllBookRequests();
  }

  @override
  Future<List<BookRequestEntity>> getUpcomingPickups() async {
    return await remoteDataSource.getUpcomingPickups();
  }

  @override
  Future<void> cancelBookRequest(String id, String reason) async {
    return await remoteDataSource.cancelBookRequest(id, reason);
  }

  @override
  Future<void> acceptBookRequest(String id, {String? notes}) async {
    return await remoteDataSource.acceptBookRequest(id, notes: notes);
  }

  @override
  Future<void> declineBookRequest(String id,
      {String reason = 'Request declined'}) async {
    return await remoteDataSource.declineBookRequest(id, reason: reason);
  }

  @override
  Future<LibraryEntity> getLibraryDetails() async {
    return await remoteDataSource.getLibraryDetails();
  }

  @override
  Future<BookRequestEntity> schedulePickup(PickupDetailsEntity details) async {
    return await remoteDataSource.schedulePickup(details);
  }

  @override
  Future<BookRequestEntity> getRequestDetails(String id) async {
    return await remoteDataSource.getRequestDetails(id);
  }

  @override
  Future<void> updateRequestStatus(String id, String status) async {
    return await remoteDataSource.updateRequestStatus(id, status);
  }

  @override
  Future<void> scheduleDelivery(
      String id,
      String name,
      String phone,
      String address,
      String pincode,
      String preferredDate,
      String preferredTime) async {
    return await remoteDataSource.scheduleDelivery(
        id, name, phone, address, pincode, preferredDate, preferredTime);
  }

  @override
  Future<void> initiateReturn(String id, String returnMethod,
      {String? returnBranchId}) async {
    return await remoteDataSource.initiateReturn(id, returnMethod,
        returnBranchId: returnBranchId);
  }
}
