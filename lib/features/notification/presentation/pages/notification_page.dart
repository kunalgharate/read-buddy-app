import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import '../bloc/notification_bloc.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const _textColor = Color(0xFF052E44);
  static const _bgColor = Color(0xFFFDFDFD);
  static const _greenHighlight = Color.fromRGBO(44, 224, 127, 0.4);
  static const _accentColor = Color(0xFF2CE07F);
  static const _mutedColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationBloc>()..add(LoadMyNotifications()),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotificationPage._bgColor,
      appBar: AppBar(
        backgroundColor: NotificationPage._bgColor,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: NotificationPage._textColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Notification',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: NotificationPage._textColor,
          ),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) => _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationState state) {
    if (state is NotificationError) {
      return _ErrorView(message: state.message);
    }

    if (state is NotificationLoaded) {
      final items = state.notifications
          .asMap()
          .entries
          .map((entry) => _toNotificationData(entry.value, entry.key))
          .toList();

      if (items.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          color: NotificationPage._accentColor,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 140),
              _EmptyView(),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _refresh(context),
        color: NotificationPage._accentColor,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) => _NotificationCard(data: items[index]),
        ),
      );
    }

    return const Center(
      child: CircularProgressIndicator(color: NotificationPage._accentColor),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<NotificationBloc>();
    final finished = bloc.stream.firstWhere(
      (state) => state is NotificationLoaded || state is NotificationError,
    );
    bloc.add(LoadMyNotifications());
    await finished.timeout(
      const Duration(seconds: 20),
      onTimeout: () => NotificationLoaded(const <Map<String, dynamic>>[]),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: NotificationPage._mutedColor,
          ),
          SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: NotificationPage._mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: NotificationPage._accentColor,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: NotificationPage._textColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<NotificationBloc>().add(LoadMyNotifications()),
              style: ElevatedButton.styleFrom(
                backgroundColor: NotificationPage._accentColor,
                foregroundColor: NotificationPage._textColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificationData data;

  const _NotificationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: data.isHighlighted
            ? NotificationPage._greenHighlight
            : NotificationPage._bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: data.isHighlighted
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover placeholder
          Container(
            width: 74,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.menu_book,
              color: Color(0xFF9E9E9E),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // Message
          Expanded(
            child: Text(
              data.message,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: NotificationPage._textColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Time + menu column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.time,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 8),
              const Icon(
                Icons.more_vert,
                size: 20,
                color: Color(0xFF9E9E9E),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationData {
  final String message;
  final String time;
  final bool isHighlighted;

  const _NotificationData({
    required this.message,
    required this.time,
    this.isHighlighted = false,
  });
}

_NotificationData _toNotificationData(Map<String, dynamic> raw, int index) {
  return _NotificationData(
    message: _extractMessage(raw),
    time: _formatRelativeTime(_extractTimestamp(raw)),
    isHighlighted: _isHighlighted(raw, index),
  );
}

String _extractMessage(Map<String, dynamic> raw) {
  final title = _asText(raw['title']);
  final body = _asText(raw['body']);
  if (title != null && body != null) {
    return title == body ? title : '$title $body';
  }
  final message = _asText(raw['message']);
  final text = _asText(raw['text']);
  return title ?? message ?? body ?? text ?? 'No details available';
}

DateTime? _extractTimestamp(Map<String, dynamic> raw) {
  const keys = ['createdAt', 'sentAt', 'updatedAt', 'date', 'time'];
  for (final key in keys) {
    final parsed = _parseDate(raw[key]);
    if (parsed != null) return parsed;
  }
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toLocal();
  if (value is int) return _fromEpoch(value);
  if (value is double) return _fromEpoch(value.toInt());
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) return parsed.toLocal();
    final epoch = int.tryParse(trimmed);
    if (epoch != null) return _fromEpoch(epoch);
  }
  return null;
}

DateTime _fromEpoch(int value) {
  final millis = value.abs() < 100000000000 ? value * 1000 : value;
  return DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
}

String _formatRelativeTime(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.isNegative || diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return DateFormat('dd MMM yyyy', 'en').format(date);
}

bool _isHighlighted(Map<String, dynamic> raw, int index) {
  if (raw.containsKey('read')) {
    final read = raw['read'];
    if (read is bool) return !read;
    if (read is String) return read.toLowerCase() == 'false';
    if (read is num) return read == 0;
  }
  return index == 0;
}

String? _asText(dynamic value) {
  if (value == null) return null;
  final text = value is String ? value.trim() : value.toString().trim();
  return text.isEmpty ? null : text;
}
