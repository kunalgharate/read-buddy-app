// domain/usecases/update_preferences_usecase.dart
import 'package:read_buddy_app/features/questionaries/domain/repositories/onboarding_repository.dart';

class UpdatePreferencesUseCase {
  final OnboardingRepository repository;
  UpdatePreferencesUseCase(this.repository);

  Future<void> call(Map<String, dynamic> preferences) =>
      repository.updatePreferences(preferences);
}
