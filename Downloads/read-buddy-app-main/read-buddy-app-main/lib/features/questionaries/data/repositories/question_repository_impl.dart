// lib/features/questionaries/data/repositories/question_repository_impl.dart

import '../../domain/entities/question_entity.dart';
import '../../domain/repositories/question_repository.dart';
import '../questions_data_source.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionLocalDataSource dataSource;

  QuestionRepositoryImpl(this.dataSource);

  @override
  List<QuestionEntity> getQuestions() => dataSource.getQuestions();
}
