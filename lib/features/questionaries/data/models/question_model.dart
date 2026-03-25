// onboarding/data/model/onboarding_question_model.dart

import '../../domain/entity/onboarding_question_entity.dart'; // ← correct import

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.question,
    required super.answers,
    required super.quesType,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'] ?? '',
      question: json['question'] ?? '',
      answers: List<String>.from(json['answers'] ?? []),
      quesType: json['quesType'] == 'singleSelection'
          ? QuestionType.singleSelection
          : QuestionType.multiSelection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'question': question,
      'answers': answers,
      'quesType': quesType == QuestionType.singleSelection
          ? 'singleSelection'
          : 'multiSelection',
    };
  }
}