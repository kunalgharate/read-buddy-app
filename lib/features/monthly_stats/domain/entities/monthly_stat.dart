import 'package:equatable/equatable.dart';

/// Domain entity for monthly statistics
/// Pure Dart class with no framework dependencies
class MonthlyStat extends Equatable {
  final String month;
  final int booksRead;
  final int booksDonated;
  final int hoursRead;
  final double completionRate;

  const MonthlyStat({
    required this.month,
    required this.booksRead,
    required this.booksDonated,
    required this.hoursRead,
    required this.completionRate,
  });

  @override
  List<Object?> get props => [
        month,
        booksRead,
        booksDonated,
        hoursRead,
        completionRate,
      ];
}
