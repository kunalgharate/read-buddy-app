import 'package:equatable/equatable.dart';

abstract class HomeMainEvent extends Equatable {
  const HomeMainEvent();

  @override
  List<Object> get props => [];
}

class FetchMainHomeData
    extends HomeMainEvent {} // to fetch the recommended book

