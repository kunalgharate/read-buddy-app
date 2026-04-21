---
inclusion: auto
---

# ReadBuddy — Flutter Project Standards

## Project Overview

ReadBuddy is a donation-based book sharing platform. Users donate physical books, eBooks, audiobooks, and video books to the system. These books get circulated to other users who join the app. Features include prime membership (access to multiple books), multi-format reading (physical, eBook, audiobook, video), multi-language support (English, Hindi, Marathi), and an admin dashboard for content management.

**Backend**: Node.js on Render.com — `https://readbuddy-server.onrender.com/api`
**Package**: `read_buddy_app` | **SDK**: `>=3.5.0 <4.0.0` | **Font**: Poppins (google_fonts)

---

## Architecture — Feature-Based Clean Architecture

### Full Features (with API)
```
lib/features/<feature_name>/
├── data/
│   ├── datasources/     # Remote data source (Dio HTTP calls)
│   ├── models/          # Data models — EXTEND domain entities, manual fromJson/toJson
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Pure Dart classes, no framework deps
│   ├── repositories/    # Abstract interfaces (contracts)
│   └── usecases/        # Single call() method per use case
└── presentation/
    ├── blocs/           # BLoC (event/state/bloc) or Cubit
    ├── pages/           # Full-screen widgets
    └── widgets/         # Reusable UI components
```

### Presentation-Only Features
Simple UI features: `home`, `donate`, `mybook`, `rewards`, `settings`, `splash`, `onboarding`, `search`, `notification`.

### Current Features (22 total)
| Feature | Type | Layers | Description |
|---------|------|--------|-------------|
| auth | Full | D/Do/P | Sign in, sign up, Google sign-in, forgot password (OTP), email verification |
| profile | Full | D/Do/P | User profile, avatar selection, field updates, cache-first fetch |
| books | Full | D/Do/P | Browse books list from API |
| bookcrud | Full | D/Do/P | Admin: Add/edit/delete books with images, location search |
| category_crud | Full | D/Do/P | Admin: CRUD categories with images |
| question_crud | Full | D/Do/P | Admin: CRUD onboarding questions |
| banner | Full | D/Do/P | Admin: CRUD promotional banners |
| donated_books | Full | D/Do/P | Admin: View all donated books |
| questionaries | Full | D/Do/P | Onboarding questionnaire with preference submission |
| ebook | Partial | Do/P | PDF + EPUB reader with dark mode, TTS, highlights, caching |
| audiobook | Partial | Do/P | Audio player with just_audio, speed control, playlist, state persistence |
| home | Presentation | P | Home screen with bottom nav (4 tabs), AppBar actions |
| donate | Presentation | P | Donation tab, book format selection, donate book form, donate money |
| search | Presentation | P | Search with topic chips and book format cards |
| notification | Presentation | P | Notification cards list |
| rewards | Presentation | P | Rewards, reading streak, badges, challenges |
| mybook | Presentation | P | My Books with Reading/Completed/Wishlist tabs |
| dashboard | Presentation | P | Admin dashboard |
| settings | Presentation | P | Settings screen |
| splash | Presentation | P | Splash screen with auth routing |
| onboarding | Presentation | P | Onboarding intro screens |
| user_preference | Presentation | P | User preference display |

---

## Dependencies Reference

### State Management
- `flutter_bloc: ^8.1.3` — BLoC/Cubit pattern
- `equatable: ^2.0.5` — Value equality for events/states

### Networking
- `dio: ^5.4.0` — HTTP client with interceptors
- `connectivity_plus: ^6.1.4` — Real-time network monitoring

### Auth & Security
- `google_sign_in: ^6.2.2` — Google OAuth
- `flutter_secure_storage: ^9.2.4` — Encrypted local storage for tokens/user
- `shared_preferences: ^2.5.4` — Simple key-value storage

### DI
- `get_it: ^7.6.0` — Service locator
- `injectable: ^2.3.0` — DI annotations (manual registration used)

### Readers
- `syncfusion_flutter_pdfviewer: ^27.2.5` — PDF viewer (zoom, search, text selection)
- `syncfusion_flutter_pdf: ^27.2.5` — PDF text extraction for TTS
- `flutter_epub_viewer: ^1.1.1` — EPUB viewer (chapters, highlights, themes)

### Audio
- `just_audio: ^0.9.43` — Audio playback with streaming, speed control, playlists
- `flutter_tts: ^4.2.0` — Text-to-speech (EN, HI, MR)

### UI
- `google_fonts: ^6.2.1` — Poppins font
- `flutter_svg: ^2.0.10` — SVG rendering
- `curved_navigation_bar: ^1.0.6` — Bottom navigation
- `cached_network_image: ^3.4.1` — Image caching
- `dropdown_search: ^6.0.2` — Searchable dropdowns

### Media & Storage
- `image_picker: ^1.1.2` — Camera/gallery image picking
- `permission_handler: ^12.0.0+1` — Runtime permissions
- `path_provider: ^2.1.5` — App directory paths
- `crypto: ^3.0.6` — MD5 hashing for file cache

---

## Dependency Injection

Manual registration in `lib/core/di/injection.dart`. Order:
1. `_registerUtils()` — Dio, SecureStorageUtil
2. `_registerDataSources()` — Remote data sources (inject Dio + SecureStorage)
3. `_registerRepositories()` — Repository implementations
4. `_registerUseCases()` — Use cases
5. `_registerBlocs()` — BLoCs
6. `_registerCubits()` — Cubits

Use `registerLazySingleton` for most. Use `registerFactory` for per-screen BLoCs (ProfileBloc, OnboardingBloc).

