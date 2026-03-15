// domain/use_cases/get_onboarding_data.dart
import '../entities/onboarding_question_entity.dart';
import '../repositories/onboarding_repository.dart';

class GetOnboardingQuestionsUseCase {
  final OnboardingRepository repository;

  GetOnboardingQuestionsUseCase(this.repository);

  Future<List<OnboardingQuestionEntity>> call() {
    return repository.getQuestions();
  }
}