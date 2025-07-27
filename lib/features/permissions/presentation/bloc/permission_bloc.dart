import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/permission_service.dart';

part 'permission_event.dart';
part 'permission_state.dart';

@injectable
class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final PermissionService _permissionService;

  PermissionBloc(this._permissionService) : super(PermissionInitial()) {
    on<LoadPermissionsEvent>(_onLoadPermissions);
    on<RequestPermissionEvent>(_onRequestPermission);
    on<RequestAllPermissionsEvent>(_onRequestAllPermissions);
    on<CheckPermissionStatusEvent>(_onCheckPermissionStatus);
  }

  Future<void> _onLoadPermissions(
    LoadPermissionsEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(PermissionLoading());
    
    try {
      final permissions = await _permissionService.getAllPermissions();
      
      final allRequiredGranted = await _permissionService.areAllRequiredPermissionsGranted();
      
      if (allRequiredGranted) {
        emit(PermissionAllGranted(permissions));
      } else {
        emit(PermissionLoaded(permissions));
      }
    } catch (error) {
      emit(PermissionError(error.toString()));
    }
  }

  Future<void> _onRequestPermission(
    RequestPermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    if (state is! PermissionLoaded && state is! PermissionUpdated) return;
    
    final currentPermissions = (state is PermissionLoaded) 
        ? (state as PermissionLoaded).permissions
        : (state as PermissionUpdated).permissions;

    try {
      // Check if permission is permanently denied
      final isPermanentlyDenied = await _permissionService
          .isPermissionPermanentlyDenied(event.permission);
      
      if (isPermanentlyDenied) {
        emit(PermissionPermanentlyDenied(
          currentPermissions,
          event.permission,
        ));
        return;
      }

      // Request the permission
      final isGranted = await _permissionService.requestPermission(event.permission);
      
      // Update the permission list
      final updatedPermissions = await _permissionService.getAllPermissions();
      
      if (isGranted) {
        // Check if all required permissions are now granted
        final allRequiredGranted = await _permissionService.areAllRequiredPermissionsGranted();
        
        if (allRequiredGranted) {
          emit(PermissionAllGranted(updatedPermissions));
        } else {
          emit(PermissionUpdated(updatedPermissions));
        }
      } else {
        emit(PermissionDenied(updatedPermissions, event.permission));
      }
    } catch (error) {
      emit(PermissionError(error.toString()));
    }
  }

  Future<void> _onRequestAllPermissions(
    RequestAllPermissionsEvent event,
    Emitter<PermissionState> emit,
  ) async {
    if (state is! PermissionLoaded && state is! PermissionUpdated) return;
    
    emit(PermissionLoading());
    
    try {
      final results = await _permissionService.requestAllRequiredPermissions();
      final updatedPermissions = await _permissionService.getAllPermissions();
      
      final allRequiredGranted = await _permissionService.areAllRequiredPermissionsGranted();
      
      if (allRequiredGranted) {
        emit(PermissionAllGranted(updatedPermissions));
      } else {
        // Find which permissions were denied
        final deniedPermissions = results.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList();
        
        if (deniedPermissions.isNotEmpty) {
          emit(PermissionSomeDenied(updatedPermissions, deniedPermissions));
        } else {
          emit(PermissionUpdated(updatedPermissions));
        }
      }
    } catch (error) {
      emit(PermissionError(error.toString()));
    }
  }

  Future<void> _onCheckPermissionStatus(
    CheckPermissionStatusEvent event,
    Emitter<PermissionState> emit,
  ) async {
    try {
      final permissions = await _permissionService.getAllPermissions();
      final allRequiredGranted = await _permissionService.areAllRequiredPermissionsGranted();
      
      if (allRequiredGranted) {
        emit(PermissionAllGranted(permissions));
      } else {
        emit(PermissionUpdated(permissions));
      }
    } catch (error) {
      emit(PermissionError(error.toString()));
    }
  }
}
