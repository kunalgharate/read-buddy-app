
import '../domain/entities/question_entity.dart';
import 'models/question_model.dart';

abstract class QuestionLocalDataSource {
  List<QuestionModel> getQuestions();
}

class QuestionLocalDataSourceImpl implements QuestionLocalDataSource {
  @override
  List<QuestionModel> getQuestions() {
    return [
      const QuestionModel(
        id: 1,
        question: 'What type of books do you enjoy reading the most?',
        options: [
          'Fiction',
          'Non-Fiction',
          'Fantasy',
          'Mystery & Thriller',
          'Business & Productivity',
          'Biographies',
          'Self Help',
        ],
        type: QuestionType.multiple,
      ),
      const QuestionModel(
        id: 2,
        question: 'How often do you read books?',
        options: [
          'Daily',
          'A few times a week',
          'Occasionally',
          'Rarely',
        ],
        type: QuestionType.single,
      ),
      const QuestionModel(
        id: 3,
        question: 'What is your preferred reading format?',
        options: [
          'E-books',
          'Physical books',
          'Audiobooks',
          'A mix of all three',
        ],
        type: QuestionType.multiple,
      ),
      const QuestionModel(
        id: 4,
        question: 'When do you usually read?',
        options: [
          'Morning',
          'Afternoon',
          'Night',
          'During commutes',
          'Before bed',
        ],
        type: QuestionType.multiple,
      ),
      const QuestionModel(
        id: 5,
        question: 'How many pages do you usually read in a day?',
        options: [
          'Less than 10 pages',
          '10 - 20 pages',
          '20 - 40 pages',
          'More than 40 pages',
        ],
        type: QuestionType.single,
      ),
    ];
  }
}
