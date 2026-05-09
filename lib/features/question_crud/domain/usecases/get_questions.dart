import 'package:read_buddy_app/features/question_crud/domain/entities/question_entity.dart';
import 'package:read_buddy_app/features/question_crud/domain/repositories/question_repository.dart';

class GetQuestions {
  final QuestionRepository repository;

  GetQuestions(this.repository);

  Future<List<QuestionEntity>> call() {
    return repository.getQuestions();
  }
}
