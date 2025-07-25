import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(ReviewRemoteDataSource reviewRemoteDataSource,
      {required this.remoteDataSource});

  @override
  Future<List<ReviewEntity>> getReviews(String bookId) async {
    final reviewModels = await remoteDataSource.fetchReviews(bookId);
    return reviewModels;
  }
}
