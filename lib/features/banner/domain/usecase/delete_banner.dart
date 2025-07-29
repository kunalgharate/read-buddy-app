import 'package:read_buddy_app/features/banner/domain/repository/banner_repository.dart';

class DeleteBannerUsecase {
  final BannerRepository repository;

  DeleteBannerUsecase(this.repository);

  Future<void> call({
    required String id,
  }) {
    return repository.deleteBanner(
      id: id,
    );
  }
}
