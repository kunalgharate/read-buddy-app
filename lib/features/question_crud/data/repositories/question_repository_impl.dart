import '../../domain/entities/question_entity.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/question_remote_datasource.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionRemoteDataSource dataSource;

  QuestionRepositoryImpl(this.dataSource);

  @override
  Future<List<QuestionEntity>> getQuestions() {
    return dataSource.getQuestions();
  }

  @override
  Future<void> addQuestion(QuestionEntity question) {
    return dataSource.addQuestion(question);
  }

  @override
  Future<void> updateQuestion(QuestionEntity question) {
    return dataSource.updateQuestion(question);
  }

  @override
  Future<void> deleteQuestion(String id) {
    return dataSource.deleteQuestion(id);
  }
}
