import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/books/domain/entities/book.dart';

class WishlistState extends Equatable {
  final List<Book> books;
  final bool isMenuVisible;
  final bool isMenuPermanentlyClosed;

  const WishlistState({
    this.books = const [],
    this.isMenuVisible = false,
    this.isMenuPermanentlyClosed = false,
  });

  WishlistState copyWith({
    List<Book>? books,
    bool? isMenuVisible,
    bool? isMenuPermanentlyClosed,
  }) {
    return WishlistState(
      books: books ?? this.books,
      isMenuVisible: isMenuVisible ?? this.isMenuVisible,
      isMenuPermanentlyClosed:
          isMenuPermanentlyClosed ?? this.isMenuPermanentlyClosed,
    );
  }

  @override
  List<Object?> get props => [books, isMenuVisible, isMenuPermanentlyClosed];
}

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit() : super(const WishlistState());

  void addBook(Book book) {
    if (!state.books.contains(book)) {
      emit(state.copyWith(
        books: List.from(state.books)..add(book),
        isMenuVisible: true,
      ));
    }
  }

  void removeBook(Book book) {
    emit(state.copyWith(
      books: List.from(state.books)..remove(book),
    ));
  }

  void toggleMenu() {
    emit(state.copyWith(isMenuVisible: !state.isMenuVisible));
  }

  void hideMenu() {
    emit(state.copyWith(isMenuVisible: false));
  }

  void permanentCloseMenu() {
    emit(state.copyWith(
      isMenuVisible: false,
      isMenuPermanentlyClosed: true,
    ));
  }

  void resetMenu() {
    emit(state.copyWith(
      isMenuVisible: true,
      isMenuPermanentlyClosed: false,
    ));
  }
}
