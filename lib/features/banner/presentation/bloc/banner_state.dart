part of 'banner_bloc.dart';

sealed class BannerState extends Equatable {
  const BannerState();

  @override
  List<Object> get props => [];
}

final class BannerInitial extends BannerState {}

final class BannerLoading extends BannerState {}

final class BannerLoaded extends BannerState {
  final BannerModel banner;

  const BannerLoaded(this.banner);

  @override
  List<Object> get props => [banner];
}

final class BannerError extends BannerState {
  final String message;

  const BannerError(this.message);

  @override
  List<Object> get props => [message];
}
