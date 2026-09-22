import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/features/address/data/datasources/address_remote_datasource.dart';

void main() {
  const fallback = <String, dynamic>{
    '_id': 'addr-local',
    'label': 'Home',
    'name': 'Deborah',
    'phone': '9876543210',
    'addressLine1': 'Flat 101',
    'city': 'Mumbai',
    'state': 'MH',
    'pincode': '400001',
  };

  group('buildAddressModel', () {
    test('reads the address doc from a `{address: {...}}` envelope', () {
      final model = buildAddressModel(
        {
          'address': {
            '_id': 'addr-1',
            'label': 'Work',
            'name': 'Deborah',
            'phone': '9876543210',
            'addressLine1': 'Tower B',
            'city': 'Pune',
            'state': 'MH',
            'pincode': '411001',
          },
        },
        fallback,
      );

      expect(model.id, 'addr-1');
      expect(model.label, 'Work');
      expect(model.city, 'Pune');
    });

    test('reads the address doc from a `{data: {...}}` envelope', () {
      final model = buildAddressModel(
        {
          'data': {
            '_id': 'addr-2',
            'label': 'Home',
            'name': 'Deborah',
            'phone': '9876543210',
            'addressLine1': 'Flat 101',
            'city': 'Mumbai',
            'state': 'MH',
            'pincode': '400001',
          },
        },
        fallback,
      );

      expect(model.id, 'addr-2');
      expect(model.addressLine1, 'Flat 101');
    });

    test('reads the bare address map as-is', () {
      final model = buildAddressModel(
        {
          '_id': 'addr-3',
          'label': 'Other',
          'name': 'Deborah',
          'phone': '9876543210',
          'addressLine1': 'Street 9',
          'city': 'Delhi',
          'state': 'Delhi',
          'pincode': '110001',
        },
        fallback,
      );

      expect(model.id, 'addr-3');
      expect(model.city, 'Delhi');
    });

    test('recognizes a bare model that carries the combined `address` field',
        () {
      final model = buildAddressModel(
        {
          '_id': 'addr-4',
          'label': 'Home',
          'name': 'Deborah',
          'phone': '9876543210',
          'address': 'Some street',
          'city': 'Mumbai',
          'state': 'MH',
          'pincode': '400001',
        },
        fallback,
      );

      expect(model.id, 'addr-4');
      expect(model.addressLine1, 'Some street');
    });

    test('falls back to sent data when response is a message only', () {
      final model = buildAddressModel({'message': 'Address saved'}, fallback);

      expect(model.id, 'addr-local');
      expect(model.addressLine1, 'Flat 101');
    });

    test('falls back to sent data when response is not a map', () {
      final model = buildAddressModel('Address saved', fallback);

      expect(model.id, 'addr-local');
      expect(model.label, 'Home');
    });
  });
}
