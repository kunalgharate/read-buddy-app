---
inclusion: always
---

# ReadBuddy — Project Structure

## Clean Architecture Layers

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

Presentation-only features (no API): just `presentation/` folder.

## DI Registration

Manual registration in #[[file:lib/core/di/injection.dart]]. Order:
1. `_registerUtils()` → 2. `_registerDataSources()` → 3. `_registerRepositories()` → 4. `_registerUseCases()` → 5. `_registerBlocs()` → 6. `_registerCubits()`

Use `registerLazySingleton` for most. Use `registerFactory` for per-screen BLoCs.

## Navigation

Named routes via `AppRouter.generateRoute()`. Do NOT use go_router.
Routes: #[[file:lib/routes/app_router.dart]]

## File Naming

- Files: `snake_case.dart`
- BLoC: `<feature>_bloc.dart`, `<feature>_event.dart`, `<feature>_state.dart`
- Pages: `<name>_page.dart` or `<name>_screen.dart`
- Models: `<entity_name>_model.dart`
- New subfolders: prefer plural (`entities/`, `usecases/`, `datasources/`)

## Core Utilities

| Utility | Path |
|---------|------|
| ErrorHandler | `core/utils/error_handler.dart` |
| UiUtils | `core/utils/ui_utils.dart` |
| ConnectivityService | `core/services/connectivity_service.dart` |
| FileCacheService | `core/services/file_cache_service.dart` |
| SecureStorageUtil | `core/utils/secure_storage_utils.dart` |
| AppInterceptor | `core/utils/app_interceptor.dart` |
| ConnectivityMixin | `core/mixins/connectivity_mixin.dart` |

## Git Conventions

- Branches: `feature/<name>`, `fix/<name>`, `chore/<name>`
- Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- Do NOT commit `.kiro/settings/`, `.idea/`, `build/`
