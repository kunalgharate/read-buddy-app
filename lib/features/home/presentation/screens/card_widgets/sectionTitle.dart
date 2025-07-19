import 'package:flutter/material.dart';
import '../../pages/book_list.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String apiEndpoint;
  const SectionTitle({
    super.key,
    required this.title,
    required this.apiEndpoint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(5, 46, 68, 1),
                  fontFamily: 'popins'),
            ),
          ),
          //Icon have to added how a image icon

          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookListPage(
                      title: title,
                      apiEndpoint: apiEndpoint,
                    ),
                  ));
            },
            child: Image.asset(
              'assets/icons/tabler_arrow-right.png',
              height: 24,
              width: 24,
            ),
          ),
        ],
      ),
    );
  }
}
