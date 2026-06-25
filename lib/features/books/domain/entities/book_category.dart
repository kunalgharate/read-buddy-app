import 'package:equatable/equatable.dart';

class BookCategory extends Equatable {
  final String id;
  final String categoryName;

  const BookCategory({
    required this.id,
    required this.categoryName,
  });

  @override
  List<Object> get props => [id, categoryName];
}
