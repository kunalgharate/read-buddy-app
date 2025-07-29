import 'package:read_buddy_app/features/bookcrud/domain/entities/search_location_entity.dart';

class SearchLocationModel extends SearchLocationEntity {
  SearchLocationModel(super.description, super.latitude, super.longitude);

  factory SearchLocationModel.fromJson(Map<String, dynamic> json) {
    return SearchLocationModel(
      json['description'],
      json['latitude'],
      json['longitude'],
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
