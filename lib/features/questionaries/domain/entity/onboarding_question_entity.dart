// questionaries/domain/entities/question_entity.dart

enum QuestionType { singleSelection, multiSelection }

class QuestionEntity {
  final String id;
  final String question;
  final List<String> answers;
  final QuestionType quesType;

  const QuestionEntity({
    required this.id,
    required this.question,
    required this.answers,
    required this.quesType,
  });
}