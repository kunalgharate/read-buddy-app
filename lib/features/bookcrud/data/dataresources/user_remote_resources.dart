import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/utils/book_value_items.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/user_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';

abstract class UserRemoteResources {
  Future<List<UserEntity>> getusersList();
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
      final response = await dio.get(Api.userslist,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }));

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
}
