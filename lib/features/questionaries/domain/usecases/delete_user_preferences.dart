// domain/usecases/delete_preferences_usecase.dart
import 'package:read_buddy_app/features/questionaries/domain/repositories/onboarding_repository.dart';

class DeletePreferencesUseCase {
  final OnboardingRepository repository;
  DeletePreferencesUseCase(this.repository);

  Future<void> call() => repository.deletePreferences();
}
