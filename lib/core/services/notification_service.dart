// lib/core/services/notification_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_result.dart';

/// Notification types supported by the app
enum NotificationType {
  bookRequest,
  bookApproved,
  bookRejected,
  bookReturned,
  bookOverdue,
  newBookAvailable,
  systemUpdate,
  promotional,
}

/// Notification priority levels
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// Notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? actionUrl;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.data,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
  });

  /// Creates a copy with updated values
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  /// Creates from JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.systemUpdate,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
    );
  }
}

/// Notification service for managing local notifications
@injectable
class NotificationService {
  static const String _notificationsKey = 'app_notifications';
  static const String _settingsKey = 'notification_settings';
  static const int _maxNotifications = 100;

  /// Gets all notifications
  Future<AppResult<List<AppNotification>>> getNotifications() async {
    try {
      if (kDebugMode) {
        print('📱 NotificationService: Getting all notifications');
      }

      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

      final notifications = <AppNotification>[];
      
      for (final jsonString in notificationsJson) {
        try {
          final notification = AppNotification.fromJson(jsonDecode(jsonString));
          notifications.add(notification);
        } catch (e) {
          if (kDebugMode) {
            print('📱 NotificationService: Failed to parse notification: $e');
          }
          // Skip corrupted notification but continue with others
        }
      }

      // Sort by creation date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (kDebugMode) {
        print('📱 NotificationService: Found ${notifications.length} notifications');
      }

      return AppSuccess(notifications);
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        print('📱 NotificationService: Failed to get notifications');
        print('📱 Exception: $exception');
        print('📱 Stack trace: $stackTrace');
      }
      return const AppFailure('Failed to load notifications. Please try again.');
    }
  }

  /// Gets unread notifications
  Future<AppResult<List<AppNotification>>> getUnreadNotifications() async {
    final result = await getNotifications();
    return result.map((notifications) => 
        notifications.where((n) => !n.isRead).toList());
  }

  /// Gets notifications by type
  Future<AppResult<List<AppNotification>>> getNotificationsByType(
    NotificationType type,
  ) async {
    final result = await getNotifications();
    return result.map((notifications) => 
        notifications.where((n) => n.type == type).toList());
  }

  /// Adds a new notification
  Future<AppResult<void>> addNotification(AppNotification notification) async {
    try {
      if (kDebugMode) {
        print('📱 NotificationService: Adding notification');
        print('📱 Title: ${notification.title}');
        print('📱 Type: ${notification.type}');
      }

      final notificationsResult = await getNotifications();
      if (notificationsResult.isFailure) {
        return AppFailure(notificationsResult.error!);
      }

      final notifications = notificationsResult.data!;
      
      // Check if notification with same ID already exists
      if (notifications.any((n) => n.id == notification.id)) {
        return const AppFailure('Notification with this ID already exists');
      }
      
      // Add new notification at the beginning
      notifications.insert(0, notification);

      // Keep only the latest notifications to prevent storage bloat
      if (notifications.length > _maxNotifications) {
        notifications.removeRange(_maxNotifications, notifications.length);
        if (kDebugMode) {
          print('📱 NotificationService: Trimmed old notifications to maintain limit');
        }
      }

      final saveResult = await _saveNotifications(notifications);
      if (saveResult.isFailure) {
        return AppFailure(saveResult.error!);
      }

      if (kDebugMode) {
        print('📱 NotificationService: Notification added successfully');
      }

      return const AppSuccess(null);
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        print('📱 NotificationService: Failed to add notification');
        print('📱 Exception: $exception');
        print('📱 Stack trace: $stackTrace');
      }
      return const AppFailure('Failed to save notification. Please try again.');
    }
  }

  /// Marks a notification as read
  Future<AppResult<void>> markAsRead(String notificationId) async {
    try {
      if (kDebugMode) {
        print('📱 NotificationService: Marking notification as read: $notificationId');
      }

      if (notificationId.isEmpty) {
        return const AppFailure('Invalid notification ID');
      }

      final notificationsResult = await getNotifications();
      if (notificationsResult.isFailure) {
        return AppFailure(notificationsResult.error!);
      }

      final notifications = notificationsResult.data!;
      final index = notifications.indexWhere((n) => n.id == notificationId);

      if (index == -1) {
        if (kDebugMode) {
          print('📱 NotificationService: Notification not found: $notificationId');
        }
        return const AppFailure('Notification not found');
      }

      // Check if already read
      if (notifications[index].isRead) {
        if (kDebugMode) {
          print('📱 NotificationService: Notification already marked as read');
        }
        return const AppSuccess(null);
      }

      notifications[index] = notifications[index].copyWith(isRead: true);
      
      final saveResult = await _saveNotifications(notifications);
      if (saveResult.isFailure) {
        return AppFailure(saveResult.error!);
      }

      if (kDebugMode) {
        print('📱 NotificationService: Notification marked as read');
      }

      return const AppSuccess(null);
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        print('📱 NotificationService: Failed to mark notification as read');
        print('📱 Exception: $exception');
        print('📱 Stack trace: $stackTrace');
      }
      return const AppFailure('Failed to update notification. Please try again.');
    }
  }

  /// Marks all notifications as read
  Future<AppResult<void>> markAllAsRead() async {
    try {
      if (kDebugMode) {
        print('📱 NotificationService: Marking all notifications as read');
      }

      final notificationsResult = await getNotifications();
      if (notificationsResult.isFailure) {
        return AppFailure(notificationsResult.error!);
      }

      final notifications = notificationsResult.data!;
      
      // Check if there are any unread notifications
      final unreadCount = notifications.where((n) => !n.isRead).length;
      if (unreadCount == 0) {
        if (kDebugMode) {
          print('📱 NotificationService: All notifications already read');
        }
        return const AppSuccess(null);
      }

      final updatedNotifications = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      final saveResult = await _saveNotifications(updatedNotifications);
      if (saveResult.isFailure) {
        return AppFailure(saveResult.error!);
      }

      if (kDebugMode) {
        print('📱 NotificationService: $unreadCount notifications marked as read');
      }

      return const AppSuccess(null);
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        print('📱 NotificationService: Failed to mark all notifications as read');
        print('📱 Exception: $exception');
        print('📱 Stack trace: $stackTrace');
      }
      return const AppFailure('Failed to update notifications. Please try again.');
    }
  }

  /// Deletes a notification
  Future<AppResult<void>> deleteNotification(String notificationId) async {
    try {
      if (kDebugMode) {
        print('📱 NotificationService: Deleting notification: $notificationId');
      }

      if (notificationId.isEmpty) {
        return const AppFailure('Invalid notification ID');
      }

      final notificationsResult = await getNotifications();
      if (notificationsResult.isFailure) {
        return AppFailure(notificationsResult.error!);
      }

      final notifications = notificationsResult.data!;
      final initialCount = notifications.length;
      
      notifications.removeWhere((n) => n.id == notificationId);

      if (notifications.length == initialCount) {
        if (kDebugMode) {
          print('📱 NotificationService: Notification not found for deletion');
        }
        return const AppFailure('Notification not found');
      }

      final saveResult = await _saveNotifications(notifications);
      if (saveResult.isFailure) {
        return AppFailure(saveResult.error!);
      }

      if (kDebugMode) {
        print('📱 NotificationService: Notification deleted successfully');
      }

      return const AppSuccess(null);
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        print('📱 NotificationService: Failed to delete notification');
        print('📱 Exception: $exception');
        print('📱 Stack trace: $stackTrace');
      }
      return const AppFailure('Failed to delete notification. Please try again.');
    }
  }

  /// Clears all notifications
  Future<AppResult<void>> clearAllNotifications() async {
    try {
      if (kDebugMode) {
        print('📱 NotificationService: Clearing all notifications');
      }

      final prefs = await SharedPreferences.getInstance();
      final removed = await prefs.remove(_notificationsKey);
      
      if (!removed) {
        return const AppFailure('Failed to clear notifications from storage');
      }

      if (kDebugMode) {
        print('📱 NotificationService: All notifications cleared successfully');
      }

      return const AppSuccess(null);
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        print('📱 NotificationService: Failed to clear notifications');
        print('📱 Exception: $exception');
        print('📱 Stack trace: $stackTrace');
      }
      return const AppFailure('Failed to clear notifications. Please try again.');
    }
  }

  /// Gets notification count by type
  Future<AppResult<Map<NotificationType, int>>> getNotificationCounts() async {
    final result = await getNotifications();
    return result.map((notifications) {
      final counts = <NotificationType, int>{};
      for (final type in NotificationType.values) {
        counts[type] = notifications.where((n) => n.type == type).length;
      }
      return counts;
    });
  }

  /// Gets unread notification count
  Future<AppResult<int>> getUnreadCount() async {
    final result = await getUnreadNotifications();
    return result.map((notifications) => notifications.length);
  }

  /// Gets notification settings
  Future<AppResult<Map<String, bool>>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        final typedSettings = settings.map((key, value) => MapEntry(key, value as bool));
        return AppSuccess(typedSettings);
      }
      
      // Default settings - all enabled except promotional
      final defaultSettings = {
        'bookRequest': true,
        'bookApproved': true,
        'bookRejected': true,
        'bookReturned': true,
        'bookOverdue': true,
        'newBookAvailable': true,
        'systemUpdate': true,
        'promotional': false,
      };
      
      return AppSuccess(defaultSettings);
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        print('📱 NotificationService: Failed to get settings');
        print('📱 Exception: $exception');
        print('📱 Stack trace: $stackTrace');
      }
      return const AppFailure('Failed to load notification settings');
    }
  }

  /// Updates notification settings
  Future<AppResult<void>> updateNotificationSettings(Map<String, bool> settings) async {
    try {
      if (settings.isEmpty) {
        return const AppFailure('Settings cannot be empty');
      }

      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_settingsKey, jsonEncode(settings));
      
      if (!success) {
        return const AppFailure('Failed to save settings to storage');
      }
      
      if (kDebugMode) {
        print('📱 NotificationService: Settings updated successfully');
        print('📱 Settings: $settings');
      }
      
      return const AppSuccess(null);
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        print('📱 NotificationService: Failed to update settings');
        print('📱 Exception: $exception');
        print('📱 Stack trace: $stackTrace');
      }
      return const AppFailure('Failed to save notification settings');
    }
  }

  /// Checks if notifications are enabled for a specific type
  Future<AppResult<bool>> isNotificationEnabled(NotificationType type) async {
    final settingsResult = await getNotificationSettings();
    return settingsResult.map((settings) => settings[type.name] ?? true);
  }

  /// Saves notifications to local storage
  Future<AppResult<void>> _saveNotifications(List<AppNotification> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = notifications
          .map((n) => jsonEncode(n.toJson()))
          .toList();
      
      final success = await prefs.setStringList(_notificationsKey, notificationsJson);
      
      if (!success) {
        return const AppFailure('Failed to save notifications to storage');
      }
      
      return const AppSuccess(null);
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        print('📱 NotificationService: Failed to save notifications');
        print('📱 Exception: $exception');
        print('📱 Stack trace: $stackTrace');
      }
      return const AppFailure('Failed to save notifications to storage');
    }
  }

  // Factory methods for creating different types of notifications...
  
  /// Creates a book request notification
  AppNotification createBookRequestNotification({
    required String bookTitle,
    required String requesterName,
    required String bookId,
  }) {
    return AppNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_book_request',
      title: 'New Book Request',
      body: '$requesterName wants to borrow "$bookTitle"',
      type: NotificationType.bookRequest,
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      data: {
        'bookId': bookId,
        'requesterName': requesterName,
        'bookTitle': bookTitle,
      },
      actionUrl: '/book-requests/$bookId',
    );
  }

  /// Creates a book approved notification
  AppNotification createBookApprovedNotification({
    required String bookTitle,
    required String ownerName,
    required String bookId,
  }) {
    return AppNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_book_approved',
      title: 'Book Request Approved',
      body: '$ownerName approved your request for "$bookTitle"',
      type: NotificationType.bookApproved,
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      data: {
        'bookId': bookId,
        'ownerName': ownerName,
        'bookTitle': bookTitle,
      },
      actionUrl: '/my-books/$bookId',
    );
  }

  /// Creates a book overdue notification
  AppNotification createBookOverdueNotification({
    required String bookTitle,
    required DateTime dueDate,
    required String bookId,
  }) {
    final daysOverdue = DateTime.now().difference(dueDate).inDays;
    return AppNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_book_overdue',
      title: 'Book Overdue',
      body: '"$bookTitle" is $daysOverdue days overdue. Please return it soon.',
      type: NotificationType.bookOverdue,
      priority: NotificationPriority.urgent,
      createdAt: DateTime.now(),
      data: {
        'bookId': bookId,
        'bookTitle': bookTitle,
        'dueDate': dueDate.toIso8601String(),
        'daysOverdue': daysOverdue,
      },
      actionUrl: '/my-books/$bookId',
    );
  }
}
