import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/library/domain/entities/library_entity.dart';
import 'package:read_buddy_app/features/library/domain/repositories/library_repository.dart';
import 'package:read_buddy_app/features/library/domain/usecases/library_usecases.dart';
import 'package:read_buddy_app/features/library/presentation/widgets/pickup_library_selector.dart';

const MethodChannel _geoChannel =
    MethodChannel('flutter.baseflow.com/geolocator');

// Only getLibraryDetails is exercised by the picker; everything else on the
// repository is unreachable from this widget.
class _FakeLibraryRepository implements LibraryRepository {
  _FakeLibraryRepository(this.libraries, {this.fail = false});

  final List<LibraryEntity> libraries;
  final bool fail;

  @override
  Future<List<LibraryEntity>> getLibraryDetails() async {
    if (fail) throw Exception('network down');
    return libraries;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('not used: ${invocation.memberName}');
}

LibraryEntity _library(
  String id, {
  double lat = 0,
  double lng = 0,
  String? name,
}) {
  return LibraryEntity(
    id: id,
    name: name ?? id,
    address: LibraryAddressEntity(
      street: '$id Street',
      city: 'City',
      state: 'State',
      country: 'India',
      pincode: '560001',
      latitude: lat,
      longitude: lng,
    ),
    contactNumber: '1234567890',
    openHours: '9 AM - 6 PM',
    isSuperLibrary: false,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
}

void _mockGeo(
  WidgetTester tester, {
  required bool serviceEnabled,
  Map<String, dynamic>? position,
}) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    _geoChannel,
    (call) async {
      switch (call.method) {
        case 'isLocationServiceEnabled':
          return serviceEnabled;
        case 'checkPermission':
        case 'requestPermission':
          return serviceEnabled ? 2 /* whileInUse */ : 0 /* denied */;
        case 'getCurrentPosition':
          return position;
        default:
          return null;
      }
    },
  );
}

void _registerLibraries(List<LibraryEntity> libraries, {bool fail = false}) {
  getIt.registerFactory<GetLibraryDetails>(
    () => GetLibraryDetails(_FakeLibraryRepository(libraries, fail: fail)),
  );
}

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Bengaluru coordinates used as the "user's current location".
  const userPosition = {'latitude': 12.9716, 'longitude': 77.5946};

  tearDown(() async {
    if (getIt.isRegistered<GetLibraryDetails>()) {
      await getIt.unregister<GetLibraryDetails>();
    }
  });

  testWidgets(
      'location unavailable: shows every library with a hint and never '
      'auto-selects', (tester) async {
    _mockGeo(tester, serviceEnabled: false);
    _registerLibraries([
      _library('a', lat: 13.05, lng: 77.55, name: 'Near Library'),
      _library('b', lat: 28.61, lng: 77.20, name: 'Far Library'),
      _library('c', name: 'No-Coord Library'),
    ]);

    LibraryEntity? selected;
    await tester.pumpWidget(
      _host(
        PickupLibrarySelector(
          selectedLibrary: null,
          onSelected: (lib) => selected = lib,
          fallbackSentence: 'Choose Pick Up instead.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Near Library'), findsOneWidget);
    expect(find.text('Far Library'), findsOneWidget);
    expect(find.text('No-Coord Library'), findsOneWidget);
    expect(
      find.textContaining('Location unavailable — showing all libraries'),
      findsOneWidget,
      reason: 'the user must be told the location could not be resolved',
    );
    expect(
      selected,
      isNull,
      reason: 'without a location nothing may be auto-selected',
    );
  });

  testWidgets(
      'location available: keeps only libraries within 15 km, sorts nearest '
      'first, auto-selects the nearest and allows re-selection',
      (tester) async {
    _mockGeo(tester, serviceEnabled: true, position: userPosition);
    final near = _library('near', lat: 13.05, lng: 77.55, name: 'Near Library');
    final far = _library('far', lat: 28.61, lng: 77.20, name: 'Far Library');
    final coordless = _library('nocoord', name: 'No-Coord Library');
    // Deliberately unsorted input.
    _registerLibraries([far, coordless, near]);

    LibraryEntity? selected;
    await tester.pumpWidget(
      _host(
        PickupLibrarySelector(
          selectedLibrary: null,
          onSelected: (lib) => selected = lib,
          fallbackSentence: 'Choose Pick Up instead.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Near Library'), findsOneWidget);
    expect(find.text('No-Coord Library'), findsOneWidget);
    expect(
      find.text('Far Library'),
      findsNothing,
      reason: 'libraries beyond the 15 km radius must not be listed',
    );
    expect(selected?.id, 'near', reason: 'the nearest in-range library wins');

    final nearTop = tester.getTopLeft(find.text('Near Library')).dy;
    final coordlessTop = tester.getTopLeft(find.text('No-Coord Library')).dy;
    expect(
      nearTop,
      lessThan(coordlessTop),
      reason: 'in-range libraries are listed before coord-less fallbacks',
    );

    await tester.tap(find.text('No-Coord Library'));
    await tester.pump();
    expect(selected?.id, 'nocoord');
  });

  testWidgets(
      'location available but nothing within 15 km: shows the empty message '
      'with the supplied fallback sentence', (tester) async {
    _mockGeo(tester, serviceEnabled: true, position: userPosition);
    _registerLibraries([
      _library('far', lat: 28.61, lng: 77.20, name: 'Far Library'),
    ]);

    LibraryEntity? selected;
    await tester.pumpWidget(
      _host(
        PickupLibrarySelector(
          selectedLibrary: null,
          onSelected: (lib) => selected = lib,
          fallbackSentence: 'Choose Pick Up instead.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Far Library'), findsNothing);
    expect(
      find.text(
        'No libraries within 15 km of your location. Choose Pick Up instead.',
      ),
      findsOneWidget,
    );
    expect(selected, isNull);
  });

  testWidgets('library fetch failure: shows the error with a retry action',
      (tester) async {
    _mockGeo(tester, serviceEnabled: false);
    _registerLibraries([], fail: true);

    await tester.pumpWidget(
      _host(
        PickupLibrarySelector(
          selectedLibrary: null,
          onSelected: (_) {},
          fallbackSentence: 'Choose Pick Up instead.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load libraries. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
