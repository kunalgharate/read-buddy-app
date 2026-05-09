import 'package:read_buddy_app/features/question_crud/domain/entities/question_entity.dart';
import 'package:read_buddy_app/features/question_crud/domain/repositories/question_repository.dart';

class AddQuestion {
  final QuestionRepository repository;

  AddQuestion(this.repository);

  Future<void> call(QuestionEntity question) {
    return repository.addQuestion(question);
  }
}
