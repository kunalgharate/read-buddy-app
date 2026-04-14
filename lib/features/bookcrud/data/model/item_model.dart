import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.name,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
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
