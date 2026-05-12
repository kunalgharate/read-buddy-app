// domain/usecases/get_questions_usecase.dart

import '../entity/onboarding_question_entity.dart';
import '../repositories/onboarding_repository.dart';

class GetQuestionsUseCase {
  final OnboardingRepository repository;
  GetQuestionsUseCase(this.repository);

  Future<List<QuestionEntity>> call() => repository.getQuestions();
}
