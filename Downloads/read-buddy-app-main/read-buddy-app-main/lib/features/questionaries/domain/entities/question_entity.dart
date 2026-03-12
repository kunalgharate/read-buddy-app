// lib/features/questionaries/domain/entities/question_entity.dart

import 'package:equatable/equatable.dart';

enum QuestionType { single, multiple }

class QuestionEntity extends Equatable {
  final int id;
  final String question;
  final List<String> options;
  final QuestionType type;

  const QuestionEntity({
    required this.id,
    required this.question,
    required this.options,
    required this.type,
  });

  @override
  List<Object?> get props => [id, question, options, type];
}

class AnswerEntity extends Equatable {
  final int questionId;
  final List<String> selectedOptions;

  const AnswerEntity({
    required this.questionId,
    required this.selectedOptions,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedOptions': selectedOptions,
      };

  @override
  List<Object?> get props => [questionId, selectedOptions];
}
