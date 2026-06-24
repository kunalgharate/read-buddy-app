import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';

class ParentCategoryModel extends Item {
  const ParentCategoryModel({
    required super.id,
    required super.name,
  });

  factory ParentCategoryModel.fromJson(Map<String, dynamic> json) {
    return ParentCategoryModel(
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
