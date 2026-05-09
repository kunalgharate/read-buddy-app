import 'package:read_buddy_app/features/question_crud/domain/repositories/question_repository.dart';

class DeleteQuestion {
  final QuestionRepository repository;

  DeleteQuestion(this.repository);

  Future<void> call(String id) {
    return repository.deleteQuestion(id);
  }
}
