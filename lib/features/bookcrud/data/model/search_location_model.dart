import 'package:read_buddy_app/features/bookcrud/domain/entities/search_location_entity.dart';

class SearchLocationModel extends SearchLocationEntity {
  SearchLocationModel(super.description, super.latitude, super.longitude);

  factory SearchLocationModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return SearchLocationModel(
      json['description'] ?? json['full_address'] ?? '',
      parseDouble(json['latitude']),
      parseDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
