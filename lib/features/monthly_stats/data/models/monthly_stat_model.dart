import 'package:read_buddy_app/features/monthly_stats/domain/entities/monthly_stat.dart';

/// Data model that extends domain entity
/// Handles JSON serialization/deserialization
/// Manual fromJson/toJson implementation
class MonthlyStatModel extends MonthlyStat {
  const MonthlyStatModel({
    required super.month,
    required super.booksRead,
    required super.booksDonated,
    required super.hoursRead,
    required super.completionRate,
  });

  /// Create model from JSON response
  factory MonthlyStatModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatModel(
      month: json['month'] as String? ?? '',
      booksRead: json['booksRead'] as int? ?? 0,
      booksDonated: json['booksDonated'] as int? ?? 0,
      hoursRead: json['hoursRead'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'booksRead': booksRead,
      'booksDonated': booksDonated,
      'hoursRead': hoursRead,
      'completionRate': completionRate,
    };
  }

  /// Create model from entity
  factory MonthlyStatModel.fromEntity(MonthlyStat entity) {
    return MonthlyStatModel(
      month: entity.month,
      booksRead: entity.booksRead,
      booksDonated: entity.booksDonated,
      hoursRead: entity.hoursRead,
      completionRate: entity.completionRate,
    );
  }
}
