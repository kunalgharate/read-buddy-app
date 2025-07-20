class LatestBookEntity {
  final String id;
  final String title;
  final String category;
  final String donor;
  final String format;
  final String imageUrl;
  final String formatUrl;
  final String duration;

  LatestBookEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.donor,
    required this.format,
    required this.imageUrl,
    required this.formatUrl,
    required this.duration,
  });
}

class RecommendedBookCardEntity {
  final String id;
  final String title;
  final String category;
  final String donor;
  final String format;
  final String imageUrl;
  final String formatUrl;
  final String duration;

  RecommendedBookCardEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.donor,
    required this.format,
    required this.imageUrl,
    required this.formatUrl,
    required this.duration,
  });
}

class StatEntity {
  final String bookDonated;
  final String activeUsers;
  final String deleveries;

  StatEntity({
    required this.bookDonated,
    required this.activeUsers,
    required this.deleveries,
  });
}

class BannerEntity {
  final String id;
  final String title;
  final String imageUrl;
  const BannerEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}
