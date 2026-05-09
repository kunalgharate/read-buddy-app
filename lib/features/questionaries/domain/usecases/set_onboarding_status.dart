// domain/usecases/set_onboarding_status_usecase.dart
import 'package:read_buddy_app/features/questionaries/domain/repositories/onboarding_repository.dart';

class SetOnboardingStatusUseCase {
  final OnboardingRepository repository;
  SetOnboardingStatusUseCase(this.repository);

  Future<void> call() => repository.setOnboardingStatus();
}
