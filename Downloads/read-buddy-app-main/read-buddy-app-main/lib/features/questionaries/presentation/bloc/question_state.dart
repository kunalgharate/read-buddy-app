// lib/features/questionaries/presentation/bloc/question_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/question_entity.dart';

abstract class QuestionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QuestionInitial extends QuestionState {}

class QuestionLoaded extends QuestionState {
  final List<QuestionEntity> questions;
  final Map<int, List<String>> answers;

  QuestionLoaded(this.questions, this.answers);

  @override
  List<Object?> get props => [questions, answers];
}

class QuestionSubmitted extends QuestionState {
  final String jsonResult;

  QuestionSubmitted(this.jsonResult);

  @override
  List<Object?> get props => [jsonResult];
}
