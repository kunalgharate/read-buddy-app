import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import '../models/video_course_model.dart';

abstract class VideoCourseRemoteDataSource {
  Future<List<VideoCourseModel>> getCourses({
    String? category,
    String? search,
    int? page,
  });
  Future<VideoCourseModel> getCourseById(String id);
  Future<VideoLessonModel> getLesson({
    required String courseId,
    required String lessonId,
  });
  Future<void> enrolInCourse(String courseId);
  Future<void> updateLessonProgress({
    required String courseId,
    required String lessonId,
    required int watchedSeconds,
    required bool completed,
  });
}

class VideoCourseRemoteDataSourceImpl implements VideoCourseRemoteDataSource {
  final Dio _dio;

  VideoCourseRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  static String get _basePath => '${ApiConstants.baseUrl}/video-courses';

  @override
  Future<List<VideoCourseModel>> getCourses({
    String? category,
    String? search,
    int? page,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (page != null) {
      queryParams['page'] = page;
    }

    final response = await _dio.get(
      _basePath,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data;

    final List list;
    if (data is List) {
      list = data;
    } else if (data is Map && data.containsKey('data')) {
      list = data['data'] as List;
    } else if (data is Map && data.containsKey('courses')) {
      list = data['courses'] as List;
    } else {
      list = [];
    }

    return list
        .map((json) => VideoCourseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<VideoCourseModel> getCourseById(String id) async {
    final response = await _dio.get('$_basePath/$id');
    final data = response.data;

    final Map<String, dynamic> courseJson;
    if (data is Map && data.containsKey('data')) {
      courseJson = data['data'] as Map<String, dynamic>;
    } else if (data is Map && data.containsKey('course')) {
      courseJson = data['course'] as Map<String, dynamic>;
    } else {
      courseJson = data as Map<String, dynamic>;
    }

    return VideoCourseModel.fromJson(courseJson);
  }

  @override
  Future<VideoLessonModel> getLesson({
    required String courseId,
    required String lessonId,
  }) async {
    final response = await _dio.get('$_basePath/$courseId/lessons/$lessonId');
    final data = response.data;

    final Map<String, dynamic> lessonJson;
    if (data is Map && data.containsKey('data')) {
      lessonJson = data['data'] as Map<String, dynamic>;
    } else if (data is Map && data.containsKey('lesson')) {
      lessonJson = data['lesson'] as Map<String, dynamic>;
    } else {
      lessonJson = data as Map<String, dynamic>;
    }

    return VideoLessonModel.fromJson(lessonJson);
  }

  @override
  Future<void> enrolInCourse(String courseId) async {
    await _dio.post('$_basePath/$courseId/enrol');
  }

  @override
  Future<void> updateLessonProgress({
    required String courseId,
    required String lessonId,
    required int watchedSeconds,
    required bool completed,
  }) async {
    await _dio.patch(
      '$_basePath/$courseId/lessons/$lessonId/progress',
      data: {
        'watchedSeconds': watchedSeconds,
        'completed': completed,
      },
    );
  }
}
