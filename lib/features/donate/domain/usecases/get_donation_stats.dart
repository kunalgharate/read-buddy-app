import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';
import 'package:read_buddy_app/features/donate/domain/repositories/donate_repository.dart';

class GetDonationStats {
  final DonateRepository repository;

  GetDonationStats({required this.repository});

  Future<DonationStats> call() async {
    return await repository.getDonationStats();
  }
}
