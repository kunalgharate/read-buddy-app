// domain/repositories/onboarding_repository.dart
import 'package:read_buddy_app/features/questionaries/domain/entity/onboarding_question_entity.dart';

abstract class OnboardingRepository {
  Future<List<QuestionEntity>> getQuestions();
  Future<Map<String, List<String>>> getSavedPreferences();
  Future<void> setPreferences(Map<String, dynamic> preferences);
  Future<void> updatePreferences(Map<String, dynamic> preferences);
  Future<void> deletePreferences();
  Future<void> setOnboardingStatus();
}
