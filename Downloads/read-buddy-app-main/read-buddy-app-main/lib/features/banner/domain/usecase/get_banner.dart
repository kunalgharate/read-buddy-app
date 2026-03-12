import 'package:read_buddy_app/features/banner/domain/entity/banner_entity.dart';
import 'package:read_buddy_app/features/banner/domain/repository/banner_repository.dart';

class GetBannerUsecase {
  final BannerRepository repository;

  GetBannerUsecase(this.repository);

  Future<List<BannerEntity>> call() {
    return repository.getBannerList();
  }
}
