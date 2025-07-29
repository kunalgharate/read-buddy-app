part of 'banner_bloc.dart';

sealed class BannerEvent extends Equatable {
  const BannerEvent();

  @override
  List<Object> get props => [];
}

class GetBannerListEvent extends BannerEvent {}

class CreateBannerEvent extends BannerEvent {
  final String title;
  final String? link;
  final String? description;
  final String bannerType;
  final File bannerImage;

  const CreateBannerEvent({
    required this.title,
    this.link,
    this.description,
    required this.bannerType,
    required this.bannerImage,
  });

  @override
  List<Object> get props => [title, bannerType, bannerImage];
}

class UpdateBannerEvent extends BannerEvent {
  final String id;
  final String title;
  final String link;
  final String description;
  final String bannerType;
  final File bannerImage;

  const UpdateBannerEvent({
    required this.id,
    required this.title,
    required this.link,
    required this.description,
    required this.bannerType,
    required this.bannerImage,
  });

  @override
  List<Object> get props => [title, link, description, bannerType, bannerImage];
}

class DeleteBannerEvent extends BannerEvent {
  final String id;
  const DeleteBannerEvent(this.id);
}
