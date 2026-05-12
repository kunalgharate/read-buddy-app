import '../entities/question_entity.dart';
import '../repositories/question_repository.dart';

class UpdateQuestion {
  final QuestionRepository repository;

  UpdateQuestion(this.repository);

  Future<void> call(QuestionEntity question) {
    return repository.updateQuestion(question);
  }
}
