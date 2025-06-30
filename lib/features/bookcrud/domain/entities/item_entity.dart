import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String name;

  Item({required this.id, required this.name});

  @override
  // TODO: implement props
  List<Object?> get props => [id, name];
}
