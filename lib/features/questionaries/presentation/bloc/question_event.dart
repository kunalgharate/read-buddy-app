// lib/features/questionaries/presentation/bloc/question_event.dart

import 'package:equatable/equatable.dart';

abstract class QuestionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadQuestions extends QuestionEvent {}

class SelectAnswer extends QuestionEvent {
  final int questionId;
  final String option;

  SelectAnswer(this.questionId, this.option);

  @override
  List<Object?> get props => [questionId, option];
}

class SubmitAnswers extends QuestionEvent {}
