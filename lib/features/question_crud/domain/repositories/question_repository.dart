import '../entities/question_entity.dart';

abstract class QuestionRepository {
  Future<List<QuestionEntity>> getQuestions();
  Future<void> addQuestion(QuestionEntity question);
  Future<void> updateQuestion(QuestionEntity question);
  Future<void> deleteQuestion(String id);
}
