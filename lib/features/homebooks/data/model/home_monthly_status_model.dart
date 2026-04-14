class MonthlyStatsModel {
  final int donatedBooks;
  final int requestedBooks;
  final int newUsers;
  final int deliveredBooks;

  MonthlyStatsModel({
    required this.donatedBooks,
    required this.requestedBooks,
    required this.newUsers,
    required this.deliveredBooks,
  });

  factory MonthlyStatsModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatsModel(
      donatedBooks: json['donatedBooks'] ?? 0,
      requestedBooks: json['requestedBooks'] ?? 0,
      newUsers: json['newUsers'] ?? 0,
      deliveredBooks: json['deliveredBooks'] ?? 0,
    );
  }
}
