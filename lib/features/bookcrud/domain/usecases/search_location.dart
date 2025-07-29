import 'package:read_buddy_app/features/bookcrud/domain/entities/search_location_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/search_location_repo.dart';

class SearchLocationUsecase {
  final SearchLocationRepository searchLocationRepository;

  SearchLocationUsecase(this.searchLocationRepository);

  Future<List<SearchLocationEntity>> call(String query) {
    return searchLocationRepository.getSuggestionsList(query);
  }
}
