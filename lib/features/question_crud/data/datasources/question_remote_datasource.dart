import 'package:dio/dio.dart';
import '../models/question_model.dart';
import '../../domain/entities/question_entity.dart';
import '../../../../core/utils/secure_storage_utils.dart';

class QuestionRemoteDataSource {
  final Dio _dio;
  final SecureStorageUtil _storage;
  final String baseUrl = 'https://readbuddy-server.onrender.com/api/onboarding';

  QuestionRemoteDataSource(this._dio, this._storage);

  // GET - Fetch all questions
  Future<List<QuestionEntity>> getQuestions() async {
    try {
      print('🔑 Using token refresh system for getting questions');
      
      // Debug: Check if tokens exist in storage
      final accessToken = await _storage.getAccessToken();
      final refreshToken = await _storage.getRefreshToken();
      print('🔑 Access token exists: ${accessToken != null && accessToken.isNotEmpty}');
      print('🔑 Refresh token exists: ${refreshToken != null && refreshToken.isNotEmpty}');
      
      // Interceptor automatically adds token and handles refresh
      final response = await _dio.get('$baseUrl/questions');
      
      print('✅ API Success: ${response.statusCode}');
      
      List<QuestionEntity> questions = (response.data as List)
          .map((json) => _mapApiToEntity(json))
          .toList();
      
      return questions;
    } catch (e) {
      print('❌ API Error: $e');
      throw Exception('Failed to load questions: $e');
    }
  }

  // POST - Create new question
  Future<void> addQuestion(QuestionEntity question) async {
    try {
      final requestData = {
        'question': question.question,
        'answers': question.options,
        'quesType': question.type == QuestionType.single ? 'singleSelection' : 'multiSelection',
      };

      // Interceptor automatically adds token and handles refresh
      await _dio.post('$baseUrl/question', data: requestData);
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
        'quesType': question.type == QuestionType.single ? 'singleSelection' : 'multiSelection',
      };

      // Interceptor automatically adds token and handles refresh
      await _dio.put('$baseUrl/question/${question.id}', data: requestData);
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  // DELETE - Remove question
  Future<void> deleteQuestion(String id) async {
    try {
      // Interceptor automatically adds token and handles refresh
      await _dio.delete('$baseUrl/question/$id');
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
      type: json['quesType'] == 'singleSelection' ? QuestionType.single : QuestionType.multiple,
    );
  }
}