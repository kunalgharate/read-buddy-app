import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const _textColor = Color(0xFF052E44);
  static const _bgColor = Color(0xFFFDFDFD);
  static const _greenHighlight = Color.fromRGBO(44, 224, 127, 0.4);

  static const _notifications = <_NotificationData>[
    _NotificationData(
      message: 'The book Nick was recently donated by Sameer Sharamma',
      time: '1H',
      isHighlighted: true,
    ),
    _NotificationData(
      message:
          'Your request for The Design of Everyday Things has been accepted',
      time: '3H',
    ),
    _NotificationData(
      message:
          'Reminder: Your reading time for the book will expire in 2 days.',
      time: '7H',
    ),
    _NotificationData(
      message: 'Your request for Rich Dad Poor dad has been accepted',
      time: '1D',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Notification',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: _textColor,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final n = _notifications[index];
          return _NotificationCard(data: n);
        },
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
