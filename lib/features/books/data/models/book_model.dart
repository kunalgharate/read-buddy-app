// // features/books/data/models/book_model.dart
import '../../domain/entities/book.dart';

// class BookModel extends Book {
//   BookModel(
//       {required String id,
//       required String title,
//       required String bookimage,
//       required BookCategory book_category
//       // required List<String> authors,
//       })
//       : super(
//             id: id,
//             title: title,
//             bookimage: bookimage,
//             book_category: book_category);

//   factory BookModel.fromJson(Map<String, dynamic> json) {
//     return BookModel(
//         id: json['_id'],
//         title: json['title'] ?? 'Unknown Title',
//         bookimage: json['coverImageUrl'] ?? "Unkown Image",
//         book_category: BookCategory.fromJson(json['category'])
//         //  authors: json['authors'],
//         );
//   }

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'title': title,
//         // 'authors': authors,
//         'bokimage': bookimage,
//         'book_caategory': book_category
//       };
// }

// class BookCategory {
//   final String id;
//   final String category_name;
//   BookCategory({required this.id, required this.category_name});

//   factory BookCategory.fromJson(Map<String, dynamic> json) {
//     return BookCategory(
//         id: json['_id'] ?? "", category_name: json['name'] ?? "");
//   }
//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'name': category_name,
//       };
// }

// features/books/data/models/book_model.dart

import '../../domain/entities/book.dart';

class BookModel extends Book {
  BookModel({
    required String id,
    required String title,
    required String bookimage,
    required BookCategory book_category,
    required List<String> authors,
  }) : super(
          id: id,
          title: title,
          bookimage: bookimage,
          book_category: book_category,
          // authors: authors,
        );

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    final authorsJson = json['authors'];

    return BookModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      bookimage: json['coverImageUrl'] ?? 'Unknown Image',
      book_category:
          categoryJson != null && categoryJson is Map<String, dynamic>
              ? BookCategory.fromJson(categoryJson)
              : BookCategory(id: '', category_name: 'Unknown Category'),
      authors: authorsJson != null && authorsJson is List
          ? List<String>.from(authorsJson.expand((e) {
              if (e is List) {
                return e.whereType<String>();
              } else if (e is String) {
                return [e];
              }
              return [];
            }))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'bookimage': bookimage,
        'book_category': book_category.toJson(),
        //'authors': authors,
      };
}

class BookCategory {
  final String id;
  final String category_name;

  BookCategory({
    required this.id,
    required this.category_name,
  });

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: json['_id'] ?? '',
      category_name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': category_name,
      };
}
