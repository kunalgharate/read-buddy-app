import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// A simple data model for our book/item
// You likely have this defined elsewhere, so you can import it.
class Book extends Equatable {
  final String id;
  final String title;
  final String author;

  const Book({required this.id, required this.title, required this.author});

  @override
  List<Object> get props => [id];
}

class WishlistState extends Equatable {
  final List<Book> items;

  const WishlistState({this.items = const []});

  @override
  List<Object> get props => [items];
}

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit() : super(const WishlistState());

  void addToWishlist(Book book) {
    // Don't add if it already exists
    if (state.items.contains(book)) return;

    // Create a new list and emit a new state
    final updatedList = List<Book>.from(state.items)..add(book);
    emit(WishlistState(items: updatedList));
  }

  void removeFromWishlist(Book book) {
    final updatedList = List<Book>.from(state.items)..remove(book);
    emit(WishlistState(items: updatedList));
  }
}
