// features/books/presentation/bloc/book_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'book_event.dart';
import 'book_state.dart';
import '../../domain/usecases/get_books.dart';

@injectable
class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooks getBooks;

  BookBloc(this.getBooks) : super(BookInitial()) {
    on<LoadBooks>((event, emit) async {
      emit(BookLoading());
      try {
        final books = await getBooks();
        emit(BookLoaded(books));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    });

    on<RefreshBooks>((event, emit) async {
      try {
        final books = await getBooks();
        emit(BookLoaded(books));
      } catch (e) {
        emit(BookError("Refresh failed: ${e.toString()}"));
      }
    });
  }
}
