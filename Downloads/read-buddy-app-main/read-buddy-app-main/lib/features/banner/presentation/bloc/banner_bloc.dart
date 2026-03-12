import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:read_buddy_app/features/banner/domain/entity/banner_entity.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/create_banner.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/delete_banner.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/get_banner.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/update_banner.dart';

part 'banner_event.dart';
part 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final GetBannerUsecase getBannerUsecase;
  final CreateBannerUsecase createBannerUsecase;
  final UpdateBannerUsecase updateBannerUsecase;
  final DeleteBannerUsecase deleteBannerUsecase;
  BannerBloc(
      {required this.getBannerUsecase,
      required this.createBannerUsecase,
      required this.updateBannerUsecase,
      required this.deleteBannerUsecase})
      : super(BannerInitial()) {
    on<GetBannerListEvent>(_onGetBanners);
    on<CreateBannerEvent>(_onCreateBanner);
    on<UpdateBannerEvent>(_onUpdateBanner);
    on<DeleteBannerEvent>(_onDeleteBanner);
  }

  Future<void> _onGetBanners(
      GetBannerListEvent event, Emitter<BannerState> emit) async {
    emit(BannerLoading());
    try {
      final banners = await getBannerUsecase.call();
      emit(BannerLoaded(banners: banners));
    } catch (e) {
      emit(BannerError('Failed to create banner : ${e.toString()}'));
    }
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
      add(GetBannerListEvent());
    } catch (e) {
      emit(BannerError('Failed to create banner : ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBanner(
      UpdateBannerEvent event, Emitter<BannerState> emit) async {
    emit(BannerLoading());
    try {
      await updateBannerUsecase.call(
        id: event.id,
        title: event.title,
        link: event.link,
        description: event.description,
        bannerType: event.bannerType,
        bannerImage: event.bannerImage,
      );
      add(GetBannerListEvent());
    } catch (e) {
      emit(BannerError('Failed to update banner : ${e.toString()}'));
    }
  }

  Future<void> _onDeleteBanner(
      DeleteBannerEvent event, Emitter<BannerState> emit) async {
    emit(BannerLoading());
    try {
      await deleteBannerUsecase.call(id: event.id);
      add(GetBannerListEvent());
    } catch (e) {
      emit(BannerError('Failed to delete banner : ${e.toString()}'));
    }
  }
}
