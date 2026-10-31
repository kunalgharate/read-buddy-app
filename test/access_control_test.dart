import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/core/utils/access_control.dart';

void main() {
  group('AccessControl.isAdmin', () {
    test('returns true for admin role with trimmed/case-insensitive inputs',
        () {
      expect(AccessControl.isAdmin('admin'), isTrue);
      expect(AccessControl.isAdmin('ADMIN'), isTrue);
      expect(AccessControl.isAdmin(' Admin '), isTrue);
    });

    test('returns false for non-admin, null, or empty roles', () {
      expect(AccessControl.isAdmin(null), isFalse);
      expect(AccessControl.isAdmin(''), isFalse);
      expect(AccessControl.isAdmin('   '), isFalse);
      expect(AccessControl.isAdmin('user'), isFalse);
      expect(AccessControl.isAdmin('librarian'), isFalse);
    });
  });

  group('AccessControl.isLibrarian', () {
    test('returns true for librarian role with trimmed/case-insensitive inputs',
        () {
      expect(AccessControl.isLibrarian('librarian'), isTrue);
      expect(AccessControl.isLibrarian('LIBRARIAN'), isTrue);
      expect(AccessControl.isLibrarian(' Librarian '), isTrue);
    });

    test('returns false for non-librarian, null, or empty roles', () {
      expect(AccessControl.isLibrarian(null), isFalse);
      expect(AccessControl.isLibrarian(''), isFalse);
      expect(AccessControl.isLibrarian('   '), isFalse);
      expect(AccessControl.isLibrarian('user'), isFalse);
      expect(AccessControl.isLibrarian('admin'), isFalse);
    });
  });

  group('AccessControl.canManageBooks', () {
    test('returns true for admin and librarian roles', () {
      expect(AccessControl.canManageBooks('admin'), isTrue);
      expect(AccessControl.canManageBooks('librarian'), isTrue);
      expect(AccessControl.canManageBooks(' Librarian '), isTrue);
      expect(AccessControl.canManageBooks('ADMIN'), isTrue);
    });

    test('returns false for user, null, or empty roles', () {
      expect(AccessControl.canManageBooks(null), isFalse);
      expect(AccessControl.canManageBooks(''), isFalse);
      expect(AccessControl.canManageBooks('   '), isFalse);
      expect(AccessControl.canManageBooks('user'), isFalse);
      expect(AccessControl.canManageBooks('guest'), isFalse);
    });
  });
}
