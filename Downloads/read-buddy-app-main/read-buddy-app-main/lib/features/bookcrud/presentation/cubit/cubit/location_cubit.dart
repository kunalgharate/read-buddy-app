import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/search_location_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/search_location.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final SearchLocationUsecase searchLocationUsecase;
  LocationCubit(this.searchLocationUsecase) : super(LocationInitial());

  Future<void> fetchlocations(String query) async {
    emit(LocationLoading());
    try {
      final locationlists = await searchLocationUsecase(query);
      emit(LocationLoaded(locationlists));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}
