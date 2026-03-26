// domain/usecases/delete_preferences_usecase.dart
import '../repositories/onboarding_repository.dart';

class DeletePreferencesUseCase {
  final OnboardingRepository repository;
  DeletePreferencesUseCase(this.repository);

  Future<void> call() => repository.deletePreferences();
}
