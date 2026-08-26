import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import '../../domain/entities/wishlist_book_entity.dart';
import '../../domain/usecases/wishlist_usecases.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final GetWishlist _getWishlist;
  final AddToWishlist _addToWishlist;
  final RemoveFromWishlist _removeFromWishlist;

  WishlistBloc({
    required GetWishlist getWishlist,
    required AddToWishlist addToWishlist,
    required RemoveFromWishlist removeFromWishlist,
  })  : _getWishlist = getWishlist,
        _addToWishlist = addToWishlist,
        _removeFromWishlist = removeFromWishlist,
        super(WishlistInitial()) {
    on<LoadWishlist>(_onLoadWishlist);
    on<AddBookToWishlist>(_onAddBookToWishlist);
    on<RemoveBookFromWishlist>(_onRemoveBookFromWishlist);
  }

  Future<void> _onLoadWishlist(
    LoadWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());
    try {
      final books = await _getWishlist();
      emit(WishlistLoaded(books));
    } catch (e) {
      emit(WishlistError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onAddBookToWishlist(
    AddBookToWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      await _addToWishlist(event.bookId);
      emit(WishlistBookAdded());
    } catch (e) {
      emit(WishlistError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onRemoveBookFromWishlist(
    RemoveBookFromWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      await _removeFromWishlist(event.bookId);
      emit(WishlistBookRemoved());
    } catch (e) {
      emit(WishlistError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
