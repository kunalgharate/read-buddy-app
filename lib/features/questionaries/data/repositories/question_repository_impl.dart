// data/repositories/onboarding_repository_impl.dart
import '../../domain/entity/onboarding_question_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<QuestionEntity>> getQuestions() =>
      remoteDataSource.getQuestions();

  @override
  Future<Map<String, List<String>>> getSavedPreferences() =>
      remoteDataSource.getSavedPreferences();

  @override
  Future<void> setPreferences(Map<String, dynamic> preferences) =>
      remoteDataSource.setPreferences(preferences);

  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) =>
      remoteDataSource.updatePreferences(preferences);

  @override
  Future<void> deletePreferences() => remoteDataSource.deletePreferences();

  @override
  Future<void> setOnboardingStatus() => remoteDataSource.setOnboardingStatus();
}
