---
inclusion: auto
---

# Flutter Expert — ReadBuddy Project Standards

## Code Quality Tools

### Dart Formatter
- ALWAYS run `dart format .` before considering any code complete.
- Line length: 80 characters (Dart default).
- Use trailing commas on all multi-argument function calls, widget constructors, and collection literals — this ensures `dart format` produces clean, readable diffs.

### Linter
- The project uses `package:flutter_lints/flutter.yaml` as the base rule set.
- Enforced rules (see `analysis_options.yaml`):
  - `prefer_const_constructors` — use `const` wherever possible.
  - `prefer_const_declarations` — declare compile-time constants with `const`.
  - `avoid_unnecessary_containers` — don't wrap widgets in unnecessary `Container`.
- Run `flutter analyze` to check for lint violations. Fix all warnings before committing.
- `avoid_print` is set to `ignore` in this project — debug prints are acceptable.

### Dart Code Metrics (DCM)
- Configured in `analysis_options.yaml` under `dart_code_metrics`.
- Thresholds:
  - Cyclomatic complexity: max 20
  - Maximum nesting level: max 5
  - Number of parameters: max 4
- Rules enforced:
  - `no-boolean-literal-compare` — use `if (flag)` not `if (flag == true)`.
  - `no-empty-block` — no empty `{}` blocks; use a comment if intentionally empty.
  - `prefer-trailing-comma` — trailing commas on multi-line constructs.
- If a function exceeds complexity limits, break it into smaller private methods.

---

## Architecture — Feature-Based Clean Architecture

### Full Features (with API/data)

Features that interact with APIs or persistent data MUST follow the three-layer structure under `lib/features/<feature_name>/`:

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/        # Remote/local data source abstractions + implementations
│   │   └── (also seen as: remotesource/, dataresources/)
│   ├── models/              # Data models (fromJson/toJson), extend domain entities
│   └── repositories/        # Repository implementations (implements domain interface)
├── domain/
│   ├── entities/            # Pure Dart classes, no framework dependencies
│   │   └── (also seen as: entity/)
│   ├── repositories/        # Abstract repository interfaces (contracts)
│   │   └── (also seen as: repository/)
│   └── usecases/            # Single-responsibility use cases with call() method
│       └── (also seen as: usecase/)
└── presentation/
    ├── blocs/               # BLoC classes (event, state, bloc)
    │   └── (also seen as: bloc/)
    ├── pages/               # Full-screen page widgets
    │   └── (also seen as: screens/)
    └── widgets/             # Reusable UI components scoped to this feature
```

IMPORTANT: The project has naming inconsistencies in subfolder names (e.g., `remotesource` vs `datasources`, `entity` vs `entities`, `usecase` vs `usecases`). For NEW features, prefer the plural form: `datasources/`, `entities/`, `repositories/`, `usecases/`.

### Presentation-Only Features

Simple UI-only features that don't need API calls can have just a `presentation/` folder. Existing examples: `home`, `donate`, `mybook`, `rewards`, `settings`, `splash`, `onboarding`.

```
lib/features/<feature_name>/
└── presentation/
    ├── pages/
    └── widgets/
