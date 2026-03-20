import '../../domain/entities/question_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.question,
    required super.options,
    required super.type,
  });

  factory QuestionModel.fromEntity(QuestionEntity entity) {
    return QuestionModel(
      id: entity.id,
      question: entity.question,
      options: entity.options,
      type: entity.type,
    );
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['answers'] ?? []),
      type: json['quesType'] == 'singleSelection' ? QuestionType.single : QuestionType.multiple,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answers': options,
      'quesType': type == QuestionType.single ? 'singleSelection' : 'multiSelection',
    };
  }
}