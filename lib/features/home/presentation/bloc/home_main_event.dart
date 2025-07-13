import 'package:equatable/equatable.dart';

abstract class HomeMainEvent extends Equatable {
  const HomeMainEvent();

  @override
  List<Object> get props => [];
}

class FetchMainHomeData extends HomeMainEvent {
  final String id;
  const FetchMainHomeData(this.id);

  @override
  List<Object> get props => [id];
}
