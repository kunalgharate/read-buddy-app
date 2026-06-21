import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_variant.dart';
import '../../../domain/usecases/update_variant.dart';
import '../../../domain/usecases/delete_variant.dart';
import '../../../domain/usecases/add_format.dart';
import '../../../domain/usecases/remove_format.dart';
import '../../../domain/usecases/get_variants_for_book.dart';
import 'variant_event.dart';
import 'variant_state.dart';

class VariantBloc extends Bloc<VariantEvent, VariantState> {
  final GetVariantsForBookUsecase getVariantsForBook;
  final CreateVariantUsecase createVariant;
  final UpdateVariantUsecase updateVariant;
  final DeleteVariantUsecase deleteVariant;
  final AddFormatUsecase addFormat;
  final RemoveFormatUsecase removeFormat;

  VariantBloc({
    required this.getVariantsForBook,
    required this.createVariant,
    required this.updateVariant,
    required this.deleteVariant,
    required this.addFormat,
    required this.removeFormat,
  }) : super(VariantInitial()) {
    on<LoadVariants>(_onLoadVariants);
    on<CreateVariantEvent>(_onCreateVariant);
    on<UpdateVariantEvent>(_onUpdateVariant);
    on<DeleteVariantEvent>(_onDeleteVariant);
    on<AddFormatEvent>(_onAddFormat);
    on<RemoveFormatEvent>(_onRemoveFormat);
  }

  Future<void> _onLoadVariants(
      LoadVariants event, Emitter<VariantState> emit) async {
    emit(VariantLoading());
    try {
      final variants = await getVariantsForBook(event.bookId);
      emit(VariantsLoaded(variants));
    } catch (e) {
      emit(VariantError('Failed to load variants: $e'));
    }
  }

  Future<void> _onCreateVariant(
      CreateVariantEvent event, Emitter<VariantState> emit) async {
    emit(VariantLoading());
    try {
      final variant = await createVariant(event.variant);
      emit(VariantCreated(variant));
    } catch (e) {
      emit(VariantError('Failed to create variant: $e'));
    }
  }

  Future<void> _onUpdateVariant(
      UpdateVariantEvent event, Emitter<VariantState> emit) async {
    emit(VariantLoading());
    try {
      final variant = await updateVariant(event.variantId, event.data);
      emit(VariantUpdated(variant));
    } catch (e) {
      emit(VariantError('Failed to update variant: $e'));
    }
  }

  Future<void> _onDeleteVariant(
      DeleteVariantEvent event, Emitter<VariantState> emit) async {
    emit(VariantLoading());
    try {
      await deleteVariant(event.variantId);
      emit(VariantDeleted());
      // Reload variants after deletion
      final variants = await getVariantsForBook(event.bookId);
      emit(VariantsLoaded(variants));
    } catch (e) {
      emit(VariantError('Failed to delete variant: $e'));
    }
  }

  Future<void> _onAddFormat(
      AddFormatEvent event, Emitter<VariantState> emit) async {
    emit(VariantLoading());
    try {
      final variant = await addFormat(event.variantId, event.formats);
      emit(FormatAdded(variant));
    } catch (e) {
      emit(VariantError('Failed to add format: $e'));
    }
  }

  Future<void> _onRemoveFormat(
      RemoveFormatEvent event, Emitter<VariantState> emit) async {
    emit(VariantLoading());
    try {
      await removeFormat(event.variantId, event.formatId);
      emit(FormatRemoved());
      // Reload variants after format removal
      final variants = await getVariantsForBook(event.bookId);
      emit(VariantsLoaded(variants));
    } catch (e) {
      emit(VariantError('Failed to remove format: $e'));
    }
  }
}
