import 'package:equatable/equatable.dart';
import '../../../domain/entities/book_variant_entity.dart';

abstract class VariantEvent extends Equatable {
  const VariantEvent();

  @override
  List<Object?> get props => [];
}

class LoadVariants extends VariantEvent {
  final String bookId;

  const LoadVariants(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class CreateVariantEvent extends VariantEvent {
  final BookVariantEntity variant;

  const CreateVariantEvent(this.variant);

  @override
  List<Object?> get props => [variant];
}

class UpdateVariantEvent extends VariantEvent {
  final String variantId;
  final Map<String, dynamic> data;

  const UpdateVariantEvent(this.variantId, this.data);

  @override
  List<Object?> get props => [variantId, data];
}

class DeleteVariantEvent extends VariantEvent {
  final String variantId;
  final String bookId;

  const DeleteVariantEvent(this.variantId, this.bookId);

  @override
  List<Object?> get props => [variantId, bookId];
}

class AddFormatEvent extends VariantEvent {
  final String variantId;
  final String bookId;
  final List<BookFormatEntity> formats;

  const AddFormatEvent(this.variantId, this.bookId, this.formats);

  @override
  List<Object?> get props => [variantId, bookId, formats];
}

class RemoveFormatEvent extends VariantEvent {
  final String variantId;
  final String bookId;
  final String formatId;

  const RemoveFormatEvent(this.variantId, this.bookId, this.formatId);

  @override
  List<Object?> get props => [variantId, bookId, formatId];
}
