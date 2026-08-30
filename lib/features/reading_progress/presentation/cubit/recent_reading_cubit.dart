import 'package:bloc/bloc.dart';

import '../../domain/entities/reading_progress_entity.dart';
import '../../domain/usecases/reading_progress_usecases.dart';

abstract class RecentReadingState {
  const RecentReadingState();
}

class RecentReadingInitial extends RecentReadingState {
  const RecentReadingInitial();
}

class RecentReadingLoading extends RecentReadingState {
  const RecentReadingLoading();
}

class RecentReadingLoaded extends RecentReadingState {
  final List<ReadingProgressEntity> items;
  const RecentReadingLoaded(this.items);

  /// Most recently read book (for the "Continue reading" hero card).
  ReadingProgressEntity? get lastRead => items.isNotEmpty ? items.first : null;

  /// Best recent item per format (one ebook, one audiobook, one videobook).
  List<ReadingProgressEntity> get oncePerFormat {
    final seen = <String>{};
    final out = <ReadingProgressEntity>[];
    for (final item in items) {
      if (seen.add(item.format)) out.add(item);
    }
    return out;
  }
}

class RecentReadingEmpty extends RecentReadingState {
  const RecentReadingEmpty();
}

class RecentReadingCubit extends Cubit<RecentReadingState> {
  final GetRecentReadingProgress _getRecent;

  RecentReadingCubit(this._getRecent) : super(const RecentReadingInitial());

  Future<void> load({int limit = 10}) async {
    emit(const RecentReadingLoading());
    try {
      final items = await _getRecent(limit: limit);
      if (items.isEmpty) {
        emit(const RecentReadingEmpty());
      } else {
        emit(RecentReadingLoaded(items));
      }
    } catch (_) {
      emit(const RecentReadingEmpty());
    }
  }
}
