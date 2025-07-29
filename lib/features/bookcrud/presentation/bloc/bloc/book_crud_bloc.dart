// features/book_crud/presentation/bloc/book_crud_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/add_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/delete_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/get_books.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/get_books_by_id.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/search_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/update_book.dart';
import 'book_crud_event.dart';
import 'book_crud_state.dart';

@injectable
class BookCrudBloc extends Bloc<BookCrudEvent, BookCrudState> {
  final SearchBookUsecase searchBooks;
  final GetBooksUsecase getBooksCrud;
  final GetBookByIdUsecase getBookByIdCrud;
  final AddBookUsecase addBookCrud;
  final UpdateBookUsecase updateBookCrud;
  final DeleteBookusecase deleteBookCrud;

  BookCrudBloc({
    required this.searchBooks,
    required this.getBooksCrud,
    required this.getBookByIdCrud,
    required this.addBookCrud,
    required this.updateBookCrud,
    required this.deleteBookCrud,
  }) : super(BookCrudInitial()) {
    on<SearchBook>((event, emit) async {
      emit(BookCrudLoading());
      try {
        final books = await searchBooks(event.query);
        emit(BookCrudListLoaded(booksCollection: books));
      } catch (e) {
        emit(BookCrudError("Failed to load searched books"));
      }
    });

    on<LoadBookCrudList>((event, emit) async {
      emit(BookCrudLoading());
      try {
        final books = await getBooksCrud();
        emit(BookCrudListLoaded(booksCollection: books));
      } catch (e) {
        emit(BookCrudError("Failed to load get books: $e"));
      }
    });

    on<LoadBookCrudById>((event, emit) async {
      emit(BookCrudLoading());

      try {
        final book = await getBookByIdCrud(event.id);

        emit(BookCrudDetailLoaded(book));
      } catch (e) {
        emit(BookCrudError("Failed to load book by id: $e"));
      }
    });

    on<AddBookCrudEvent>((event, emit) async {
      emit(BookCrudLoading());
      try {
        await addBookCrud(event.book);
        add(LoadBookCrudList()); // refresh list
      } catch (e) {
        emit(BookCrudError("Failed to add book: $e"));
      }
    });

    on<UpdateBookCrudEvent>((event, emit) async {
      emit(BookCrudLoading());
      try {
        await updateBookCrud(event.id, event.book);
        add(LoadBookCrudList());
      } catch (e) {
        emit(BookCrudError("Failed to update book: $e"));
      }
    });

    on<DeleteBookCrudEvent>((event, emit) async {
      emit(BookCrudLoading());
      try {
        await deleteBookCrud(event.id);
        add(LoadBookCrudList());
      } catch (e) {
        emit(BookCrudError("Failed to delete book: $e"));
      }
    });
  }
}
