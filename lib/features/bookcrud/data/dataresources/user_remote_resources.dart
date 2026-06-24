import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import '../../../../core/network/api_constants.dart';
import 'package:read_buddy_app/core/utils/app_value_items.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/user_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';

abstract class UserRemoteResources {
  Future<List<UserEntity>> getusersList();
  Future<List<UserEntity>> searchUsers(String query);
}

class UserRemoteResourcesImpl extends UserRemoteResources {
  final Dio dio;
  //static const String token =
  // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2ODIwZTA0ZjJkZjg4YzU4ZGIwM2JjMzUiLCJpYXQiOjE3NTA2ODA1MjgsImV4cCI6MTc1MDcwOTMyOH0.ujgcF5MqVseNJg6Rd7MG6OkjnBdroUXYrIc_hdef2Dk";

  UserRemoteResourcesImpl({required this.dio});

  @override
  Future<List<UserEntity>> getusersList() async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final response = await dio.get(ApiConstants.users,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }));
      BookValueItems.usersList.clear();
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load books. Status code: ${response.statusCode}');
      }

      print("📚 users list");
      print(response.data);

      return (response.data as List).map((json) {
        // ✅ Safely extract category object from each book
        final usersJson = json;
        if (usersJson != null) {
          BookValueItems.usersList.add(UserModel.fromJson(usersJson));
        }
        return UserModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      print("❌ Error fetching usrslist: $e");
      print("🔍 StackTrace: $stackTrace");
      rethrow; // rethrowing allows the error to be handled further up the chain (e.g., in Bloc)
    }
  }

  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      print('🔍 Searching users with query: "$query"');
      print('🔍 URL: ${ApiConstants.searchUsers}/$query');

      final response = await dio.get(
        '${ApiConstants.searchUsers}/$query',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('🔍 Search response status: ${response.statusCode}');
      print('🔍 Search response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to search users. Status: ${response.statusCode}');
      }

      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic>) {
        list = data['data'] ?? data['users'] ?? data['results'] ?? [];
      } else {
        list = [];
      }

      print('🔍 Parsed ${list.length} users from response');
      return list.map((json) => UserModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print("❌ Error searching users: $e");
      print("🔍 StackTrace: $stackTrace");
      rethrow;
    }
  }
}
