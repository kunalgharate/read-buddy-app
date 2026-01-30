// lib/features/questionaries/presentation/bloc/question_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/usecases/get_questions_usecase.dart';
import '../../domain/usecases/submit_answers_usecase.dart';
import 'question_event.dart';
import 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final GetQuestionsUseCase getQuestions;
  final SubmitAnswersUseCase submitAnswers;

  QuestionBloc({
    required this.getQuestions,
    required this.submitAnswers,
  }) : super(QuestionInitial()) {
    on<LoadQuestions>(_onLoadQuestions);
    on<SelectAnswer>(_onSelectAnswer);
    on<SubmitAnswers>(_onSubmitAnswers);
  }

  void _onLoadQuestions(LoadQuestions event, Emitter<QuestionState> emit) {
    final questions = getQuestions();
    emit(QuestionLoaded(questions, {}));
  }

  void _onSelectAnswer(SelectAnswer event, Emitter<QuestionState> emit) {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final question = currentState.questions.firstWhere((q) => q.id == event.questionId);
      final updatedAnswers = Map<int, List<String>>.from(currentState.answers);

      if (question.type == QuestionType.single) {
        updatedAnswers[event.questionId] = [event.option];
      } else {
        final current = updatedAnswers[event.questionId] ?? [];
        if (current.contains(event.option)) {
          updatedAnswers[event.questionId] = current.where((o) => o != event.option).toList();
        } else {
          updatedAnswers[event.questionId] = [...current, event.option];
        }
      }

      emit(QuestionLoaded(currentState.questions, updatedAnswers));
    }
  }

  void _onSubmitAnswers(SubmitAnswers event, Emitter<QuestionState> emit) {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final answerEntities = currentState.answers.entries
          .map((e) => AnswerEntity(questionId: e.key, selectedOptions: e.value))
          .toList();
      final json = submitAnswers(answerEntities);
      emit(QuestionSubmitted(json));
    }
  }
}
