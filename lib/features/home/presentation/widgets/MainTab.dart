import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:read_buddy_app/features/books/screens/book_details_screen.dart';
import 'package:read_buddy_app/features/home/presentation/screens/card_widgets/bookCard.dart';
import 'package:read_buddy_app/features/home/presentation/screens/card_widgets/main_drawer.dart';
import 'package:read_buddy_app/features/home/presentation/screens/card_widgets/recommendedBookCard.dart';
import 'package:read_buddy_app/features/home/presentation/screens/card_widgets/sectionTitle.dart';
import 'package:read_buddy_app/features/home/presentation/screens/card_widgets/statColumn.dart';
import 'package:read_buddy_app/features/home/domain/entities/book_entity.dart';
import 'package:read_buddy_app/features/home/presentation/bloc/home_main_bloc.dart';
import 'package:read_buddy_app/features/home/presentation/bloc/home_main_state.dart';

import '../../../../core/utils/secure_storage_utils.dart';
import '../bloc/home_main_event.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class Maintab extends StatefulWidget {
  const Maintab({super.key});

  @override
  State<Maintab> createState() => _MainTabState();
}

class _MainTabState extends State<Maintab> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;
  double _lastOffset = 0;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    SecureStorageUtil().getUser().then((user) {
      if (user != null) {
        context.read<HomeMainBloc>().add(FetchMainHomeData(user.id));
      }
    });

    _scrollController.addListener(() {
      double offset = _scrollController.offset;

      if (offset > _lastOffset && _isAppBarVisible) {
        // scrolling down
        setState(() => _isAppBarVisible = false);
      } else if (offset < _lastOffset && !_isAppBarVisible) {
        // scrolling up
        setState(() => _isAppBarVisible = true);
      }

      _lastOffset = offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const MainDrawer(),
      body: SafeArea(
        child: BlocBuilder<HomeMainBloc, HomeMainState>(
          builder: (context, state) {
            // Add null safety check
            final bloc = context.read<HomeMainBloc>();
            if (bloc.isClosed) {
              return const Center(
                child: Text('Session expired. Please restart the app.'),
              );
            }
            
            if (state is HomeMainLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeMainLoaded) {
              return Stack(
                children: [
                  // Scrollable content
                  NotificationListener<ScrollNotification>(
                    onNotification: (_) => true,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 90),
                      children: [
                        if (state.banners.isNotEmpty)
                          CarouselSlider.builder(
                            itemCount: state.banners.length,
                            itemBuilder: (context, index, realIndex) {
                              final banner = state.banners[index];
                              return DonateCard(
                                title: banner.title,
                                imageUrl: banner.imageUrl,
                                id: banner.id,
                              );
                            },
                            options: CarouselOptions(
                              height: 200,
                              enlargeCenterPage: true,
                              viewportFraction: 1.0,
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 5),
                              onPageChanged: (index, reason) {
                                setState(() => _current = index);
                              },
                            ),
                          ),
                        // 🔘 Dot Indicators
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(state.banners.length, (index) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _current == index
                                    ? Colors.black
                                    : Colors.grey.shade400,
                              ),
                            );
                          }),
                        ),

                        // Latest Book Suggestions
                        LatestBook(books: state.latestBooks),

                        // SectionTitle(title: "Recommended for you"),
                        Recommended(books: state.recommendedBooks),

                        CardDetails(stats: state.stats.first),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),

                  // Animated AppBar
                  AnimatedSlide(
                    offset:
                        _isAppBarVisible ? Offset.zero : const Offset(0, -1),
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      height: 90,
                      padding:
                          const EdgeInsets.only(top: 60, left: 5, right: 5),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  print("This icon butt");
                                },
                                icon: Icon(Icons.search, color: Colors.black),
                              ),
                              SizedBox(width: 12),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.notifications_none,
                                    color: Colors.black),
                              ),
                              SizedBox(width: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is HomeMainError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text("Unknown state"));
            }
          },
        ),
      ),
    );
  }
}
//Section Title---------------------------------------------------

//Donate Section -----------------------------------------------

class DonateCard extends StatelessWidget {
  final String title;
  final String id;
  final String imageUrl;

  const DonateCard({
    super.key,
    required this.title,
    required this.id,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 188,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFD0E1FD),
        border: Border.all(width: 1, color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Left: Text content
          SizedBox(
            width: 220,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizeWords(title),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Donate books and help someone learn, grow, and succeed.",
                  softWrap: true,
                  maxLines: 3,
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(44, 224, 127, 1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Donate",
                      style: TextStyle(
                        color: Color(0xFF052E44),
                      )),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Right: Book Image
          ClipRRect(
            borderRadius: BorderRadius.circular(5.66),
            child: Image.network(
              imageUrl,
              width: 96.26,
              height: 136,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported),
            ),
          ),
        ],
      ),
    );
  }
}

