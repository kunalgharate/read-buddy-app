import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/features/donated_books/domain/entities/donated_books_entity.dart';

class AdminDonationDetailPage extends StatefulWidget {
  final DonatedBooksEntity book;

  const AdminDonationDetailPage({super.key, required this.book});

  @override
  State<AdminDonationDetailPage> createState() =>
      _AdminDonationDetailPageState();
}

class _AdminDonationDetailPageState extends State<AdminDonationDetailPage> {
  static const _textDark = Color(0xFF052E44);
  static const _primaryGreen = Color(0xFF2CE07F);

  late String _currentStatus;
  bool _isUpdating = false;

  final List<String> _statusOptions = [
    'donation_created',
    'picked_up',
    'delivered',
    'done',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.book.status;
    if (!_statusOptions.contains(_currentStatus)) {
      _statusOptions.insert(0, _currentStatus);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (widget.book.id == null || newStatus == _currentStatus) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final dio = getIt<Dio>();

      // Sending only the status field as sending populated fields like 'category'
      // causes BSON Cast errors on the backend.
      final updatedBody = {
        'status': newStatus,
      };

      final response = await dio.put(
        ApiConstants.updateDonationStatus(widget.book.id!),
        data: updatedBody,
      );

      if (response.statusCode == ApiConstants.success ||
          response.statusCode == 201) {
        if (mounted) {
          setState(() {
            _currentStatus = newStatus;
            _isUpdating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status updated successfully ✓'),
              backgroundColor: _primaryGreen,
            ),
          );
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Donation',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverHeader(size),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.book.bookTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                          ),
                        ),
                      ),
                      _buildStatusBadge(_currentStatus),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (widget.book.category.isNotEmpty)
                    Text(
                      widget.book.category,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF7A9BB5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Update Status Section
                  _buildSectionCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Update Status'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                // ignore: deprecated_member_use
                                value: _currentStatus,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF7A9BB5)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                items: _statusOptions.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: _isUpdating
                                    ? null
                                    : (val) {
                                        if (val != null) _updateStatus(val);
                                      },
                              ),
                            ),
                            if (_isUpdating)
                              const Padding(
                                padding: EdgeInsets.only(left: 16.0),
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionCard(_buildInfoGrid()),

                  const SizedBox(height: 24),

                  _buildSectionCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Donation Info'),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                            Icons.person_outline,
                            'Donor',
                            widget.book.donorName.isNotEmpty
                                ? widget.book.donorName
                                : 'You'),
                        _buildDetailRow(Icons.calendar_today_outlined,
                            'Donated on', _formatDate(widget.book.createdAt)),
                        _buildDetailRow(Icons.confirmation_number_outlined,
                            'Donation ID', widget.book.id ?? 'N/A'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCoverHeader(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.35,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        image: widget.book.coverImageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(widget.book.coverImageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.book.coverImageUrl.isEmpty
          ? const Center(
              child: Icon(
                Icons.menu_book,
                size: 80,
                color: Color(0xFFB3D9FF),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final apiStatus = status.toLowerCase();
    String displayStatus;
    Color color;

    if (apiStatus.contains('pending') || apiStatus.contains('created')) {
      displayStatus = 'Pending';
      color = const Color(0xFFFFC107);
    } else if (apiStatus.contains('progress') || apiStatus.contains('pickup')) {
      displayStatus = 'In Progress';
      color = const Color(0xFF2196F3);
    } else if (apiStatus.contains('complete') ||
        apiStatus.contains('success') ||
        apiStatus.contains('done') ||
        apiStatus.contains('delivered')) {
      displayStatus = 'Completed';
      color = _primaryGreen;
    } else {
      displayStatus = status;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        displayStatus.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoItem(Icons.menu_book, 'Format',
            widget.book.format.isEmpty ? 'Physical' : widget.book.format),
        _buildInfoItem(Icons.language, 'Language',
            widget.book.language.isEmpty ? 'English' : widget.book.language),
        _buildInfoItem(Icons.star_outline, 'Condition', 'Good'),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _textDark, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style:
              GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF7A9BB5)),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600, color: _textDark),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _textDark,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF7A9BB5)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: const Color(0xFF7A9BB5)),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
