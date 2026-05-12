import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/update_user_avatar.dart';

part 'profile_event.dart';
part 'profile_state.dart';

enum PhotoSource { camera, gallery }

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SecureStorageUtil _secureStorage;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateAvatarUseCase _updateAvatarUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileBloc(
    this._secureStorage,
    this._getProfileUseCase,
    this._updateAvatarUseCase,
    this._updateProfileUseCase,
  ) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateAvatarEvent>(_onUpdateAvatar);
    on<UpdateProfileFieldEvent>(_onUpdateProfileField);
    on<RefreshProfileEvent>(_onRefreshProfile);
  }

  // ─── GET /users/profile ───────────────────────────────────────────────────

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profileUser = await _getProfileUseCase.call();
      emit(ProfileLoaded(profileUser));
    } catch (error) {
      // Fallback to cached AppUser from secure storage
      try {
        final cachedUser = await _secureStorage.getUser();
        if (cachedUser != null) {
          emit(ProfileLoaded(_appUserToProfileUser(cachedUser)));
        } else {
          emit(ProfileError(ErrorHandler.getErrorMessage(error)));
        }
      } catch (_) {
        emit(ProfileError(ErrorHandler.getErrorMessage(error)));
      }
    }
  }

  // ─── PATCH /users/update-avatar ───────────────────────────────────────────

  Future<void> _onUpdateAvatar(
    UpdateAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _currentUser();
    if (currentUser == null) return;

    emit(ProfileUpdating(currentUser));
    try {
      final updatedUser = await _updateAvatarUseCase.call(event.avatarName);
      emit(AvatarUpdateSuccess(updatedUser));
      emit(ProfileLoaded(updatedUser));
    } catch (error) {
      emit(ProfileError(ErrorHandler.getErrorMessage(error)));
      emit(ProfileLoaded(currentUser));
    }
  }

  // ─── PUT /users/update-user-info ──────────────────────────────────────────

  Future<void> _onUpdateProfileField(
    UpdateProfileFieldEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _currentUser();
    if (currentUser == null) return;

    emit(ProfileUpdating(currentUser));
    try {
      final profileData = _validateInputs(key: event.field, value: event.value);
      if (profileData['error'] != null) {
        emit(ProfileError(profileData['error']!));
        emit(ProfileLoaded(currentUser));
        return;
      }
      profileData.remove('error');

      final updatedAppUser =
          await _updateProfileUseCase.call(profileData: profileData);
      await _secureStorage.saveUser(updatedAppUser);

      // Re-fetch full profile after update to stay in sync
      add(LoadProfileEvent());
    } catch (error) {
      emit(ProfileError(ErrorHandler.getErrorMessage(error)));
      emit(ProfileLoaded(currentUser));
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    add(LoadProfileEvent());
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  ProfileUser? _currentUser() {
    if (state is ProfileLoaded) return (state as ProfileLoaded).user;
    if (state is ProfileUpdating) return (state as ProfileUpdating).user;
    if (state is AvatarUpdateSuccess) {
      return (state as AvatarUpdateSuccess).user;
    }
    return null;
  }

  /// Maps a cached [AppUser] → [ProfileUser] as fallback when API is unavailable
  ProfileUser _appUserToProfileUser(AppUser u) {
    return ProfileUser(
      id: u.id,
      name: u.name,
      email: u.email,
      phno: u.phno,
      picture: u.picture,
      userAvatar: u.userAvatar,
      role: u.role,
      isPrime: u.isPrime,
      finesDue: u.finesDue,
      isEmailVerified: u.isEmailVerified,
      onboardingCompleted: u.onboardingCompleted,
      badges: u.badges,
      wishlist: u.wishlist ?? [],
      createdAt: u.createdAt,
      updatedAt: u.updatedAt,
    );
  }

  Map<String, String> _validateInputs({String? key, String? value}) {
    if (key == null || value == null) {
      return {'error': 'Key and value are required'};
    }

    switch (key.toLowerCase()) {
      case 'name':
        if (value.trim().length < 2) {
          return {'error': 'Name must be at least 2 characters long'};
        }
        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
          return {'error': 'Name can only contain letters and spaces'};
        }
        return {'name': value.trim()};

      case 'phno':
        if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
          return {'error': 'Phone number must be exactly 10 digits'};
        }
        return {'phno': value.trim()};

      case 'email':
        return {
          'error':
              'Email address cannot be changed. It\'s your primary account identifier.'
        };

      case 'gender':
        const validGenders = ['male', 'female', 'other', 'rather not to say'];
        if (!validGenders.contains(value.toLowerCase())) {
          return {'error': 'Invalid gender selection'};
        }
        return {'gender': value.toLowerCase()};

      case 'dob':
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
          return {'error': 'Date of birth must be in YYYY-MM-DD format'};
        }
        try {
          DateTime.parse(value);
          return {'dob': value};
        } catch (_) {
          return {'error': 'Invalid date format'};
        }

      default:
        return {'error': 'Invalid field key'};
    }
  }
}
