// lib/features/questionaries/domain/usecases/submit_answers_usecase.dart

import 'dart:convert';
import '../entities/question_entity.dart';

class SubmitAnswersUseCase {
  String call(List<AnswerEntity> answers) {
    final result = answers.map((a) => a.toJson()).toList();
    return jsonEncode(result);
  }
}
