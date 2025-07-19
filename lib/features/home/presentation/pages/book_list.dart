import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:read_buddy_app/features/home/presentation/screens/card_widgets/recommendedBookCard.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/models/home_response_model.dart';
import '../screens/card_widgets/bookCard.dart';

class BookListPage extends StatefulWidget {
  final String title;
  final String apiEndpoint; // 'latest' or 'recommended'

  const BookListPage({
    super.key,
    required this.title,
    required this.apiEndpoint,
  });

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late HomeRemoteDataSourceImpl _dataSource;
  Future<List<BookResponseModel>>? _booksFuture;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _dataSource = HomeRemoteDataSourceImpl(Dio(), SecureStorageUtil());
    _loadUserAndFetchBooks();
  }

  Future<void> _loadUserAndFetchBooks() async {
    final user = await SecureStorageUtil().getUser();
    if (user != null) {
      setState(() {
        _userId = user.id;
        _booksFuture = fetchBooks(widget.apiEndpoint, _userId);
      });
    }
  }

  Future<List<BookResponseModel>> fetchBooks(
      String apiEndpoint, String userId) async {
    try {
      if (apiEndpoint.startsWith('http')) {
        final token = await SecureStorageUtil().getAccessToken();
        final response = await Dio().get(
          apiEndpoint,
          options: Options(
            headers: {
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          ),
        );
        if (response.statusCode == 200) {
          final List<dynamic> data =
              response.data is Map && response.data.containsKey('recommended')
                  ? response.data['recommended']
                  : response.data;
          return data.map((json) => BookResponseModel.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load books from URL');
        }
      } else if (apiEndpoint == 'latest') {
        return await _dataSource.fetchLatestBooks(userId);
      } else if (apiEndpoint == 'recommended') {
        return await _dataSource.fetchRecommendedBooks(userId);
      } else {
        throw Exception('Invalid API endpoint: $apiEndpoint');
      }
    } catch (e) {
      throw Exception('Failed to fetch books: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<BookResponseModel>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books found.'));
          } else {
            final books = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: books.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cards per row
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.62, // match your card size ratio
                ),
                itemBuilder: (context, index) {
                  final book = books[index];
                  print("ApiEndPoint: ${widget.apiEndpoint}");
                  if (widget.apiEndpoint == 'latest') {
                    return BookCard(
                      bookId: book.id,
                      title: book.title,
                      category: book.category,
                      donor: book.donor,
                      format: book.format,
                      duration: book.duration,
                      imageUrl: book.imageUrl,
                      formatUrl: book.formatUrl,
                      showLockIcon: false,
                    );
                  } else {
                    return RecommendedBookCard(
                      bookId: book.id,
                      title: book.title,
                      category: book.category,
                      donor: book.donor,
                      format: book.format,
                      duration: book.duration,
                      imageUrl: book.imageUrl,
                      formatUrl: book.formatUrl,
                      showLockIcon: false,
                    );
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}
