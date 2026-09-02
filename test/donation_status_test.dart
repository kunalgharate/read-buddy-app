import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';
import 'package:read_buddy_app/features/donate/presentation/widgets/donation_status.dart'
    show DonationStatusInfo, allBooksSorted, confirmedBooksSorted, resolveDonationStatus;

void main() {
  BookStatusItem item(String id, String status, {String? createdAt}) =>
      BookStatusItem(
        id: id,
        title: 'Book $id',
        format: 'Hardcover',
        status: status,
        createdAt: createdAt,
      );

  group('resolveDonationStatus', () {
    DonationStatusInfo resolved(String status) => resolveDonationStatus(status);

    test('maps pending-like statuses to Pending without counting', () {
      for (final s in ['pending', 'donation_created', 'pickup_requested']) {
        final r = resolved(s);
        expect(r.label, 'Pending');
        expect(r.confirmed, isFalse);
      }
    });

    test('maps in-progress statuses to In Progress and counts', () {
      for (final s in [
        'accepted',
        'approved',
        'processing',
        'out_for_pickup',
        'pickup_scheduled',
        'book_shipped',
        'in_transit',
        'picked_up',
      ]) {
        final r = resolved(s);
        expect(r.label, 'In Progress');
        expect(r.confirmed, isTrue);
      }
    });

    test('maps completed statuses to Completed and counts', () {
      for (final s in ['completed', 'done', 'delivered', 'success', 'received']) {
        final r = resolved(s);
        expect(r.label, 'Completed');
        expect(r.confirmed, isTrue);
      }
    });

    test('maps cancelled/rejected to Cancelled without counting', () {
      for (final s in ['cancelled', 'rejected']) {
        final r = resolved(s);
        expect(r.label, 'Cancelled');
        expect(r.confirmed, isFalse);
      }
    });

    test('treats any unknown status as safe, non-confirmed, and does not throw',
        () {
      final r = resolved('completely_unknown_status');
      expect(r.label, isNotEmpty);
      expect(r.confirmed, isFalse);
      expect(r.color, isA<Color>());
    });

    test('is case-insensitive and trims whitespace', () {
      expect(resolved(' PENDING ').label, 'Pending');
      expect(resolved('DONE').label, 'Completed');
    });
  });

  group('allBooksSorted', () {
    test('keeps all donations, pending and confirmed', () {
      final items = [
        item('1', 'completed', createdAt: '2026-01-02'),
        item('2', 'pending', createdAt: '2026-01-03'),
        item('3', 'done', createdAt: '2026-01-01'),
        item('4', 'cancelled', createdAt: '2026-01-04'),
        item('5', 'received', createdAt: '2026-01-05'),
      ];
      final result = allBooksSorted(items);
      expect(result.map((b) => b.id), ['5', '4', '2', '1', '3']);
    });

    test('sorts newest first by createdAt', () {
      final items = [
        item('old', 'completed', createdAt: '2026-01-01'),
        item('new', 'completed', createdAt: '2026-01-10'),
        item('mid', 'completed', createdAt: '2026-01-05'),
      ];
      expect(allBooksSorted(items).map((b) => b.id), ['new', 'mid', 'old']);
    });

    test('does not mutate the input list', () {
      final items = [item('1', 'pending', createdAt: '2026-01-01')];
      allBooksSorted(items);
      expect(items.length, 1);
    });
  });

  group('confirmedBooksSorted', () {
    test('keeps only confirmed statuses', () {
      final items = [
        item('1', 'completed', createdAt: '2026-01-02'),
        item('2', 'pending', createdAt: '2026-01-03'),
        item('3', 'done', createdAt: '2026-01-01'),
        item('4', 'cancelled', createdAt: '2026-01-04'),
        item('5', 'received', createdAt: '2026-01-05'),
      ];
      final result = confirmedBooksSorted(items);
      expect(result.map((b) => b.id), ['5', '1', '3']);
    });

    test('sorts newest first by createdAt', () {
      final items = [
        item('old', 'completed', createdAt: '2026-01-01'),
        item('new', 'completed', createdAt: '2026-01-10'),
        item('mid', 'completed', createdAt: '2026-01-05'),
      ];
      expect(confirmedBooksSorted(items).map((b) => b.id), ['new', 'mid', 'old']);
    });

    test('returns empty list when nothing is confirmed', () {
      final items = [item('1', 'pending'), item('2', 'unknown_x')];
      expect(confirmedBooksSorted(items), isEmpty);
    });
  });
}
