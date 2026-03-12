// test/features/questionaries/domain/usecases/get_questions_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/features/questionaries/domain/entities/question_entity.dart';
import 'package:read_buddy_app/features/questionaries/domain/repositories/question_repository.dart';
import 'package:read_buddy_app/features/questionaries/domain/usecases/get_questions_usecase.dart';

class MockQuestionRepository implements QuestionRepository {
  @override
  List<QuestionEntity> getQuestions() {
    return [
      const QuestionEntity(
        id: 1,
        question: 'Test Question?',
        options: ['Option 1', 'Option 2'],
        type: QuestionType.single,
      ),
    ];
  }
}

void main() {
  late GetQuestionsUseCase useCase;
  late MockQuestionRepository repository;

  setUp(() {
    repository = MockQuestionRepository();
    useCase = GetQuestionsUseCase(repository);
  });

  test('should return list of questions from repository', () {
    final result = useCase();
    expect(result, isA<List<QuestionEntity>>());
    expect(result.length, 1);
    expect(result.first.question, 'Test Question?');
  });
}
