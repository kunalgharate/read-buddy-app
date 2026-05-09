import 'package:dio/dio.dart';
import 'package:read_buddy_app/features/donate/domain/repositories/donate_repository.dart';

class UploadReceipt {
  final DonateRepository repository;

  UploadReceipt({required this.repository});

  Future<void> call(String donationId, FormData formData) async {
    return await repository.uploadReceipt(donationId, formData);
  }
}
