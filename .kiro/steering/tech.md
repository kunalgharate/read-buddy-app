---
inclusion: always
---

# ReadBuddy — Technology Stack

**Package**: `read_buddy_app` | **SDK**: `>=3.5.0 <4.0.0` | **Font**: Poppins (google_fonts)

## Core Dependencies

| Category | Package | Purpose |
|----------|---------|---------|
| State | `flutter_bloc` | BLoC/Cubit pattern |
| State | `equatable` | Value equality for events/states |
| Network | `dio` | HTTP client with interceptors |
| Network | `connectivity_plus` | Real-time network monitoring |
| DI | `get_it` | Service locator |
| DI | `injectable` | DI annotations (manual registration) |
| Auth | `google_sign_in` | Google OAuth |
| Auth | `flutter_secure_storage` | Encrypted token/user storage |
| Storage | `shared_preferences` | Key-value storage |
| Storage | `path_provider` | App directory paths |
| Storage | `crypto` | MD5 hashing for file cache |
| PDF | `syncfusion_flutter_pdfviewer` | PDF viewer |
| PDF | `syncfusion_flutter_pdf` | PDF text extraction for TTS |
| EPUB | `flutter_epub_viewer` | EPUB viewer |
| Audio | `just_audio` | Audio playback, speed control |
| TTS | `flutter_tts` | Text-to-speech (EN, HI, MR) |
| UI | `google_fonts`, `flutter_svg`, `curved_navigation_bar`, `cached_network_image` | UI components |
| Media | `image_picker`, `permission_handler` | Camera/gallery |

## Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#2CE07F` | Buttons, active states |
| Text Highlight | `#052E44` | Headings |
| Background | `#FDFDFD` | Page backgrounds |
| Error | `#D64545` | Error states |
| Border | `#E0E0E0` | Dividers |

## Code Quality
- Linter: `flutter_lints` + `prefer_const_constructors`, `avoid_unnecessary_containers`
- DCM: complexity ≤ 20, nesting ≤ 5, params ≤ 4
- `dart format .` and `flutter analyze` before every commit
- Config: #[[file:analysis_options.yaml]]