//BookDetailsWidget-----------------------------

//Latest Book Suggestions--------------------------------------
class LatestBook extends StatefulWidget {
  final List<LatestBookEntity> books;
  const LatestBook({super.key, required this.books});

  @override
  State<LatestBook> createState() => _LatestBookState();
}

class _LatestBookState extends State<LatestBook> {
  String _userId;
  _LatestBookState() : _userId = '';

  @override
  void initState() {
    super.initState();
    SecureStorageUtil().getUser().then((user) {
      if (user != null) {
        setState(() {
          _userId = user.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) {
      return const SizedBox.shrink();
    }
    String apiEndpoint =
        'https://readbuddy-server.onrender.com/api/getmostrequestedbook/$_userId';
    return Column(
      children: [
        SectionTitle(
          title: "Latest Book Suggestions",
          apiEndpoint: apiEndpoint,
        ),
        LayoutBuilder(builder: (context, constraints) {
          final double sliderHeight =
              constraints.maxHeight < 400 ? constraints.maxHeight - 30 : 332;
          return Container(
            height: sliderHeight + 27,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(8),
            child: CarouselSlider(
              options: CarouselOptions(
                height: sliderHeight,
                enableInfiniteScroll: false,
                enlargeCenterPage: false,
                viewportFraction: 0.6, // controls how wide each item is
                padEnds: false,
              ),
              items: widget.books
                  .map((book) => BookCard(
                        bookId: book.id,
                        title: book.title,
                        category: book.category,
                        donor: book.donor,
                        format: book.format,
                        duration: book.duration,
                        imageUrl: book.imageUrl,
                        formatUrl: book.formatUrl,
                      ))
                  .toList(),
            ),
          );
        }),
      ],
    );
  }
}

//Book Card for recommendation -----------------------------

//Recommended Section-----------------------
class Recommended extends StatefulWidget {
  final List<RecommendedBookCardEntity> books;
  const Recommended({super.key, required this.books});

  @override
  State<Recommended> createState() => _RecommendedState();
}

class _RecommendedState extends State<Recommended> {
  String _userId;
  _RecommendedState() : _userId = '';

  @override
  void initState() {
    super.initState();
    SecureStorageUtil().getUser().then((user) {
      if (user != null) {
        setState(() {
          _userId = user.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) {
      return const SizedBox.shrink();
    }
    String apiEndpoint =
        'https://readbuddy-server.onrender.com/api/recommend/$_userId';
    return Column(
      children: [
        SectionTitle(
          title: "Recommended for you",
          apiEndpoint: apiEndpoint,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final double sliderHeight =
                constraints.maxHeight < 400 ? constraints.maxHeight - 30 : 356;
            return Container(
              width: double.infinity,
              height: sliderHeight + 27,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(8),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: sliderHeight,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: false,
                  viewportFraction: 0.6, // controls how wide each item is
                  padEnds: false,
                ),
                items: widget.books
                    .map((book) => RecommendedBookCard(
                          bookId: book.id,
                          title: book.title,
                          category: book.category,
                          donor: book.donor,
                          format: book.format,
                          duration: book.duration,
                          imageUrl: book.imageUrl,
                          formatUrl: book.formatUrl,
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Last widget ----------------------------------------------------------------------------

class CardDetails extends StatelessWidget {
  final StatEntity stats;
  const CardDetails({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //dynamically adjust margin based on screen width
    final horizontalMargin = screenWidth < 350 ? 16.0 : 16.0;
    return Container(
      height: 165,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          width: 1,
          color: Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3), // x, y
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.only(left: 16, top: 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "This Month",
                style: TextStyle(
                  color: Color(0xFF052E44),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  wordSpacing: 0,
                  fontFamily: 'popins',
                ),
              ),
              SizedBox(height: 12), // spacing between text and container
              Container(
                margin: EdgeInsets.only(right: horizontalMargin),
                // You can now add a column or layout here
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatColumn(
                      // icon: book,
                      iconPath: 'assets/icons/Vector.png',
                      number: stats.bookDonated,
                      label: "Books Donated",
                    ),
                    SizedBox(width: 6),
                    StatColumn(
                      // icon: Icons.people,
                      iconPath: 'assets/icons/Group.png',
                      number: stats.activeUsers,
                      label: "Active Users",
                    ),
                    SizedBox(width: 6),
                    StatColumn(
                      // icon: Icons.local_shipping,
                      iconPath: 'assets/icons/car.png',
                      number: stats.deleveries,
                      label: "Delivery",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
