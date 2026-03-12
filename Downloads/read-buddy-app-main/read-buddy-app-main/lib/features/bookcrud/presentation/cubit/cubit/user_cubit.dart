import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/user_listcase.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetUserListUseCase getUserListUseCase;

  UserCubit(this.getUserListUseCase) : super(UserInitial());

  Future<void> fetchUsers() async {
    emit(UserLoading());
    try {
      final users = await getUserListUseCase();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
