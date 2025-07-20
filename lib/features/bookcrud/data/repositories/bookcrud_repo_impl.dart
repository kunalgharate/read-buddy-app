import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/bookcrud/data/dataresources/bookCrud_remote_resources.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/bookcrud_repo.dart';
import '../../domain/entities/book_crud.dart';

@Injectable(as: BookCrudRepository)
class BookCrudRepositoryImpl implements BookCrudRepository {
  final BookCrudRemoteDataSource remoteDataSource;

  BookCrudRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BookCrudEntity>> getBooks() async {
    return await remoteDataSource.getBooks();
  }

  @override
  Future<BookCrudEntity> getBookById(String id) async {
    final bookModel = await remoteDataSource.getBookById(id);
    return bookModel;
  }

  @override
  Future<void> addBook(BookCrudEntity book) async {
    final model = BookCrudModel.fromEntity(book); // convert entity to model
    await remoteDataSource.addBook(model); // safe now
  }

  @override
  Future<void> updateBook(String id, BookCrudEntity book) async {
    final model = BookCrudModel.fromEntity(book);
    await remoteDataSource.updateBook(id, model);
  }

  @override
  Future<void> deleteBook(String id) async {
    await remoteDataSource.deleteBook(id);
  }
}
