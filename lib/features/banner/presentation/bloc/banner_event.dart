part of 'banner_bloc.dart';

sealed class BannerEvent extends Equatable {
  const BannerEvent();

  @override
  List<Object> get props => [];
}

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
