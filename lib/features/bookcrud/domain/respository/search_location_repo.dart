import 'package:read_buddy_app/features/bookcrud/domain/entities/search_location_entity.dart';

abstract class SearchLocationRepository {
  Future<List<SearchLocationEntity>> getSuggestionsList(String query);
}
