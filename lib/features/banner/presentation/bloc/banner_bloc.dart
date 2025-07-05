import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/banner/datasources/model/banner_model.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/create_banner.dart';

part 'banner_event.dart';
part 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final CreateBannerUsecase createBannerUsecase;
  BannerBloc({required this.createBannerUsecase}) : super(BannerInitial()) {
    on<CreateBannerEvent>(_onCreateBanner);
  }

  Future<void> _onCreateBanner(
      CreateBannerEvent event, Emitter<BannerState> emit) async {
    emit(BannerLoading());
    try {
      await createBannerUsecase.call(
        title: event.title,
        link: event.link,
        description: event.description,
        bannerType: event.bannerType,
        bannerImage: event.bannerImage,
      );
      // emit(BannerLoaded();
    } catch (e) {
      emit(BannerError('Failed to create banner : ${e.toString()}'));
    }
  }
}
