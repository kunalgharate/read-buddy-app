---
inclusion: always
---

# ReadBuddy Mobile — Technology Stack

| Layer | Technology | Version |
|---|---|---|
| Framework | Flutter | 3.x |
| Language | Dart | >=3.5 |
| State Management | flutter_bloc (BLoC + Cubit) | 8.1 |
| DI | get_it + injectable | 7.6 / 2.3 |
| Networking | Dio | 5.4 |
| Auth Storage | flutter_secure_storage | 9.2 |
| Local Storage | shared_preferences | 2.3 |
| PDF Viewer | syncfusion_flutter_pdfviewer | 27.2 |
| EPUB Reader | flutter_epub_viewer | 1.1 |
| Audio Player | just_audio | 0.9 |
| TTS | flutter_tts (+ future Gnani.ai) | 4.2 |
| File Picker | file_picker | 8.0 |
| Image Picker | image_picker | 1.1 |
| Firebase | firebase_core | 3.12 |
| Google Auth | google_sign_in | 6.2 |
| Navigation | Named routes via onGenerateRoute | — |
| Fonts | google_fonts (Poppins) | 6.2 |
| Connectivity | connectivity_plus | 6.1 |

## Architecture: Clean Architecture + BLoC

```
lib/
├── core/           # Shared: DI, network, utils, widgets, theme, services
├── features/       # Feature modules — each with data/domain/presentation layers
├── routes/         # Centralized route definitions (AppRouter)
└── layout/         # Bottom navigation layout
```

Each feature follows:
```
feature/
├── data/
│   ├── datasources/   # Remote API calls (Dio)
│   ├── models/        # JSON serialization models
│   └── repositories/  # Repository implementations
├── domain/
│   ├── entities/      # Pure domain objects
│   ├── repositories/  # Abstract repository interfaces
│   └── usecases/      # Business logic use cases
└── presentation/
    ├── bloc/          # BLoC/Cubit + Events + States
    ├── pages/         # Screen widgets
    └── widgets/       # Reusable UI components
```

## Key Technical Decisions
- BLoC pattern for state management — events in, states out
- Dio with AppInterceptor for auto-token attachment and refresh
- SecureStorage for JWT tokens, SharedPreferences for app settings
- get_it + injectable for dependency injection
- Named route navigation via `Navigator.pushNamed`
- ConnectivityWrapper shows offline dialog
- Error handling via custom Failure/Exception classes
- No code generation for models (manual fromJson/toJson)
