---
inclusion: fileMatch
fileMatchPattern: ["**/blocs/**", "**/bloc/**", "**/cubit/**"]
---

# BLoC & Cubit Patterns

## BLoC (preferred for new code)

Use part files + sealed class + Equatable:

```dart
// feature_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
part 'feature_event.dart';
part 'feature_state.dart';

class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final MyUseCase _useCase;
  FeatureBloc(this._useCase) : super(FeatureInitial()) {
    on<LoadFeature>(_onLoad);
  }
  Future<void> _onLoad(LoadFeature event, Emitter<FeatureState> emit) async {
    emit(FeatureLoading());
    try {
      final result = await _useCase(params);
      emit(FeatureLoaded(result));
    } catch (error) {
      emit(FeatureError(ErrorHandler.getErrorMessage(error)));
    }
  }
}
```

```dart
// feature_event.dart
part of 'feature_bloc.dart';
sealed class FeatureEvent extends Equatable {
  const FeatureEvent();
  @override
  List<Object> get props => [];
}
final class LoadFeature extends FeatureEvent {}
```

```dart
// feature_state.dart
part of 'feature_bloc.dart';
sealed class FeatureState extends Equatable {
  const FeatureState();
}
final class FeatureInitial extends FeatureState {
  @override
  List<Object> get props => [];
}
```

## Cubit (for simple state)

```dart
class MyCubit extends Cubit<MyState> {
  final MyUseCase _useCase;
  MyCubit(this._useCase) : super(MyInitial());
  Future<void> load() async {
    emit(MyLoading());
    try {
      final result = await _useCase();
      emit(MyLoaded(result));
    } catch (e) { emit(MyError(e.toString())); }
  }
}
```

## Rules
- BLoC takes USE CASES, never repositories
- Error: `ErrorHandler.getErrorMessage(error)`
- Register in `_registerBlocs()` or `_registerCubits()`
- `registerFactory` for per-screen BLoCs (ProfileBloc, OnboardingBloc)
