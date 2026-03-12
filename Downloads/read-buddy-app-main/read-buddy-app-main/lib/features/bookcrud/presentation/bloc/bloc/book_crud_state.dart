import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';

abstract class BookCrudState {}

class BookCrudInitial extends BookCrudState {}

class BookCrudLoading extends BookCrudState {}

class BookCrudListLoaded extends BookCrudState {
  final List<BookCrudEntity> booksCollection;
  BookCrudListLoaded({required this.booksCollection});
}

class BookCrudDetailLoaded extends BookCrudState {
  final BookCrudEntity book;
  BookCrudDetailLoaded(this.book);
}

class BookCrudError extends BookCrudState {
  final String message;
  BookCrudError(this.message);
}
