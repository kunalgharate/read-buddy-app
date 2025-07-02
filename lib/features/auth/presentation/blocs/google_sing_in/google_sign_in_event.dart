import 'package:equatable/equatable.dart';

abstract class GoogleSignInEvent extends Equatable {
  const GoogleSignInEvent();
}

class GoogleSignInRequested extends GoogleSignInEvent {
  @override
  List<Object?> get props => [];
}
