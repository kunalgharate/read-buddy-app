import 'book_crud_model.dart';

class PagedBooksResult {
  final List<BookCrudModel> books;
  final int total;
  final int page;
  final int totalPages;

  const PagedBooksResult({
    required this.books,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}