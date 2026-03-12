import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';

abstract class BookCrudEvent {}

class SearchBook extends BookCrudEvent {
  final String query;

  SearchBook(this.query);
}

class LoadBookCrudList extends BookCrudEvent {}

class LoadBookCrudById extends BookCrudEvent {
  final String id;
  LoadBookCrudById({required this.id});
}

class AddBookCrudEvent extends BookCrudEvent {
  final BookCrudEntity book;
  AddBookCrudEvent(this.book);
}

class UpdateBookCrudEvent extends BookCrudEvent {
  final String id;
  final BookCrudEntity book;
  UpdateBookCrudEvent(this.id, this.book);
}

class DeleteBookCrudEvent extends BookCrudEvent {
  final String id;
  DeleteBookCrudEvent(this.id);
}
