// import '../models/question_model.dart';
// import '../../domain/entities/question_entity.dart';
//
// class QuestionLocalDataSource {
//   List<QuestionEntity> _questions = [
//     const QuestionEntity(
//       id: 1,
//       question: 'What genres do you enjoy reading?',
//       options: ['Fiction', 'Non-Fiction', 'Mystery', 'Romance', 'Sci-Fi', 'Biography'],
//       type: QuestionType.multiple,
//     ),
//     const QuestionEntity(
//       id: 2,
//       question: 'How often do you read?',
//       options: ['Daily', 'Weekly', 'Monthly', 'Occasionally'],
//       type: QuestionType.single,
//     ),
//     const QuestionEntity(
//       id: 3,
//       question: 'What format do you prefer?',
//       options: ['Physical Books', 'E-books', 'Audiobooks', 'All formats'],
//       type: QuestionType.single,
//     ),
//     const QuestionEntity(
//       id: 4,
//       question: 'When do you prefer to read?',
//       options: ['Morning', 'Afternoon', 'Evening', 'Night', 'Anytime'],
//       type: QuestionType.multiple,
//     ),
//     const QuestionEntity(
//       id: 5,
//       question: 'How many pages do you read per day?',
//       options: ['Less than 20', '20-50', '50-100', 'More than 100'],
//       type: QuestionType.single,
//     ),
//   ];
//
//   Future<List<QuestionEntity>> getQuestions() async {
//     return _questions;
//   }
//
//   Future<void> addQuestion(QuestionEntity question) async {
//     _questions.add(question);
//   }
//
//   Future<void> updateQuestion(QuestionEntity question) async {
//     int index = _questions.indexWhere((q) => q.id == question.id);
//     if (index != -1) {
//       _questions[index] = question;
//     }
//   }
//
//   Future<void> deleteQuestion(int id) async {
//     _questions.removeWhere((q) => q.id == id);
//   }
// }