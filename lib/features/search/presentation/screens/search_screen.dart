import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const _textColor = Color(0xFF052E44);
  static const _bgColor = Color(0xFFFDFDFD);
  static const _chipBg = Color(0xFFE0E0E0);
  static const _formatCardBg = Color.fromRGBO(208, 225, 253, 0.4);

  static const _topics = <_TopicData>[
    _TopicData('Education', Icons.school),
    _TopicData('Money & Investments', Icons.attach_money),
    _TopicData('Science', Icons.science),
    _TopicData('Career & Success', Icons.trending_up),
    _TopicData('Marketing & Sales', Icons.campaign),
    _TopicData('Health & Nutrition', Icons.favorite),
    _TopicData('Communication Skill', Icons.chat),
    _TopicData('Management & Leadership', Icons.groups),
    _TopicData('Psychology', Icons.psychology),
    _TopicData('Fiction', Icons.auto_stories),
    _TopicData('Politics', Icons.account_balance),
    _TopicData('History', Icons.history_edu),
    _TopicData('Motivation & Inspiration', Icons.lightbulb),
    _TopicData('Biography & Memoir', Icons.person),
  ];

  static const _formats = <_FormatData>[
    _FormatData(
      'Hardcover',
      'Durable printed book with a hard binding. '
          'Perfect for collectors and long-term reading.',
      Icons.menu_book,
    ),
    _FormatData(
      'eBook',
      'Digital version of the book. Read anytime on '
          'your phone, tablet or eReader',
      Icons.tablet_mac,
    ),
    _FormatData(
      'Audio Book',
      'Listen to the book on the go. Great for '
          'commutes or bedtime stories.',
      Icons.headphones,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildSectionTitle('Topics'),
            const SizedBox(height: 12),
            _buildTopicChips(),
            const SizedBox(height: 24),
            _buildSectionTitle('Book Format'),
            const SizedBox(height: 12),
            _buildFormatCards(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: _textColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          SizedBox(width: 12),
          Icon(Icons.search, color: _textColor, size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search any Books',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ),
          Icon(
            Icons.qr_code_scanner,
            color: _textColor,
            size: 22,
          ),
          SizedBox(width: 12),
          Icon(Icons.mic, color: _textColor, size: 22),
          SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: _textColor,
      ),
    );
  }

  Widget _buildTopicChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _topics
          .map(
            (t) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _chipBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon, size: 16, color: _textColor),
                  const SizedBox(width: 6),
                  Text(
                    t.label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFormatCards() {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _formats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final f = _formats[index];
          return Container(
            width: 240,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _formatCardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        f.description,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: _textColor,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    f.icon,
                    size: 32,
                    color: _textColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopicData {
  final String label;
  final IconData icon;
  const _TopicData(this.label, this.icon);
}

class _FormatData {
  final String title;
  final String description;
  final IconData icon;
  const _FormatData(this.title, this.description, this.icon);
}
