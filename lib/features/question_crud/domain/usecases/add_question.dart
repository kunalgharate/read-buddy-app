import '../entities/question_entity.dart';
import '../repositories/question_repository.dart';

class AddQuestion {
  final QuestionRepository repository;

  AddQuestion(this.repository);

  Future<void> call(QuestionEntity question) {
    return repository.addQuestion(question);
  }
}
