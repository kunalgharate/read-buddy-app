import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/core/config/app_config.dart';
import 'package:read_buddy_app/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:read_buddy_app/features/reviews/data/models/review_model.dart';
import 'package:read_buddy_app/features/reviews/domain/entities/review_entity.dart';
import 'package:read_buddy_app/features/reviews/presentation/widgets/review_card.dart';

/// Regression tests for the "review details are not displayed" bug.
///
/// The root cause was a data-contract mismatch: the backend returns a review
/// as `{ user: {_id, name}, book, rating, title, review, ... }` while the app
/// read legacy keys (`userId`, `bookId`, `comment`). These tests lock in the
/// parsing of the new contract and that the card actually renders the title,
/// rating and comment.
class _FakeHttpAdapter implements HttpClientAdapter {
  _FakeHttpAdapter({required this.body, this.statusCode = 200});

  final String body;
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() {
    AppConfig.init(
      environment: Environment.dev,
      baseUrl: 'http://localhost',
      appName: 'read_buddy_test',
    );
  });

  group('ReviewModel.fromJson', () {
    test('parses the new contract: user map, book, title and review', () {
      final model = ReviewModel.fromJson({
        '_id': 'r1',
        'user': {'_id': 'u1', 'name': 'Deborah'},
        'book': 'b1',
        'rating': 5,
        'title': 'Great book',
        'review': 'Loved every page.',
        'helpfulCount': 2,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-02T00:00:00.000Z',
      });

      expect(model.id, 'r1');
      expect(model.userId, 'u1');
      expect(model.userName, 'Deborah');
      expect(model.bookId, 'b1');
      expect(model.rating, 5);
      expect(model.title, 'Great book');
      expect(model.comment, 'Loved every page.');
      expect(model.helpfulCount, 2);
    });

    test('still parses the legacy contract: userId, bookId and comment', () {
      final model = ReviewModel.fromJson({
        '_id': 'r2',
        'userId': 'u2',
        'bookId': 'b2',
        'rating': 4,
        'comment': 'Solid read.',
      });

      expect(model.userId, 'u2');
      expect(model.bookId, 'b2');
      expect(model.rating, 4);
      expect(model.comment, 'Solid read.');
      // Legacy payloads have no title -> defaults to empty, not null.
      expect(model.title, '');
    });

    test('accepts a user id string and a populated book map', () {
      final model = ReviewModel.fromJson({
        '_id': 'r3',
        'user': 'u3',
        'book': {'_id': 'b3', 'title': 'Some Book'},
        'rating': 3,
        'review': 'Okay.',
      });

      expect(model.userId, 'u3');
      expect(model.userName, '');
      expect(model.bookId, 'b3');
    });

    test('coerces a double rating to int', () {
      final model = ReviewModel.fromJson({'rating': 4.0});

      expect(model.rating, 4);
    });

    test('falls back safely when rating and text fields are missing', () {
      final model = ReviewModel.fromJson({});

      expect(model.rating, 0);
      expect(model.comment, '');
      expect(model.title, '');
      expect(model.userId, '');
      expect(model.bookId, '');
      expect(model.helpfulCount, 0);
    });
  });

  group('ReviewRemoteDataSourceImpl.getBookReviews', () {
    ReviewRemoteDataSourceImpl dataSourceReturning(Map<String, dynamic> json) {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter =
          _FakeHttpAdapter(body: jsonEncode(json), statusCode: 200);
      return ReviewRemoteDataSourceImpl(dio: dio);
    }

    test('maps reviews and reads the new `total` field', () async {
      final ds = dataSourceReturning({
        'success': true,
        'reviews': [
          {
            '_id': 'r1',
            'user': {'_id': 'u1', 'name': 'Deborah'},
            'book': 'b1',
            'rating': 5,
            'title': 'Great book',
            'review': 'Loved every page.',
          },
        ],
        'averageRating': 5,
        'total': 7,
      });

      final result = await ds.getBookReviews('b1');
      final reviews = result['reviews'] as List<ReviewModel>;

      expect(reviews, hasLength(1));
      expect(reviews.single.title, 'Great book');
      expect(reviews.single.comment, 'Loved every page.');
      expect(reviews.single.userName, 'Deborah');
      expect(reviews.single.rating, 5);
      expect(result['totalReviews'], 7);
      expect(result['averageRating'], 5.0);
    });

    test('falls back to legacy `totalReviews` and list length', () async {
      final legacy = dataSourceReturning({
        'reviews': [
          {'_id': 'r1', 'userId': 'u1', 'bookId': 'b1', 'rating': 4},
        ],
        'totalReviews': 3,
      });
      expect((await legacy.getBookReviews('b1'))['totalReviews'], 3);

      final noTotals = dataSourceReturning({
        'reviews': [
          {'_id': 'r1', 'userId': 'u1', 'bookId': 'b1', 'rating': 4},
          {'_id': 'r2', 'userId': 'u2', 'bookId': 'b1', 'rating': 5},
        ],
      });
      expect((await noTotals.getBookReviews('b1'))['totalReviews'], 2);
    });
  });

  group('ReviewCard', () {
    Future<void> pumpCard(WidgetTester tester, ReviewEntity review) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReviewCard(review: review)),
        ),
      );
    }

    ReviewEntity review({
      String title = '',
      String comment = '',
      int rating = 0,
      String userName = 'Deborah',
    }) {
      return ReviewEntity(
        id: 'r1',
        bookId: 'b1',
        userId: 'u1',
        userName: userName,
        userAvatar: '',
        rating: rating,
        title: title,
        comment: comment,
        createdAt: '2026-01-01T00:00:00.000Z',
        updatedAt: '2026-01-01T00:00:00.000Z',
      );
    }

    testWidgets('renders title, comment, author and star rating',
        (tester) async {
      await pumpCard(
        tester,
        review(
          title: 'Great book',
          comment: 'Loved every page.',
          rating: 4,
        ),
      );

      expect(find.text('Great book'), findsOneWidget);
      expect(find.text('Loved every page.'), findsOneWidget);
      expect(find.text('Deborah'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('hides title/comment when empty', (tester) async {
      await pumpCard(tester, review(rating: 3));

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      // Only the author name text remains; no empty title/comment widgets.
      expect(find.text(''), findsNothing);
    });

    testWidgets('falls back to Anonymous when the author name is missing',
        (tester) async {
      await pumpCard(tester, review(userName: '', comment: 'Nice.'));

      expect(find.text('Anonymous'), findsOneWidget);
    });
  });
}
