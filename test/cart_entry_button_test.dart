import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/features/borrow_order/domain/entities/borrow_order_entity.dart';
import 'package:read_buddy_app/features/borrow_order/domain/repositories/borrow_order_repository.dart';
import 'package:read_buddy_app/features/borrow_order/domain/usecases/borrow_order_usecases.dart';
import 'package:read_buddy_app/features/borrow_order/presentation/bloc/borrow_order_bloc.dart';
import 'package:read_buddy_app/features/borrow_order/presentation/cart_badge_notifier.dart';
import 'package:read_buddy_app/features/borrow_order/presentation/widgets/cart_entry_button.dart';

/// Only `getMyDraft` is exercised by the badge; every other repository call is
/// unreachable from this widget.
class _FakeBorrowOrderRepository implements BorrowOrderRepository {
  _FakeBorrowOrderRepository(this.draft);

  BorrowOrderEntity draft;

  @override
  Future<BorrowOrderEntity> getMyDraft() async => draft;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('not used: ${invocation.memberName}');
}

BorrowOrderBloc _blocFor(BorrowOrderRepository repository) {
  return BorrowOrderBloc(
    getMyDraft: GetMyDraft(repository),
    addBookToOrder: AddBookToOrder(repository),
    removeBookFromOrder: RemoveBookFromOrder(repository),
    submitOrder: SubmitOrder(repository),
    getMyOrders: GetMyOrders(repository),
    cancelOrder: CancelOrder(repository),
    createPayment: CreatePayment(repository),
    verifyPayment: VerifyPayment(repository),
  );
}

BorrowOrderEntity _draft(int items) {
  return BorrowOrderEntity(
    id: 'order-1',
    bookRequests: List.generate(
      items,
      (i) => OrderBookItem(
        id: 'request-$i',
        bookId: 'book-$i',
        bookTitle: 'Book $i',
        bookAuthor: 'Author',
        bookCoverUrl: '',
        bookPrice: 100,
        bookPages: 100,
        status: 'draft',
      ),
    ),
    totalBookValue: items * 100,
    budgetLimit: 1000,
    status: BorrowOrderStatus.draft,
    paymentStatus: PaymentStatus.PENDING,
    deliveryFee: 0,
    createdAt: DateTime(2025, 1, 1),
  );
}

Widget _host(BorrowOrderBloc bloc) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        actions: [CartEntryButton(bloc: bloc)],
      ),
    ),
    onGenerateRoute: (settings) => MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Text('cart screen')),
    ),
  );
}

void main() {
  testWidgets('badge shows the number of books in the draft cart',
      (tester) async {
    final bloc = _blocFor(_FakeBorrowOrderRepository(_draft(2)));
    addTearDown(bloc.close);

    await tester.pumpWidget(_host(bloc));
    bloc.add(const LoadDraftOrder());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('tapping the cart button opens the borrow cart', (tester) async {
    final bloc = _blocFor(_FakeBorrowOrderRepository(_draft(1)));
    addTearDown(bloc.close);

    await tester.pumpWidget(_host(bloc));
    bloc.add(const LoadDraftOrder());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CartEntryButton));
    await tester.pumpAndSettle();

    expect(find.text('cart screen'), findsOneWidget);
  });

  testWidgets('badge is hidden when the draft cart is empty', (tester) async {
    final bloc = _blocFor(_FakeBorrowOrderRepository(_draft(0)));
    addTearDown(bloc.close);

    await tester.pumpWidget(_host(bloc));
    bloc.add(const LoadDraftOrder());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('badge refreshes after the cart changes elsewhere',
      (tester) async {
    final repository = _FakeBorrowOrderRepository(_draft(1));
    final bloc = _blocFor(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_host(bloc));
    bloc.add(const LoadDraftOrder());
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    repository.draft = _draft(3);
    markCartChanged();
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
  });
}
