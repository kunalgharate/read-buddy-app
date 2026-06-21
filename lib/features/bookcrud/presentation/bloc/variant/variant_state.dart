import 'package:equatable/equatable.dart';
import '../../../domain/entities/book_variant_entity.dart';

abstract class VariantState extends Equatable {
  const VariantState();

  @override
  List<Object?> get props => [];
}

class VariantInitial extends VariantState {}

class VariantLoading extends VariantState {}

class VariantsLoaded extends VariantState {
  final List<BookVariantEntity> variants;

  const VariantsLoaded(this.variants);

  @override
  List<Object?> get props => [variants];
}

class VariantCreated extends VariantState {
  final BookVariantEntity variant;

  const VariantCreated(this.variant);

  @override
  List<Object?> get props => [variant];
}

class VariantUpdated extends VariantState {
  final BookVariantEntity variant;

  const VariantUpdated(this.variant);

  @override
  List<Object?> get props => [variant];
}

class VariantDeleted extends VariantState {}

class FormatAdded extends VariantState {
  final BookVariantEntity variant;

  const FormatAdded(this.variant);

  @override
  List<Object?> get props => [variant];
}

class FormatRemoved extends VariantState {}

class VariantError extends VariantState {
  final String message;

  const VariantError(this.message);

  @override
  List<Object?> get props => [message];
}
