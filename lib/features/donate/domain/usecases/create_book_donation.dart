import 'package:read_buddy_app/features/donate/domain/entities/book_donation_request.dart';
import 'package:read_buddy_app/features/donate/domain/repositories/donate_repository.dart';

class CreateBookDonation {
  final DonateRepository repository;

  CreateBookDonation({required this.repository});

  Future<void> call(BookDonationRequest request) async {
    return await repository.createBookDonation(request);
  }
}