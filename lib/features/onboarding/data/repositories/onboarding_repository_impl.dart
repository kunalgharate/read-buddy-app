// data/repositories/onboarding_repository_impl.dart
import '../../domain/entities/onboarding_question_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../remotesource/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource dataSource;

  OnboardingRepositoryImpl(this.dataSource);

  @override
  Future<List<OnboardingQuestionEntity>> getQuestions() {
    return dataSource.getQuestions();
  }
}