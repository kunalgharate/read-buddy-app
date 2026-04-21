---
inclusion: manual
---

# Testing Guide

## Structure
Place tests in `test/features/<feature>/` mirroring the lib structure.

## Priority
1. Use cases (pure Dart, easiest to test)
2. BLoCs (use `bloc_test` package)
3. Widgets (use `flutter_test`)

## Packages
- `flutter_test` (already in dev_dependencies)
- Add `bloc_test` and `mocktail` when starting tests

## Use Case Test
```dart
class MockBookRepository extends Mock implements BookRepository {}
void main() {
  late GetBooks useCase;
  late MockBookRepository mockRepo;
  setUp(() {
    mockRepo = MockBookRepository();
    useCase = GetBooks(mockRepo);
  });
  test('should return list of books', () async {
    when(() => mockRepo.getBooks()).thenAnswer((_) async => [testBook]);
    final result = await useCase();
    expect(result, [testBook]);
  });
}
```

## BLoC Test
```dart
blocTest<BookBloc, BookState>(
  'emits [BookLoading, BookLoaded] when LoadBooks is added',
  build: () {
    when(() => mockGetBooks()).thenAnswer((_) async => [testBook]);
    return BookBloc(mockGetBooks);
  },
  act: (bloc) => bloc.add(LoadBooks()),
  expect: () => [BookLoading(), BookLoaded([testBook])],
);
```

## Commands
```bash
flutter test                       # All tests
flutter test test/features/books/  # Specific feature
flutter test --coverage            # With coverage
```
