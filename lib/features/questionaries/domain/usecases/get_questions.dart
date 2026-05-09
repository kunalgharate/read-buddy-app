// domain/usecases/get_questions_usecase.dart

import 'package:read_buddy_app/features/questionaries/domain/entity/onboarding_question_entity.dart';
import 'package:read_buddy_app/features/questionaries/domain/repositories/onboarding_repository.dart';

class GetQuestionsUseCase {
  final OnboardingRepository repository;
  GetQuestionsUseCase(this.repository);

  Future<List<QuestionEntity>> call() => repository.getQuestions();
}
