import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/book_request/domain/entities/book_request_entity.dart';
import 'package:read_buddy_app/features/book_request/presentation/pages/pickup_details_page.dart';
import 'package:read_buddy_app/features/library/domain/entities/library_entity.dart';
import 'package:read_buddy_app/features/library/domain/repositories/library_repository.dart';
import 'package:read_buddy_app/features/library/domain/usecases/library_usecases.dart';

class _FakeLibraryRepository implements LibraryRepository {
  _FakeLibraryRepository(this.library);

  final LibraryEntity library;

  @override
  Future<LibraryEntity> getLibraryById(String id) async => library;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('not used: ${invocation.memberName}');
}

LibraryEntity _library() => LibraryEntity(
      id: 'lib-1',
      name: 'Central Library',
      address: const LibraryAddressEntity(
        street: 'MG Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        pincode: '560001',
        latitude: 12.97,
        longitude: 77.59,
      ),
      contactNumber: '08012345678',
      openHours: '9 AM - 6 PM',
      isSuperLibrary: false,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

BookRequestEntity _request({
  String? pickupDate,
  String? pickupTime,
  String? pickupUserName,
  String? pickupPhone,
}) =>
    BookRequestEntity(
      id: 'req-1',
      status: 'approved',
      fulfillmentMethod: 'PICKUP',
      paymentStatus: 'PENDING',
      requestDate: '2026-11-01',
      libraryId: 'lib-1',
      libraryName: 'Central Library',
      bookTitle: 'Atomic Habits',
      bookAuthor: 'James Clear',
      pickupDate: pickupDate,
      pickupTime: pickupTime,
      pickupUserName: pickupUserName,
      pickupPhone: pickupPhone,
    );

Widget _host(Widget child) => MaterialApp(home: child);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    getIt.registerFactory<GetLibraryById>(
      () => GetLibraryById(_FakeLibraryRepository(_library())),
    );
  });

  tearDown(() async {
    if (getIt.isRegistered<GetLibraryById>()) {
      await getIt.unregister<GetLibraryById>();
    }
  });

  testWidgets('shows the pickup library and offers scheduling when unscheduled',
      (tester) async {
    await tester.pumpWidget(_host(PickupDetailsPage(request: _request())));
    await tester.pumpAndSettle();

    expect(find.text('Pickup Details'), findsOneWidget);
    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('Central Library'), findsOneWidget);
    expect(find.textContaining('MG Road'), findsOneWidget);
    expect(find.text('9 AM - 6 PM'), findsOneWidget);
    expect(find.text('Not scheduled yet'), findsOneWidget);
    expect(find.text('Schedule Pickup'), findsOneWidget);
  });

  testWidgets('shows the saved slot and contact without a scheduling action',
      (tester) async {
    await tester.pumpWidget(
      _host(
        PickupDetailsPage(
          request: _request(
            pickupDate: '2026-11-10',
            pickupTime: '10:30 AM',
            pickupUserName: 'Asha Rao',
            pickupPhone: '9876543210',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('10 Nov 2026'), findsOneWidget);
    expect(find.text('10:30 AM'), findsOneWidget);
    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('9876543210'), findsOneWidget);
    expect(find.text('Schedule Pickup'), findsNothing);
  });
}
