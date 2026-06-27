import 'dart:io';

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
  final List<File> ebookFiles;
  final List<File> audioParts;
  final List<File> videoParts;

  const CreateVariantEvent(
    this.variant, {
    this.ebookFiles = const [],
    this.audioParts = const [],
    this.videoParts = const [],
  });

  @override
  List<Object?> get props => [variant, ebookFiles, audioParts, videoParts];
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
  final List<File> ebookFiles;
  final List<File> audioParts;
  final List<File> videoParts;

  const AddFormatEvent(
    this.variantId,
    this.bookId,
    this.formats, {
    this.ebookFiles = const [],
    this.audioParts = const [],
    this.videoParts = const [],
  });

  @override
  List<Object?> get props =>
      [variantId, bookId, formats, ebookFiles, audioParts, videoParts];
}

class RemoveFormatEvent extends VariantEvent {
  final String variantId;
  final String bookId;
  final String formatId;

  const RemoveFormatEvent(this.variantId, this.bookId, this.formatId);

  @override
  List<Object?> get props => [variantId, bookId, formatId];
}

/// Adds parts/files to an existing format incrementally.
/// Used when adding new audio/video chapters to an existing audiobook/videobook,
/// or adding ebook files to an existing ebook format.
class AddPartsToFormatEvent extends VariantEvent {
  final String variantId;
  final String formatId;
  final String bookId;
  final List<MediaPartEntity> parts;
  final List<File> ebookFiles;
  final List<File> audioParts;
  final List<File> videoParts;

  const AddPartsToFormatEvent({
    required this.variantId,
    required this.formatId,
    required this.bookId,
    this.parts = const [],
    this.ebookFiles = const [],
    this.audioParts = const [],
    this.videoParts = const [],
  });

  @override
  List<Object?> get props =>
      [variantId, formatId, bookId, parts, ebookFiles, audioParts, videoParts];
}
