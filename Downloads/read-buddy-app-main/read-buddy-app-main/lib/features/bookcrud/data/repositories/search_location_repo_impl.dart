import 'package:read_buddy_app/features/bookcrud/data/dataresources/search_location_remote_resources.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/search_location_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/search_location_repo.dart';

class SearchLocationRepoImpl extends SearchLocationRepository {
  final SearchLocationRemoteResources searchLocationRemoteResources;

  SearchLocationRepoImpl(this.searchLocationRemoteResources);

  @override
  Future<List<SearchLocationEntity>> getSuggestionsList(String query) async {
    return await searchLocationRemoteResources.getSuggestionsList(query);
  }
}
