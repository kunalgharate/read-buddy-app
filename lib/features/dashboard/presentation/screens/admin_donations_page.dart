import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/features/donated_books/data/models/donated_books_model.dart';
import 'package:read_buddy_app/features/donated_books/presentation/widgets/donated_book_card.dart';

class AdminDonationsPage extends StatefulWidget {
  const AdminDonationsPage({super.key});

  @override
  State<AdminDonationsPage> createState() => _AdminDonationsPageState();
}

class _AdminDonationsPageState extends State<AdminDonationsPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;

  /// All donations fetched once from the API
  List<DonatedBooksModel> _allDonations = [];

  /// What's shown in the list (after tab filter + ID search)
  List<DonatedBooksModel> _filtered = [];

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // ─── status labels that map to the API "status" field ──────────────────────
  // "pending" tab  → show statuses that are NOT "done"
  // "done" tab     → show status == "done"
  static const String _doneStatus = 'done';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchAllDonations();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    _fetchAllDonations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── Fetch all donations from API ─────────────────────────────────────────
  Future<void> _fetchAllDonations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = getIt<Dio>();
      // Fetching all donations without status query so both tab counts are accurate.
      // If backend supports it, this will pull all items and we filter them locally.
      final response = await dio.get(ApiConstants.adminDonations);

      if (response.statusCode == ApiConstants.success) {
        _allDonations = _parseDonations(response.data);
        _applyFilter();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load donations.\n${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // ─── Apply search filter client-side ──────────────────────────────────────
  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    final isDoneTab = _tabController.index == 1;

    List<DonatedBooksModel> result = _allDonations.where((d) {
      final status = d.status.toLowerCase();
      if (isDoneTab) {
        return status == _doneStatus;
      } else {
        // "Pending" tab = everything that is NOT done
        return status != _doneStatus;
      }
    }).toList();

    // Further filter by donation ID search
    if (query.isNotEmpty) {
      result = result.where((d) {
        return (d.id ?? '').toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filtered = result;
      _isLoading = false;
    });
  }

  // ─── Search by exact donation ID via API ────────────────────────────────────
  Future<void> _searchById(String id) async {
    if (id.trim().isEmpty) {
      _applyFilter();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = getIt<Dio>();
      final response = await dio.get(ApiConstants.donationById(id.trim()));
      final donations = _parseDonations(response.data, isSingle: true);
      setState(() {
        _filtered = donations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No donation found with ID "$id".';
        _isLoading = false;
      });
    }
  }

  // Removed inline markDelivered as it's now in the detail page.

  // ─── Parse helper ────────────────────────────────────────────────────────────
  List<DonatedBooksModel> _parseDonations(dynamic data,
      {bool isSingle = false}) {
    try {
      if (data is List) {
        return data
            .map((e) => DonatedBooksModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map<String, dynamic>) {
        if (data.containsKey('donations')) {
          return (data['donations'] as List)
              .map((e) =>
                  DonatedBooksModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (data.containsKey('donation')) {
          return [
            DonatedBooksModel.fromJson(
                data['donation'] as Map<String, dynamic>)
          ];
        }
        if (isSingle) {
          return [DonatedBooksModel.fromJson(data)];
        }
        final list = data['data'] ?? [];
        return (list as List)
            .map((e) => DonatedBooksModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ─── UI ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Donated Books',
          style: TextStyle(
            color: Color(0xFF052E44),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF052E44),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2CE07F),
          indicatorWeight: 3,
          tabs: [
            Tab(
              text: _isLoading
                  ? 'Pending'
                  : 'Pending (${_allDonations.where((d) => d.status.toLowerCase() != _doneStatus).length})',
            ),
            Tab(
              text: _isLoading
                  ? 'Done'
                  : 'Done (${_allDonations.where((d) => d.status.toLowerCase() == _doneStatus).length})',
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF052E44)),
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _searchById,
                onChanged: (v) {
                  if (v.isEmpty) _applyFilter();
                },
                decoration: InputDecoration(
                  hintText: 'Search by Donation ID...',
                  hintStyle:
                      const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF052E44)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilter();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Count chip
          if (!_isLoading && _errorMessage == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF052E44),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_filtered.length} record${_filtered.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _fetchAllDonations,
                    icon: const Icon(Icons.refresh,
                        size: 16, color: Color(0xFF052E44)),
                    label: const Text('Refresh',
                        style: TextStyle(
                            color: Color(0xFF052E44), fontSize: 12)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 4),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchAllDonations,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF052E44)),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No donations found',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    final isPendingTab = _tabController.index == 0;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = _filtered[index];
        return DonatedBookCard(
          book: book,
          onTap: () async {
            await Navigator.pushNamed(
              context,
              '/admin-donated-book-detail',
              arguments: book,
            );
            _fetchAllDonations();
          },
        );
      },
    );
  }
}
