import '../entities/question_entity.dart';
import '../repositories/question_repository.dart';

class GetQuestions {
  final QuestionRepository repository;

  GetQuestions(this.repository);

  Future<List<QuestionEntity>> call() {
    return repository.getQuestions();
  }
}
