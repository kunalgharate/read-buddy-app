import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

enum PhotoSource { camera, gallery }

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SecureStorageUtil _secureStorage;
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileBloc(
    this._secureStorage,
    this._updateProfileUseCase,
  ) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileFieldEvent>(_onUpdateProfileField);
    on<UpdateProfileApiEvent>(_onUpdateProfileApi);
    on<UpdateProfilePhotoEvent>(_onUpdateProfilePhoto);
    on<RefreshProfileEvent>(_onRefreshProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    try {
      final user = await _secureStorage.getUser();
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(const ProfileError('No user data found. Please login again.'));
      }
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      emit(ProfileError(errorMessage));
    }
  }

  Future<void> _onUpdateProfileField(
    UpdateProfileFieldEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    
    final currentState = state as ProfileLoaded;
    emit(ProfileUpdating(currentState.user));
    
    try {
      // Create updated user object
      final updatedUser = _updateUserField(currentState.user, event.field, event.value);
      
      // Save to secure storage
      await _secureStorage.saveUser(updatedUser);
      
      // TODO: Also update on server via API call
      // await _profileRepository.updateProfile(updatedUser);
      
      emit(ProfileUpdated(updatedUser));
      emit(ProfileLoaded(updatedUser));
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      emit(ProfileError(errorMessage));
      emit(ProfileLoaded(currentState.user)); // Revert to previous state
    }
  }

  Future<void> _onUpdateProfileApi(
    UpdateProfileApiEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    
    final currentState = state as ProfileLoaded;
    emit(ProfileUpdating(currentState.user));
    
    try {
      // Call API to update profile
      final updatedUser = await _updateProfileUseCase.call(
        name: event.name,
        phno: event.phno,
        gender: event.gender,
        dob: event.dob,
        picture: event.picture,
      );
      
      // Save updated user to secure storage
      await _secureStorage.saveUser(updatedUser);
      
      emit(ProfileUpdated(updatedUser));
      emit(ProfileLoaded(updatedUser));
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      emit(ProfileError(errorMessage));
      emit(ProfileLoaded(currentState.user)); // Revert to previous state
    }
  }

  Future<void> _onUpdateProfilePhoto(
    UpdateProfilePhotoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    
    final currentState = state as ProfileLoaded;
    emit(ProfileUpdating(currentState.user));
    
    try {
      // TODO: Implement image picker and upload functionality
      // final imagePath = await _imagePickerService.pickImage(event.source);
      // final imageUrl = await _imageUploadService.uploadImage(imagePath);
      
      // For now, just show a message
      emit(const ProfileError('Photo update functionality will be implemented soon'));
      emit(ProfileLoaded(currentState.user));
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      emit(ProfileError(errorMessage));
      emit(ProfileLoaded(currentState.user));
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // Refresh profile from server
    // TODO: Implement server refresh
    add(LoadProfileEvent());
  }

  AppUser _updateUserField(AppUser user, String field, String value) {
    switch (field) {
      case 'name':
        return AppUser(
          id: user.id,
          name: value,
          email: user.email,
          password: user.password,
          role: user.role,
          isPrime: user.isPrime,
          finesDue: user.finesDue,
          isEmailVerified: user.isEmailVerified,
          badges: user.badges,
          createdAt: user.createdAt,
          updatedAt: DateTime.now(),
          version: user.version,
          accessToken: user.accessToken,
          refreshToken: user.refreshToken,
          picture: user.picture,
          phno: user.phno,
          wishlist: user.wishlist,
        );
      case 'mobile':
        return AppUser(
          id: user.id,
          name: user.name,
          email: user.email,
          password: user.password,
          role: user.role,
          isPrime: user.isPrime,
          finesDue: user.finesDue,
          isEmailVerified: user.isEmailVerified,
          badges: user.badges,
          createdAt: user.createdAt,
          updatedAt: DateTime.now(),
          version: user.version,
          accessToken: user.accessToken,
          refreshToken: user.refreshToken,
          picture: user.picture,
          phno: value,
          wishlist: user.wishlist,
        );
      case 'email':
        return AppUser(
          id: user.id,
          name: user.name,
          email: value,
          password: user.password,
          role: user.role,
          isPrime: user.isPrime,
          finesDue: user.finesDue,
          isEmailVerified: false, // Reset verification when email changes
          badges: user.badges,
          createdAt: user.createdAt,
          updatedAt: DateTime.now(),
          version: user.version,
          accessToken: user.accessToken,
          refreshToken: user.refreshToken,
          picture: user.picture,
          phno: user.phno,
          wishlist: user.wishlist,
        );
      default:
        return user;
    }
  }
}
