import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/features/book_request/data/models/book_request_model.dart';

void main() {
  group('BookRequestModel.fromJson — return flow contract', () {
    test('maps the fields GET /v1/book-requests/my actually returns', () {
      final model = BookRequestModel.fromJson({
        '_id': 'req1',
        'status': 'returning',
        'fulfillmentMethod': 'DELIVERY',
        'paymentStatus': 'PAID',
        'createdAt': '2026-10-10T10:00:00.000Z',
        'dueDate': '2026-11-10T00:00:00.000Z',
        'returnMethod': 'PICKUP',
        'returnBranchId': 'lib1',
        'returnScheduledDate': '2026-10-20T00:00:00.000Z',
        'returnScheduledSlot': '10:00 AM',
        'returnPaymentStatus': 'PAID',
        'returnPickupAddress': 'Flat 12, MG Road, Mumbai',
        'bookId': {
          '_id': 'b1',
          'title': 'Dune',
          'author': 'Frank Herbert',
          'coverImageUrl': 'https://img/cover.jpg',
        },
        'libraryId': {'_id': 'lib1', 'name': 'Central Library'},
        'address': 'Borrow delivery address',
      });

      expect(model.id, 'req1');
      expect(model.status, 'returning');
      expect(model.requestDate, '2026-10-10T10:00:00.000Z');
      expect(model.returnMethod, 'PICKUP');
      expect(model.returnBranchId, 'lib1');
      expect(model.returnScheduledDate, '2026-10-20T00:00:00.000Z');
      expect(model.returnScheduledSlot, '10:00 AM');
      expect(model.returnPaymentStatus, 'PAID');
      expect(model.returnPickupAddress, 'Flat 12, MG Road, Mumbai');
      expect(model.bookTitle, 'Dune');
      expect(model.bookCoverUrl, 'https://img/cover.jpg');
      expect(model.libraryId, 'lib1');
      expect(model.libraryName, 'Central Library');
      // The borrow delivery address must NOT leak into the return pickup
      // address for a paid home-pickup return.
      expect(model.returnPickupAddress, isNot(model.deliveryAddress));
    });

    test('accepts returnBranchId as plain id and as populated object', () {
      final plain = BookRequestModel.fromJson({
        '_id': 'r1',
        'status': 'returning',
        'fulfillmentMethod': 'PICKUP',
        'paymentStatus': 'FREE',
        'returnMethod': 'DROP_OFF',
        'returnBranchId': 'lib9',
      });
      expect(plain.returnBranchId, 'lib9');

      final populated = BookRequestModel.fromJson({
        '_id': 'r2',
        'status': 'returning',
        'fulfillmentMethod': 'PICKUP',
        'paymentStatus': 'FREE',
        'returnMethod': 'DROP_OFF',
        'returnBranchId': {
          '_id': 'lib9',
          'name': 'Branch 2',
        },
      });
      expect(populated.returnBranchId, 'lib9');
    });

    test('leaves returnPickupAddress null when the backend omits it', () {
      final model = BookRequestModel.fromJson({
        '_id': 'r3',
        'status': 'delivered',
        'fulfillmentMethod': 'DELIVERY',
        'paymentStatus': 'PAID',
        'address': 'Borrow delivery address',
      });
      expect(model.returnPickupAddress, isNull);
    });
  });
}
