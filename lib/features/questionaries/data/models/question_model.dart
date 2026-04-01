// lib/features/questionaries/data/models/question_model.dart

import '../../domain/entities/question_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.question,
    required super.options,
    required super.type,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      type: json['type'] == 'single'
          ? QuestionType.single
          : QuestionType.multiple,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'type': type == QuestionType.single ? 'single' : 'multiple',
      };
}
