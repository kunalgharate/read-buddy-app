// domain/usecases/set_preferences_usecase.dart
import '../repositories/onboarding_repository.dart';

class SetPreferencesUseCase {
  final OnboardingRepository repository;
  SetPreferencesUseCase(this.repository);

  Future<void> call(Map<String, dynamic> preferences) =>
      repository.setPreferences(preferences);
}
