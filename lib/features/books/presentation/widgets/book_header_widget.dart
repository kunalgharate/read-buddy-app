// First Widget -
import 'package:flutter/material.dart';

class BookHeaderWidget extends StatefulWidget {
  final String title;
  final String writter;
  final String description;
  final String donator;
  final String ratings;

  const BookHeaderWidget({
    super.key,
    required this.title,
    required this.writter,
    required this.description,
    required this.donator,
    required this.ratings,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BookHeaderWidgetState createState() => _BookHeaderWidgetState();
}

class _BookHeaderWidgetState extends State<BookHeaderWidget> {
  bool isLoved = false;

  @override
  Widget build(BuildContext context) {
    String firstLetter = widget.description[0];
    String remainingText = widget.description.substring(1);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top navigation bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () {},
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isLoved ? Icons.favorite : Icons.favorite_border,
                      color: isLoved ? Colors.red : Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        isLoved = !isLoved;
                      });
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.share, color: Colors.black, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFFFD700),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          // Title of the book
                          // 'The DESIGN\nof EVERYDAY\nTHINGS',
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 0.9,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.coffee,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          // Writter name
                          widget.writter,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          // 'DON\nNORMAN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            height: 0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 150,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFFFD700),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstLetter, // String should be
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 0.8,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              // also string part
                              // 'ven the smartest among us can feel inept as we fail to figure out which light switch or oven burner to turn on, or whether to push, pull, or slide a door. The fault, argues this ingenious book, lies not in ourselves, but in product design that ignores the needs of users and the principles of cognitive psychology.',
                              remainingText,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 237, 240, 242),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  //Title
                  widget.title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  // donator
                  'Donated by - ${widget.donator}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Text(
                      'Rate ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star_border,
                          size: 22,
                          color: Colors.grey[400],
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '10+ readers loved this',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
