import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/features/address/data/models/address_model.dart';

void main() {
  group('AddressModel.fromJson', () {
    test('parses numeric latitude/longitude and bool isDefault', () {
      final model = AddressModel.fromJson({
        '_id': 'addr1',
        'label': 'Home',
        'name': 'Deborah',
        'phone': '9876543210',
        'addressLine1': 'Flat 101',
        'addressLine2': 'Main Road',
        'city': 'Mumbai',
        'state': 'MH',
        'pincode': '400001',
        'latitude': 18.52,
        'longitude': 73.85,
        'isDefault': true,
      });

      expect(model.latitude, 18.52);
      expect(model.longitude, 73.85);
      expect(model.isDefault, isTrue);
    });

    test('parses string latitude/longitude and string isDefault', () {
      final model = AddressModel.fromJson({
        '_id': 'addr2',
        'label': 'Work',
        'name': 'Deborah',
        'phone': '9876543210',
        'addressLine1': 'Tower B',
        'city': 'Pune',
        'state': 'MH',
        'pincode': '411001',
        'latitude': '18.5204',
        'longitude': '73.8567',
        'isDefault': 'false',
      });

      expect(model.latitude, 18.5204);
      expect(model.longitude, 73.8567);
      expect(model.isDefault, isFalse);
    });

    test('falls back safely when fields are missing', () {
      final model = AddressModel.fromJson({
        '_id': 'addr3',
        'label': 'Other',
        'name': 'Deborah',
        'phone': '9876543210',
        'address': 'Some street',
      });

      expect(model.latitude, 0);
      expect(model.longitude, 0);
      expect(model.isDefault, isFalse);
      expect(model.addressLine1, 'Some street');
    });
  });
}
