// features/books/presentation/bloc/book_event.dart
sealed class BookEvent {}

class LoadBooks extends BookEvent {}

class RefreshBooks extends BookEvent {}
