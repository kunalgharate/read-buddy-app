import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/image_upload_service.dart';
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
  final ImagePickerService _imagePickerService;
  final ImageUploadService _imageUploadService;

  ProfileBloc(
    this._secureStorage,
    this._updateProfileUseCase,
    this._imagePickerService,
    this._imageUploadService,
  ) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileFieldEvent>(_onUpdateProfileField);
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
    final currentUser = currentState.user;
    try {
      emit(ProfileUpdating(currentUser));
      final profileData = _validateInputs(key: event.field, value: event.value);
      if (profileData['error'] != null) {
        emit(ProfileError(profileData['error']!));
        emit(ProfileLoaded(currentUser)); // Revert to previous state
        return;
      }
      profileData.remove('error');
      final updatedUserFromApi = await _updateProfileUseCase.call(profileData: profileData);

      await _secureStorage.saveUser(updatedUserFromApi);
      emit(ProfileUpdated(updatedUserFromApi));
      emit(ProfileLoaded(updatedUserFromApi));

    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      emit(ProfileError(errorMessage));
      // Revert to previous state on error
      emit(ProfileLoaded(currentUser));
    }
  }

  Future<void> _onUpdateProfilePhoto(
    UpdateProfilePhotoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    
    final currentState = state as ProfileLoaded;
    final currentUser = currentState.user;
    
    emit(ProfileUpdating(currentUser));
    
    try {
      // Convert PhotoSource to ImageSource
      final imageSource = event.source == PhotoSource.camera 
          ? ImageSource.camera 
          : ImageSource.gallery;
      
      // Pick image
      final imageFile = await _imagePickerService.pickImage(imageSource);
      if (imageFile == null) {
        // User cancelled image selection
        emit(ProfileLoaded(currentUser));
        return;
      }

      // Validate image file
      if (!_imageUploadService.validateImageFile(imageFile)) {
        emit(const ProfileError('Invalid image file'));
        emit(ProfileLoaded(currentUser));
        return;
      }

      // Upload image and get URL
      final imageUrl = await _imageUploadService.uploadProfileImage(imageFile);
      
      if (imageUrl.isEmpty) {
        emit(const ProfileError('Failed to upload image'));
        emit(ProfileLoaded(currentUser));
        return;
      }

      // Update profile with new image URL
      final updatedUserFromApi = await _updateProfileUseCase.call(
        profileData: {'picture': imageUrl}
      );

      // Save updated user to secure storage
      await _secureStorage.saveUser(updatedUserFromApi);
      
      emit(ProfileUpdated(updatedUserFromApi));
      emit(ProfileLoaded(updatedUserFromApi));

    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      emit(ProfileError(errorMessage));
      emit(ProfileLoaded(currentUser));
    }
  }


  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // Refresh profile from secure storage first
      final user = await _secureStorage.getUser();
      if (user != null) {
        emit(ProfileLoaded(user));
      }
      
      // TODO: Implement server refresh if needed
      // final serverUser = await _profileRepository.getUserProfile();
      // await _secureStorage.saveUser(serverUser);
      // emit(ProfileLoaded(serverUser));
      
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      emit(ProfileError(errorMessage));
    }
  }



Map<String, String> _validateInputs({
  String? key,
  String? value,
}) {
  if (key == null || value == null) {
    return {'error': 'Key and value are required'};
  }

  switch(key.toLowerCase()) {
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
      return {'phno': value.trim()}; // Always use 'phno' for API

    case 'email':
      // Email updates are not allowed
      return {'error': 'Email address cannot be changed. It\'s your primary account identifier.'};

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
      } catch (e) {
        return {'error': 'Invalid date format'};
      }

    default:
      return {'error': 'Invalid field key'};
  }
}
}

// Additional Profile States for better field update handling
class ProfileFieldUpdated extends ProfileState {
  final AppUser user;
  final String updatedField;
  final String newValue;

  const ProfileFieldUpdated({
    required this.user,
    required this.updatedField,
    required this.newValue,
  });

  @override
  List<Object> get props => [user, updatedField, newValue];
}

class ProfileApiUpdated extends ProfileState {
  final AppUser user;

  const ProfileApiUpdated(this.user);

  @override
  List<Object> get props => [user];
}
