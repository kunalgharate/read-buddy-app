import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';

/// Minimal service to submit a book report/concern to the backend.
/// The backend notifies all admins immediately.
class BookReportService {
  final Dio _dio;
  BookReportService({required Dio dio}) : _dio = dio;

  Future<void> report({
    required String bookId,
    required String reason, // copyright | inappropriate | incorrect_info | broken_content | other
    String? details,
    String? contactEmail,
  }) async {
    await _dio.post(
      '${ApiConstants.baseUrl}/book-reports',
      data: {
        'bookId': bookId,
        'reason': reason,
        if (details != null && details.isNotEmpty) 'details': details,
        if (contactEmail != null && contactEmail.isNotEmpty)
          'contactEmail': contactEmail,
      },
    );
  }
}
