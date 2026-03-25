// presentation/bloc/onboarding_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/preferences_model.dart';
import '../../domain/entity/onboarding_question_entity.dart';
import '../../domain/usecases/delete_user_preferences.dart';
import '../../domain/usecases/get_questions.dart';
import '../../domain/usecases/set_onboarding_status.dart';
import '../../domain/usecases/set_preferences.dart';
import '../../domain/usecases/update_user_preferences.dart';
import 'on_boarding_event.dart';
import 'on_boarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetQuestionsUseCase getQuestionsUseCase;
  final SetPreferencesUseCase setPreferencesUseCase;
  final UpdatePreferencesUseCase updatePreferencesUseCase;
  final DeletePreferencesUseCase deletePreferencesUseCase;
  final SetOnboardingStatusUseCase setOnboardingStatusUseCase;

  OnboardingBloc({
    required this.getQuestionsUseCase,
    required this.setPreferencesUseCase,
    required this.updatePreferencesUseCase,
    required this.deletePreferencesUseCase,
    required this.setOnboardingStatusUseCase,
  }) : super(OnboardingInitial()) {

    on<FetchQuestionsEvent>(_onFetchQuestions);
    on<SelectAnswerEvent>(_onSelectAnswer);
    on<NextQuestionEvent>(_onNextQuestion);
    on<PreviousQuestionEvent>(_onPreviousQuestion);
    on<SubmitPreferencesEvent>(_onSubmitPreferences);
    on<UpdatePreferencesEvent>(_onUpdatePreferences);
    on<DeletePreferencesEvent>(_onDeletePreferences);
  }

  Future<void> _onFetchQuestions(
      FetchQuestionsEvent event,
      Emitter<OnboardingState> emit,
      ) async {
    emit(OnboardingLoading());
    try {
      final questions = await getQuestionsUseCase();
      emit(OnboardingQuestionsLoaded(
        questions: questions,
        currentIndex: 0,
        answers: {},
      ));
    } catch (e) {
      emit(OnboardingError('Failed to load questions: ${e.toString()}'));
    }
  }

  void _onSelectAnswer(
      SelectAnswerEvent event,
      Emitter<OnboardingState> emit,
      ) {
    if (state is! OnboardingQuestionsLoaded) return;
    final current = state as OnboardingQuestionsLoaded;

    final updatedAnswers = Map<String, List<String>>.from(current.answers);
    final questionId = event.question.id;
    final selected = updatedAnswers[questionId] ?? [];

    if (event.question.quesType == QuestionType.singleSelection) {
      // Replace selection
      updatedAnswers[questionId] = [event.answer];
    } else {
      // Toggle for multi-selection
      if (selected.contains(event.answer)) {
        updatedAnswers[questionId] = selected
            .where((a) => a != event.answer)
            .toList();
      } else {
        updatedAnswers[questionId] = [...selected, event.answer];
      }
    }

    emit(current.copyWith(answers: updatedAnswers));
  }

  void _onNextQuestion(
      NextQuestionEvent event,
      Emitter<OnboardingState> emit,
      ) {
    if (state is! OnboardingQuestionsLoaded) return;
    final current = state as OnboardingQuestionsLoaded;
    if (current.isLastQuestion) return;
    emit(current.copyWith(currentIndex: current.currentIndex + 1));
  }

  void _onPreviousQuestion(
      PreviousQuestionEvent event,
      Emitter<OnboardingState> emit,
      ) {
    if (state is! OnboardingQuestionsLoaded) return;
    final current = state as OnboardingQuestionsLoaded;
    if (current.isFirstQuestion) return;
    emit(current.copyWith(currentIndex: current.currentIndex - 1));
  }

  Future<void> _onSubmitPreferences(
      SubmitPreferencesEvent event,
      Emitter<OnboardingState> emit,
      ) async {
    if (state is! OnboardingQuestionsLoaded) return;
    final current = state as OnboardingQuestionsLoaded;

    emit(OnboardingSubmitting());
    try {
      final preferenceBody = _buildPreferenceBody(
        current.questions,
        current.answers,
      );

      // 1. Submit preferences
      await setPreferencesUseCase(preferenceBody);

      // 2. Mark onboarding complete
      await setOnboardingStatusUseCase();

      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError('Submission failed: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePreferences(
      UpdatePreferencesEvent event,
      Emitter<OnboardingState> emit,
      ) async {
    if (state is! OnboardingQuestionsLoaded) return;
    final current = state as OnboardingQuestionsLoaded;

    emit(OnboardingSubmitting());
    try {
      final preferenceBody = _buildPreferenceBody(
        current.questions,
        current.answers,
      );
      await updatePreferencesUseCase(preferenceBody);
      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError('Update failed: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePreferences(
      DeletePreferencesEvent event,
      Emitter<OnboardingState> emit,
      ) async {
    emit(OnboardingSubmitting());
    try {
      await deletePreferencesUseCase();
      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError('Delete failed: ${e.toString()}'));
    }
  }

  /// Maps collected answers to the preference body shape
  Map<String, dynamic> _buildPreferenceBody(
      List<QuestionEntity> questions,
      Map<String, List<String>> answers,
      ) {
    List<String> genres = [];
    List<String> formats = [];
    List<String> preferredTimes = [];

    for (final question in questions) {
      final q = question.question.toLowerCase();
      final selected = answers[question.id] ?? [];
      if (selected.isEmpty) continue;

      if (q.contains('format')) {
        formats = selected;
      } else if (q.contains('when') || q.contains('time')) {
        preferredTimes = selected;
      } else if (q.contains('type') ||
          q.contains('genre') ||
          q.contains('enjoy')) {
        genres = [...genres, ...selected];
      }
      // Language question is intentionally skipped — not in preference body
    }

    return PreferenceModel(
      genres: genres,
      formats: formats,
      preferredTimes: preferredTimes,
    ).toJson();
  }
}