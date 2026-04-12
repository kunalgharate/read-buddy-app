import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/donated_books/domain/entities/donated_books_entity.dart';

import '../repositories/donated_books_repository.dart';

@injectable
class GetDonatedBooks {
  final DonatedBooksRepository donatedBooksRepository;

  GetDonatedBooks(this.donatedBooksRepository);

  Future<List<DonatedBooksEntity>> call() =>
      donatedBooksRepository.getDonatedBooks();
}
