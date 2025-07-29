import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/search_location_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/search_location_entity.dart';
import '../../../../core/network/api_constants.dart';
import 'package:read_buddy_app/core/utils/app_value_items.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/user_model.dart';

abstract class SearchLocationRemoteResources {
  Future<List<SearchLocationEntity>> getSuggestionsList(String query);
}

class SearchLocationRemoteResourcesImpl extends SearchLocationRemoteResources {
  final Dio dio;
  SearchLocationRemoteResourcesImpl({required this.dio});

  @override
  Future<List<SearchLocationEntity>> getSuggestionsList(String query) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();

      final response = await dio.get("${ApiConstants.olaMap}=$query",
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }));
      BookValueItems.locationsuggestions.clear();
      print("Ola Map Api   -----$query");
      print(response.data);
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load locations. Status code: ${response.statusCode}');
      } else {
        final List<dynamic> payload = response.data['suggestions'];
        return payload.map((location) {
          BookValueItems.locationsuggestions
              .add(SearchLocationModel.fromJson(location));
          return SearchLocationModel.fromJson(location);
        }).toList();
      }
    } catch (e, stackTrace) {
      print("❌ Error fetching usrslist: $e");
      print("🔍 StackTrace: $stackTrace");
      rethrow; // rethrowing allows the error to be handled further up the chain (e.g., in Bloc)
    }
  }
}
