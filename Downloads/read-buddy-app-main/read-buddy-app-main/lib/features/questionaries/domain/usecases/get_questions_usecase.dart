// lib/features/questionaries/domain/usecases/get_questions_usecase.dart

import '../entities/question_entity.dart';
import '../repositories/question_repository.dart';

class GetQuestionsUseCase {
  final QuestionRepository repository;

  GetQuestionsUseCase(this.repository);

  List<QuestionEntity> call() => repository.getQuestions();
}