```

### Layer Rules

**Domain Layer** (innermost — no dependencies on data or presentation):
- Entities are plain Dart classes. No `json_annotation`, no Flutter imports.
- Repository interfaces are abstract classes defining the contract.
- Use cases have a single `call()` method. Accept a Params class if multiple inputs are needed.
- Example pattern (from this project):
```dart
class SignIn {
  final AuthRepository repository;
  SignIn(this.repository);
  Future<AppUser> call(SignInParams params) async {
    return await repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
```

**Data Layer** (implements domain contracts):
- Models EXTEND domain entities (e.g., `AppUserModel extends AppUser`, `BookModel extends Book`).
- Use MANUAL `fromJson()` factory constructors and `toJson()` methods — this project does NOT use `json_serializable` code generation.
- Remote data sources use `Dio` for HTTP calls. Inject `Dio` via constructor.
- Repository implementations take data sources as constructor dependencies.
- Always check network connectivity before API calls using `NetworkUtils.hasInternetConnection()`.
- Handle `DioException` and rethrow with meaningful messages.

**Presentation Layer** (UI + state management):
- Use `flutter_bloc` for state management.
- BLoC classes accept use cases via constructor injection — never repositories directly.
- Pages are `StatefulWidget` or `StatelessWidget` that use `BlocBuilder` / `BlocListener` / `MultiBlocListener`.
- Keep widget trees shallow — extract sub-widgets into the `widgets/` folder.

---

## Dependency Injection

- Use `get_it` as the service locator. The singleton is `getIt` in `lib/core/di/injection.dart`.
- Registration is MANUAL (not using `@InjectableInit` code generation despite the annotation being present).
- Registration order matters — follow this sequence:
  1. `_registerUtils()` — Dio, SecureStorage, core utilities
  2. `_registerDataSources()` — remote/local data sources
  3. `_registerRepositories()` — repository implementations
  4. `_registerUseCases()` — use cases
  5. `_registerBlocs()` — BLoCs
  6. `_registerCubits()` — Cubits (separate from BLoCs)
- Use `registerLazySingleton` for most registrations.
- Use `registerFactory` when a fresh instance is needed per screen (e.g., `OnboardingBloc`).
- When adding a new feature, register ALL layers in `injection.dart` following the existing grouped pattern with section comments.
- BLoCs that take multiple use cases use named parameters:
```dart
getIt.registerLazySingleton(() => BookCrudBloc(
  searchBooks: getIt<SearchBookUsecase>(),
  addBookCrud: getIt<AddBookUsecase>(),
  getBooksCrud: getIt<GetBooksUsecase>(),
));
```

---

## BLoC vs Cubit

### When to use BLoC
- Features with complex event-driven flows (auth, CRUD operations, multi-step processes).
- When you need distinct event types (e.g., `LoadBooks`, `RefreshBooks`, `DeleteBook`).

### When to use Cubit
- Simpler state management with single-action methods (e.g., `LocationCubit`, `UserCubit`).
- When the state transitions are straightforward (load → loaded/error).

### BLoC Event/State Patterns

IMPORTANT: The codebase has TWO patterns in use. For NEW code, prefer **Pattern A** (the more structured approach):

**Pattern A — `part` files with `sealed class` + `Equatable`** (preferred for new code):
```dart
// feature_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
part 'feature_event.dart';
part 'feature_state.dart';

class FeatureBloc extends Bloc<FeatureEvent, FeatureState> { ... }

// feature_event.dart
part of 'feature_bloc.dart';
sealed class FeatureEvent extends Equatable {
  const FeatureEvent();
  @override
  List<Object> get props => [];
}
final class LoadFeature extends FeatureEvent {}

// feature_state.dart
part of 'feature_bloc.dart';
sealed class FeatureState extends Equatable {
  const FeatureState();
}
final class FeatureInitial extends FeatureState {
  @override
  List<Object> get props => [];
}
final class FeatureLoaded extends FeatureState {
  final Data data;
  const FeatureLoaded(this.data);
  @override
  List<Object> get props => [data];
}
```

**Pattern B — Standalone files with `sealed class`, no Equatable** (exists in books feature):
```dart
// book_event.dart (no part of)
sealed class BookEvent {}
class LoadBooks extends BookEvent {}

// book_state.dart (no part of)
sealed class BookState {}
class BookLoaded extends BookState {
  final List<Book> books;
  BookLoaded(this.books);
}
```

### Error Handling in BLoCs
- Use `ErrorHandler.getErrorMessage(error)` from `lib/core/utils/error_handler.dart` to convert exceptions to user-friendly strings.
- The project does NOT use `Either<Failure, Success>` from dartz — it uses try/catch throughout.
- `ExceptionHandler.handle(DioException)` in `lib/core/error/exception_handler.dart` converts DioExceptions to typed `Failure` objects, but most BLoCs catch errors directly with `ErrorHandler`.

---

## Error Handling

- `Failure` class hierarchy in `lib/core/error/failure.dart`: `ServerFailure`, `NetworkFailure`, `CancelledFailure`, `UnknownFailure`.
- `ExceptionHandler` in `lib/core/error/exception_handler.dart` maps `DioException` types to `Failure` subclasses.
- `ErrorHandler` in `lib/core/utils/error_handler.dart` converts any error to a user-friendly `String` — this is what BLoCs use directly.
- Pattern: try/catch in BLoC → `ErrorHandler.getErrorMessage(error)` → emit error state with message string.

---

## Networking

- All HTTP calls go through `Dio` (configured in `lib/core/network/dio_client.dart`).
- API base URL: `https://readbuddy-server.onrender.com/api` (Render.com free tier — cold starts expected).
- API endpoints are centralized in `lib/core/network/api_constants.dart` with grouped constants per feature.
- HTTP status codes are also defined as constants in `ApiConstants` (e.g., `ApiConstants.success`, `ApiConstants.unauthorized`).
- Timeouts: connect 120s, receive 180s, send 120s (generous due to free-tier cold starts).
- Default headers: `Content-Type: application/json`, `Accept: application/json`, `User-Agent: ReadBuddyApp/1.0.0`.
- Automatic retry on timeout errors (built into DioClient interceptor).
- Network connectivity check: `NetworkUtils.hasInternetConnection()` — uses `InternetAddress.lookup('google.com')`.
- Server reachability check: `NetworkUtils.canReachServer(host)`.

---

## Navigation

- Named routes via `AppRouter.generateRoute()` in `lib/routes/app_router.dart`.
- Register new routes in the `switch` statement.
- Navigate with `Navigator.pushNamed(context, '/route-name')`.
- IMPORTANT: `go_router` is in pubspec.yaml but the project uses the manual `AppRouter` pattern — do NOT use `go_router`. Stay consistent with `AppRouter`.

---

## Core Utilities Reference

| Utility | Location | Purpose |
|---------|----------|---------|
| `ErrorHandler` | `lib/core/utils/error_handler.dart` | Convert any error to user-friendly string |
| `ExceptionHandler` | `lib/core/error/exception_handler.dart` | Map DioException to Failure types |
| `NetworkUtils` | `lib/core/utils/network_utils.dart` | Internet connectivity & server reachability checks |
| `UiUtils` | `lib/core/utils/ui_utils.dart` | Snackbars (success/error), loading dialogs, confirmation dialogs |
| `SecureStorageUtil` | `lib/core/utils/secure_storage_utils.dart` | Encrypted storage for user data & tokens |
| `AppPreferences` | `lib/core/services/app_preferences.dart` | SharedPreferences wrapper for app settings |
| `ImageHelper` | `lib/core/utils/image_helper.dart` | Image picking utilities |
| `BookValidators` | `lib/core/utils/book_validators.dart` | Book form field validation |
| `SelectionStore` | `lib/core/utils/selection_store.dart` | Selection state management |
| `AppBlocObserver` | `lib/core/utils/app_bloc_observer.dart` | Debug logging for BLoC transitions |
| `CustomElevatedButton` | `lib/core/widgets/my_buttons.dart` | Reusable button (green primary, dark text) |
| `MyTextField` | `lib/core/widgets/my_textfields.dart` | Reusable form input with validation |

---

## Project Conventions

- Font: Poppins (via `google_fonts` package).
- Color palette (from Figma design tokens):
  - Primary: `#2CE07F` (green)
  - Text Highlight: `#052E44` (dark blue)
  - Text Primary: `#141414`
  - Text Secondary: `#262626`
  - Background: `#FDFDFD`
  - Error: `#D64545`
  - Success (snackbar): `#38A169`
  - Default/Border 1: `#E0E0E0`
  - Default/Border 2: `#EAEAEA`
  - Default/Border 3: `#C9C9D1`
  - Accent/Selective: `#D0E1FD`
  - Accent/Background: `#FFE5DE`
  - Accent/Cards: `#BAC7CD`
  - Accent 2 (nav bar): `#2295F0`
- Theme text styles in `lib/core/theme/text_styles.dart`.
- Assets: SVGs via `flutter_svg` (`SvgPicture.asset()`), PNGs via `Image.asset()`.
- Asset paths: `assets/` for general, `assets/icons/` for icons, `assets/mock/` for mock JSON data.
- Mock data: JSON files in `assets/mock/` (e.g., `onboarding_question.json`).

---

## Model Serialization

- IMPORTANT: This project uses MANUAL `fromJson`/`toJson` — NOT `json_serializable` code generation.
- `build_runner` and `json_serializable` are in dev_dependencies but are NOT actively used for model generation.
- Models extend domain entities and use `super` parameters:
```dart
class AppUserModel extends AppUser {
  AppUserModel({
    required super.id,
    required super.name,
    // ...
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return AppUserModel(
      id: user['_id'] ?? '',
      name: user['name'] ?? '',
      // ...
    );
  }

  Map<String, dynamic> toJson() => { ... };
}
```
- API responses often nest data under a key (e.g., `json['user']`, `json['data']`) — always check the response structure.

---

## Testing

- The project currently has NO tests. When adding tests:
  - Place unit tests in `test/features/<feature>/` mirroring the lib structure.
  - Use `flutter_test` (already in dev_dependencies).
  - Test use cases and BLoCs as priority.

---

## File Naming

- Dart files: `snake_case.dart`
- BLoC files: `<feature>_bloc.dart`, `<feature>_event.dart`, `<feature>_state.dart`
- Cubit files: `<feature>_cubit.dart`, `<feature>_state.dart`
- Pages: `<name>_page.dart` or `<name>_screen.dart`
- Widgets: `<descriptive_name>_widget.dart` or `<descriptive_name>.dart`
- Models: `<entity_name>_model.dart`
- Use cases: `<action>_<entity>.dart` (e.g., `get_books.dart`, `sign_in.dart`)
- Data sources: `<feature>_remote_data_source.dart`

---

## Checklist for New Features

### Full Feature (with API)
1. Create `data/`, `domain/`, `presentation/` folders under `lib/features/<feature>/`.
2. Define entity in `domain/entities/`.
3. Define repository interface in `domain/repositories/`.
4. Create use case(s) in `domain/usecases/`.
5. Implement model in `data/models/` with manual `fromJson`/`toJson` (extending entity).
6. Implement remote data source in `data/datasources/`.
7. Implement repository in `data/repositories/`.
8. Create BLoC with events and states in `presentation/blocs/` (use Pattern A with part files).
9. Create pages in `presentation/pages/` and widgets in `presentation/widgets/`.
10. Register ALL layers in `lib/core/di/injection.dart` (data source → repo → use case → bloc).
11. Add API endpoints to `lib/core/network/api_constants.dart`.
12. Add route in `lib/routes/app_router.dart`.
13. Run `dart format .` and `flutter analyze`.

### Presentation-Only Feature
1. Create `presentation/` folder under `lib/features/<feature>/`.
2. Create pages and widgets.
3. Add route in `lib/routes/app_router.dart`.
4. Run `dart format .` and `flutter analyze`.
