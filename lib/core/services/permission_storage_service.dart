import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class PermissionStorageService {
  static const String _permissionsGrantedKey = 'permissions_granted';
  static const String _permissionsAskedKey = 'permissions_asked';
  
  /// Check if permissions have been granted and stored
  Future<bool> arePermissionsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionsGrantedKey) ?? false;
  }
  
  /// Mark permissions as granted
  Future<void> setPermissionsGranted(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsGrantedKey, granted);
  }
  
  /// Check if permissions have been asked before
  Future<bool> havePermissionsBeenAsked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionsAskedKey) ?? false;
  }
  
  /// Mark permissions as asked
  Future<void> setPermissionsAsked(bool asked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsAskedKey, asked);
  }
  
  /// Clear all permission storage (useful for logout)
  Future<void> clearPermissionStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_permissionsGrantedKey);
    await prefs.remove(_permissionsAskedKey);
  }
}
