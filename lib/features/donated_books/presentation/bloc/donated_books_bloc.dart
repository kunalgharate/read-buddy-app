import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/donated_books/domain/usecases/get_donated_books.dart';
import 'package:read_buddy_app/features/donated_books/presentation/bloc/donated_books_events.dart';
import 'package:read_buddy_app/features/donated_books/presentation/bloc/donated_books_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@injectable
class DonatedBooksBloc extends Bloc<DonatedBooksEvents, DonatedBooksState>{
  final GetDonatedBooks getDonatedBooks;

  DonatedBooksBloc(this.getDonatedBooks):super(DonatedBooksInitial()){
    on<LoadDonatedBooks>((event, emit) async{
      emit(DonatedBooksLoading());
      try{
        final books = await getDonatedBooks();
        emit(DonatedBooksLoaded(books));
      }
      catch(e){
        emit(DonatedBooksLoadingError(e.toString()));
      }
    });
  }
}