---

## BLoC Pattern

**Preferred pattern** (part files + sealed + Equatable):
```dart
// feature_bloc.dart
part 'feature_event.dart';
part 'feature_state.dart';
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final MyUseCase _useCase;
  FeatureBloc(this._useCase) : super(FeatureInitial()) {
    on<LoadFeature>(_onLoad);
  }
}
// feature_event.dart — part of, sealed class extends Equatable
// feature_state.dart — part of, sealed class extends Equatable
```

**Cubit** for simple state: `LocationCubit`, `UserCubit`.

**Error handling**: try/catch → `ErrorHandler.getErrorMessage(error)` → emit error state.

---

## Networking

- `DioClient.createDio()` — configures Dio with `AppInterceptor` (auto-attaches Bearer token, handles 401 token refresh)
- Base URL: `https://readbuddy-server.onrender.com/api`
- Endpoints in `lib/core/network/api_constants.dart`
- Timeouts: connect 120s, receive 180s, send 120s (Render free tier cold starts)
- `NetworkUtils.hasInternetConnection()` — DNS lookup check
- `ConnectivityService` — real-time monitoring with auto no-internet dialog

---

## Auth Flow

1. Sign up → email verification (OTP) → onboarding questionnaire → home
2. Sign in (email/password or Google) → check onboarding status → home or questionnaire
3. Forgot password → send OTP → verify OTP → reset password
4. Token refresh via `AppInterceptor` on 401 responses
5. Tokens stored in `FlutterSecureStorage`

---

## Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#2CE07F` | Buttons, active states, progress |
| Text Highlight | `#052E44` | Headings, primary text |
| Text Primary | `#141414` | Body text |
| Background | `#FDFDFD` | Page backgrounds |
| Error | `#D64545` | Error states, alerts |
| Success | `#38A169` | Success snackbars |
| Border | `#E0E0E0` | Card borders, dividers |
| Accent Blue | `#2295F0` | Nav bar, links |
| Accent Selective | `#D0E1FD` | Selected states |

---

## Code Quality

### Linter (`analysis_options.yaml`)
- Base: `package:flutter_lints/flutter.yaml`
- `prefer_const_constructors`, `prefer_const_declarations`, `avoid_unnecessary_containers`
- `avoid_print: ignore`

### DCM Metrics
- Cyclomatic complexity: max 20
- Maximum nesting: max 5
- Parameters: max 4
- Rules: `no-boolean-literal-compare`, `no-empty-block`, `prefer-trailing-comma`

### Formatting
- `dart format .` before every commit
- `flutter analyze` must pass with zero errors

---

## Core Utilities

| Utility | Path | Purpose |
|---------|------|---------|
| ErrorHandler | `core/utils/error_handler.dart` | DioException → user-friendly string |
| UiUtils | `core/utils/ui_utils.dart` | Snackbars, loading/confirmation dialogs |
| NetworkUtils | `core/utils/network_utils.dart` | Connectivity checks |
| ConnectivityService | `core/services/connectivity_service.dart` | Real-time network monitoring |
| FileCacheService | `core/services/file_cache_service.dart` | Download + cache remote files |
| SecureStorageUtil | `core/utils/secure_storage_utils.dart` | Encrypted user/token storage |
| AppPreferences | `core/services/app_preferences.dart` | SharedPreferences wrapper |
| AppInterceptor | `core/utils/app_interceptor.dart` | Auto Bearer token + 401 refresh |
| ConnectivityWrapper | `core/widgets/connectivity_wrapper.dart` | Global no-internet dialog |
| ConnectivityMixin | `core/mixins/connectivity_mixin.dart` | Per-page connectivity check |
| CustomElevatedButton | `core/widgets/my_buttons.dart` | Reusable green button |
| MyTextField | `core/widgets/my_textfields.dart` | Reusable form input |

---

## Model Serialization

- MANUAL `fromJson`/`toJson` — NOT json_serializable code generation
- Models EXTEND domain entities using `super` parameters
- API responses often nest data: `json['user']`, `json['data']`
- `AppUser` has `fromJson` factory that handles both flat and nested responses

---

## File Naming

- Files: `snake_case.dart`
- BLoC: `<feature>_bloc.dart`, `<feature>_event.dart`, `<feature>_state.dart`
- Pages: `<name>_page.dart` or `<name>_screen.dart`
- Models: `<entity_name>_model.dart`
- Use cases: `<action>_<entity>.dart`
- New subfolders: prefer plural (`entities/`, `usecases/`, `datasources/`)

---

## Navigation

- `AppRouter.generateRoute()` in `lib/routes/app_router.dart`
- Named routes via `Navigator.pushNamed(context, '/route')`
- Do NOT use `go_router` (in pubspec but unused)

---

## Testing

- No tests exist yet. When adding:
  - `test/features/<feature>/` mirroring lib structure
  - Priority: use cases → BLoCs → widgets
  - Use `flutter_test`, `bloc_test`, `mocktail`

---

## Checklist for New Features

### Full Feature (with API)
1. Domain: entity → repository interface → use cases
2. Data: model (extends entity, manual fromJson) → data source → repository impl
3. Presentation: BLoC (part files, sealed, Equatable) → pages → widgets
4. Register ALL layers in `lib/core/di/injection.dart`
5. Add endpoints to `api_constants.dart`
6. Add route to `app_router.dart`
7. `dart format .` and `flutter analyze`

### Presentation-Only Feature
1. Create `presentation/` with pages and widgets
2. Add route to `app_router.dart`
3. `dart format .` and `flutter analyze`
