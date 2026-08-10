import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';

/// Admin page for managing book return requests.
/// Fetches all requests with 'returning' status and allows marking
/// them as received or completing inspection.
class AdminReturnRequestsPage extends StatefulWidget {
  const AdminReturnRequestsPage({super.key});

  @override
  State<AdminReturnRequestsPage> createState() =>
      _AdminReturnRequestsPageState();
}

class _AdminReturnRequestsPageState extends State<AdminReturnRequestsPage> {
  late Future<List<Map<String, dynamic>>> _returnsFuture;
  final Set<String> _loadingIds = {};

  @override
  void initState() {
    super.initState();
    _returnsFuture = _fetchReturningRequests();
  }

  Future<List<Map<String, dynamic>>> _fetchReturningRequests() async {
    final response = await getIt<Dio>().get(ApiConstants.getAllBookRequests);
    final data = response.data;

    List<dynamic> allRequests = [];
    if (data is Map<String, dynamic>) {
      allRequests = (data['bookRequests'] ??
          data['requests'] ??
          data['data'] ??
          []) as List<dynamic>;
    } else if (data is List) {
      allRequests = data;
    }

    return allRequests
        .where((r) => (r['status'] as String?)?.toLowerCase() == 'returning')
        .map((r) => r as Map<String, dynamic>)
        .toList();
  }

  void _refresh() {
    setState(() {
      _returnsFuture = _fetchReturningRequests();
    });
  }

  Future<void> _markReceived(String requestId) async {
    setState(() => _loadingIds.add('$requestId-receive'));
    try {
      await getIt<Dio>().patch(
        ApiConstants.returnRequestReceive(requestId),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as received'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _refresh();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          (e.response?.data is Map ? e.response?.data['message'] : null) ??
              'Failed to mark as received';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.toString()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingIds.remove('$requestId-receive'));
    }
  }

  Future<void> _completeInspection(String requestId) async {
    setState(() => _loadingIds.add('$requestId-inspect'));
    try {
      await getIt<Dio>().patch(
        ApiConstants.returnRequestInspect(requestId),
        data: {'condition': 'good'},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspection completed'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _refresh();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          (e.response?.data is Map ? e.response?.data['message'] : null) ??
              'Failed to complete inspection';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.toString()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingIds.remove('$requestId-inspect'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Return Requests',
          style: TextStyle(
            color: Color(0xFF052E44),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF052E44)),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _returnsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'Failed to load return requests',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final returns = snapshot.data ?? [];
          if (returns.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.replay_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No pending return requests',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: returns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final request = returns[index];
              return _ReturnRequestCard(
                request: request,
                isReceiveLoading:
                    _loadingIds.contains('${request['_id']}-receive'),
                isInspectLoading:
                    _loadingIds.contains('${request['_id']}-inspect'),
                onMarkReceived: () => _markReceived(request['_id'] as String),
                onCompleteInspection: () =>
                    _completeInspection(request['_id'] as String),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReturnRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final bool isReceiveLoading;
  final bool isInspectLoading;
  final VoidCallback onMarkReceived;
  final VoidCallback onCompleteInspection;

  const _ReturnRequestCard({
    required this.request,
    required this.isReceiveLoading,
    required this.isInspectLoading,
    required this.onMarkReceived,
    required this.onCompleteInspection,
  });

  @override
  Widget build(BuildContext context) {
    final bookTitle =
        (request['bookTitle'] ?? request['book']?['title'] ?? 'Unknown Book')
            .toString();
    final userName =
        (request['userName'] ?? request['user']?['name'] ?? 'Unknown User')
            .toString();
    final returnMethod =
        (request['returnMethod'] ?? request['fulfillmentMethod'] ?? '—')
            .toString();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book title
          Text(
            bookTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF052E44),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // User name
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 14, color: Color(0xFF888888)),
              const SizedBox(width: 4),
              Text(
                userName,
                style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Return method
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  size: 14, color: Color(0xFF888888)),
              const SizedBox(width: 4),
              Text(
                'Return method: ${_capitalize(returnMethod)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Mark Received',
                  isLoading: isReceiveLoading,
                  color: const Color(0xFF2196F3),
                  onPressed: onMarkReceived,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'Complete Inspection',
                  isLoading: isInspectLoading,
                  color: AppColors.primary,
                  onPressed: onCompleteInspection,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.isLoading,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
