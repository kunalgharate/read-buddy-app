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

  /// Only items the user has actually started and not finished.
  List<ReadingProgressEntity> get _pending =>
      items.where((e) => !e.completed).toList();

  /// Most recently read pending book (for a single hero highlight).
  ReadingProgressEntity? get lastRead =>
      _pending.isNotEmpty ? _pending.first : null;

  /// Continue-reading list per requirement:
  ///  - up to 3 pending ebooks
  ///  - 1 pending audiobook (if any)
  ///  - 1 pending videobook (if any)
  /// Ordered most-recent first overall. Empty when nothing is started.
  List<ReadingProgressEntity> get continueReading {
    final ebooks = _pending.where((e) => e.format == 'ebook').take(3);
    final audio = _pending.where((e) => e.format == 'audiobook').take(1);
    final video = _pending.where((e) => e.format == 'videobook').take(1);

    final selected = {
      for (final e in [...ebooks, ...audio, ...video]) e.bookId: e,
    };
    // Preserve recency order (items already sorted by lastReadAt desc).
    return _pending.where((e) => selected.containsKey(e.bookId)).toList();
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
