import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/core/services/storage_service.dart';

part 'app_start_event.dart';
part 'app_start_state.dart';

@injectable
class AppStartBloc extends Bloc<AppStartEvent, AppStartState> {
  final StorageService storageService;

  AppStartBloc(this.storageService) : super(AppStartInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AppStartState> emit,
  ) async {
    final token = await storageService.getToken();

    if (token != null && token.isNotEmpty) {
      emit(UserLoggedIn());
    } else {
      emit(UserLoggedOut());
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AppStartState> emit) async {
    await storageService.clearToken();
    emit(UserLoggedOut());
  }
}
