// presentation/cubit/onboarding_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/app_preferences.dart';
import '../../domain/use_cases/get_onboarding_data.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final GetOnboardingQuestionsUseCase getOnboardingQuestionsUseCase;

  OnboardingCubit(this.getOnboardingQuestionsUseCase) : super(OnboardingInitial());

  Future<void> loadQuestions() async {
    emit(OnboardingLoading());
    try {
      final questions = await getOnboardingQuestionsUseCase();
      emit(OnboardingLoaded(questions: questions, answers: {}));
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  void toggleAnswer(int questionId, String option, bool isMulti) {
    if (state is! OnboardingLoaded) return;
    final current = state as OnboardingLoaded;
    final updated = Map<int, List<String>>.from(current.answers);

    if (isMulti) {
      final existing = List<String>.from(updated[questionId] ?? []);
      existing.contains(option) ? existing.remove(option) : existing.add(option);
      updated[questionId] = existing;
    } else {
      updated[questionId] = [option];
    }

    emit(current.copyWith(answers: updated));
  }

  Future<void> next() async {
    if (state is! OnboardingLoaded) return;
    final current = state as OnboardingLoaded;
    if (current.currentIndex < current.questions.length - 1) {
      emit(current.copyWith(currentIndex: current.currentIndex + 1));
    } else {
      await AppPreferences.setLoggedIn(true); // ✅ add this
      emit(OnboardingComplete());
    }
  }

  void previous() {
    if (state is! OnboardingLoaded) return;
    final current = state as OnboardingLoaded;
    if (current.currentIndex > 0) {
      emit(current.copyWith(currentIndex: current.currentIndex - 1));
    }
  }
}