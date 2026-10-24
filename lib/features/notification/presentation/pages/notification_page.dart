import 'package:cached_network_image/cached_network_image.dart';
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
    try {
      await finished.timeout(const Duration(seconds: 20));
    } catch (_) {
      bloc.add(NotificationLoadTimeout());
    }
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
          // Book cover or icon
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 50,
              height: 60,
              child: data.coverUrl != null && data.coverUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: data.coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFFE0E0E0),
                        child: const Icon(
                          Icons.notifications,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFE0E0E0),
                        child: const Icon(
                          Icons.notifications,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFE0E0E0),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF9E9E9E),
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Title + Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.title != null && data.title!.isNotEmpty) ...[
                  Text(
                    data.title!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: NotificationPage._textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  data.message,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
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
                  fontSize: 11,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationData {
  final String? title;
  final String message;
  final String? coverUrl;
  final String time;
  final bool isHighlighted;

  const _NotificationData({
    this.title,
    required this.message,
    this.coverUrl,
    required this.time,
    this.isHighlighted = false,
  });
}

_NotificationData _toNotificationData(Map<String, dynamic> raw, int index) {
  final dataObj =
      raw['data'] is Map ? raw['data'] as Map<String, dynamic> : null;

  final title = _asText(raw['title']) ?? _asText(dataObj?['title']);
  final body = _asText(raw['body']) ??
      _asText(raw['message']) ??
      _asText(dataObj?['body']) ??
      _asText(dataObj?['message']) ??
      'Notification';
  final cover = _asText(raw['coverImageUrl']) ??
      _asText(raw['image']) ??
      _asText(dataObj?['coverImageUrl']) ??
      _asText(dataObj?['image']);

  return _NotificationData(
    title: title,
    message: body,
    coverUrl: cover,
    time: _formatRelativeTime(_extractTimestamp(raw)),
    isHighlighted: _isHighlighted(raw, index),
  );
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
