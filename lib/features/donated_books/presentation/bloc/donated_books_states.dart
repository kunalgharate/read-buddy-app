import 'package:read_buddy_app/features/donated_books/domain/entities/donated_books_entity.dart';

sealed class DonatedBooksState {}

class DonatedBooksInitial extends DonatedBooksState {}

class DonatedBooksLoading extends DonatedBooksState {}

class DonatedBooksLoaded extends DonatedBooksState {
  final List<DonatedBooksEntity> donatedBooks;
  DonatedBooksLoaded(this.donatedBooks);
}

class DonatedBooksLoadingError extends DonatedBooksState {
  final String message;
  DonatedBooksLoadingError(this.message);
}
