import 'package:equatable/equatable.dart';

class BookCategory extends Equatable {
  final String id;
  final String category_name;

  const BookCategory({
    required this.id,
    required this.category_name,
  });

  @override
  List<Object> get props => [id, category_name];
}
