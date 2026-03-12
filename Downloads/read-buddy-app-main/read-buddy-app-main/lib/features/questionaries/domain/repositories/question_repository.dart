// lib/features/questionaries/domain/repositories/question_repository.dart

import '../entities/question_entity.dart';

abstract class QuestionRepository {
  List<QuestionEntity> getQuestions();
}
