import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';

class parentCategoryModel extends Item {
  const parentCategoryModel({
    required super.id,
    required super.name,
  });

  factory parentCategoryModel.fromJson(Map<String, dynamic> json) {
    return parentCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}
