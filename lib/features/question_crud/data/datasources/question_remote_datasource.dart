import 'package:dio/dio.dart';
import '../../domain/entities/question_entity.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../../core/network/api_constants.dart';

class QuestionRemoteDataSource {
  final Dio _dio;
  final SecureStorageUtil _storage;
  final String baseUrl = ApiConstants.onboarding;

  QuestionRemoteDataSource(this._dio, this._storage);

  Future<Options> get _authOptions async {
    final token = await _storage.getAccessToken() ?? '';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // GET - Fetch all questions (no auth needed)
  Future<List<QuestionEntity>> getQuestions() async {
    try {
      final response = await _dio.get('$baseUrl/questions');

      List<QuestionEntity> questions =
          (response.data as List).map((json) => _mapApiToEntity(json)).toList();

      return questions;
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  // POST - Create new question
  Future<void> addQuestion(QuestionEntity question) async {
    try {
      final requestData = {
        'question': question.question,
        'answers': question.options,
        'quesType': question.type == QuestionType.single
            ? 'singleSelection'
            : 'multiSelection',
      };

      await _dio.post('$baseUrl/question',
          data: requestData, options: await _authOptions);
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  // PUT - Update existing question
  Future<void> updateQuestion(QuestionEntity question) async {
    try {
      final requestData = {
        'question': question.question,
        'answers': question.options,
        'quesType': question.type == QuestionType.single
            ? 'singleSelection'
            : 'multiSelection',
      };

      await _dio.put('$baseUrl/question/${question.id}',
          data: requestData, options: await _authOptions);
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  // DELETE - Remove question
  Future<void> deleteQuestion(String id) async {
    try {
      await _dio.delete('$baseUrl/question/$id', options: await _authOptions);
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  // Helper method to map API response to QuestionEntity
  QuestionEntity _mapApiToEntity(Map<String, dynamic> json) {
    return QuestionEntity(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['answers'] ?? []),
      type: json['quesType'] == 'singleSelection'
          ? QuestionType.single
          : QuestionType.multiple,
    );
  }
}
