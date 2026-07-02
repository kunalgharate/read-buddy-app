# ReadBuddy App - Production Readiness Review

**Date:** 2026-06-28
**Reviewer:** Expert Mobile Architecture Review
**Status:** NOT PRODUCTION READY -- Critical issues require resolution

---

## Executive Summary

This Flutter book-sharing app has **significant issues** across security, architecture, performance, and product completeness that must be resolved before production launch. The app is approximately **60-70% production-ready**.

| Category | Score | Verdict |
|----------|-------|---------|
| **Security** | 2/10 | CRITICAL - Password stored client-side, backend returns password |
| **API/Network** | 4/10 | Many broken error handling paths, no caching, no request cancellation |
| **Performance** | 3/10 | BLoC lifecycle mismanagement causes infinite rebuild loops |
| **Functionality** | 5/10 | ~50% of features are hardcoded placeholders |
| **Accessibility** | 0/10 | Zero Semantics, zero font scaling, broken dark mode on many screens |
| **Architecture** | 5/10 | Clean architecture partially adopted, but violated in multiple places |

---

## CRITICAL - Must Fix Before Launch

### 1. Password Stored in Plaintext on Device

The user's plaintext password is stored as a field in the `AppUser` entity and serialized into `FlutterSecureStorage` as part of the full user JSON blob. Even though FlutterSecureStorage encrypts at rest, the password should **never** be stored client-side. The backend should not return it, and the client should not persist it.

- `lib/features/auth/domain/entities/app_user.dart:5,27` -- `password` field in entity
- `lib/core/utils/secure_storage_utils.dart:24` -- Password serialized to secure storage
- `lib/features/auth/data/models/app_user_model.dart:43` -- Backend returns password in login response
- `lib/features/auth/domain/entities/app_user.dart:105-116` -- Password included in `toResendPayload()`

**Fix:** Remove `password` field from `AppUser` entity entirely. Ensure backend never returns password hash in API responses.

---

### 2. BLoC Event Dispatched Inside `build()` -- Infinite Rebuild Loop

`context.read<BookBloc>().add(LoadBooks())` is called inside the `build()` method of `BookPage`. This fires a `LoadBooks` event **every single time the widget rebuilds**, causing cascading rebuilds: build -> event -> state change -> rebuild -> event -> state change...

- `lib/features/books/presentation/pages/book_page.dart:33`

**Fix:** Move to `initState()` or trigger via `BlocListener`.

---

### 3. HomeBloc Recreated on Every Tab Switch

`HomeBloc` is registered as `registerFactory` (creates a new instance every time `getIt<HomeBloc>()` is called). `MainTab` is a `StatelessWidget` that creates a new `HomeBloc` in its `build()` method. Every time the user switches tabs back to Home, a brand new `HomeBloc` is created and fires `LoadHomeData()`.

- `lib/core/di/injection.dart:574` -- Registered as `registerFactory`
- `lib/features/home/presentation/widgets/main_tab.dart:26-33` -- Created in `build()`

**Fix:** Change to `registerLazySingleton` or provide at screen level with proper lifecycle.

---

### 4. UserCubit Fires API Call on Startup Before Login

`getIt<UserCubit>()..fetchUsers()` fires immediately when the app starts, before the user even reaches the home screen. This network call will fail for logged-out users or waste bandwidth.

- `lib/main.dart:87`

**Fix:** Remove `..fetchUsers()` from initialization. Fetch only when needed.

---

### 5. 13 BLoCs Created at App Root -- Most Unnecessary

All 13 BlocProviders are created in `MyApp.build()`, meaning every single BLoC is instantiated at app startup and persists for the entire app lifetime. Most of these (BannerBloc, CategoryBloc, BookCrudBloc, UserCubit, LocationCubit, OnboardingBloc, DonateBookBloc) are only needed on specific screens.

- `lib/main.dart:75-91`

**Fix:** Move BLoC providers closer to where they are actually consumed. Use `BlocProvider` locally on the screen that needs them, not at the root.

---

### 6. Android Release Uses Debug Signing Key

The release build is signed with the debug keystore, which means anyone could sign an update to the app if they obtain the debug key. This also means Play Store uploads would fail for production.

- `android/app/build.gradle:37-40`

```groovy
release {
    // TODO: Add your own signing config for the release build.
    signingConfig = signingConfigs.debug
```

**Fix:** Add proper release signing config with keystore.

---

### 7. Profile Internet Check Not Awaited (Async Void Bug)

`_checkInternet` is declared as `void _checkInternet(String path) async` (returns `void`, not `Future<void>`). This means calling `_checkInternet(ApiConstants.getProfile)` does NOT actually await the internet check. The API call proceeds regardless of internet connectivity.

- `lib/features/profile/data/datasource/profile_remote_data_source.dart:31,49`

**Fix:** Change return type to `Future<void>` and await the call.

---

## HIGH - Should Fix Before Launch

### Security

| Issue | File | Line(s) |
|-------|------|---------|
| Access tokens logged to console | `app_user_model.dart` | 32-33 |
| Access tokens logged in dio_client | `dio_client.dart` | 46 |
| No certificate pinning | `dio_client.dart` | entire file |
| Weak password policy (6 chars, no complexity) | `sing_up_page.dart` | 65-72 |
| Proguard/minification disabled | `build.gradle` | 42-44 |
| OTP stored in secure storage | `secure_storage_utils.dart` | 99-117 |
| Google OAuth Client IDs hardcoded | `google_sign_in_bloc.dart` | 28-30 |
| Hardcoded backend URL (no env switching) | `api_constants.dart` | 2-3 |

### API/Network

| Issue | File | Line(s) |
|-------|------|---------|
| 180-second receive timeout | `dio_client.dart` | 76 |
| No exponential backoff on retry | `dio_client.dart` | 87-117 |
| Duplicate auth token injection (interceptor + manual) | Multiple datasources | Multiple |
| Search query not URL-encoded in path | `book_crud_remote_resources.dart` | 233 |
| `deleteBook` swallows all errors silently | `book_crud_remote_resources.dart` | 202-226 |
| Banner datasource swallows all errors (4 methods) | `createbanner_remote_datasource.dart` | 62-71, 125-134, 160-168, 222-230 |
| `initiateMoneyDonation` has no try-catch | `donate_remote_datasource.dart` | 127-158 |
| Server hostname mismatch in network utils | `network_utils.dart` vs `api_constants.dart` | 85 vs 3 |
| `getRequestDetails` crashes on missing `data` key | `book_request_remote_datasource.dart` | 212 |
| Notification datasource bypasses ApiConstants | `notification_remote_datasource.dart` | 26, 38 |
| Commented-out JWT token in source (git history) | `user_remote_resources.dart` | 17 |

### Performance

| Issue | File | Line(s) |
|-------|------|---------|
| No pagination anywhere -- all lists fetch full dataset | Multiple | -- |
| No CancelToken usage (no request cancellation) | All datasources | All |
| No response caching layer | All datasources | All |
| Duplicate internet checking (ConnectivityService + NetworkUtils) | `connectivity_service.dart` + `network_utils.dart` | -- |
| Missing `const` constructors throughout | Multiple widgets | -- |
| BookEntity lacks Equatable | `book_entity.dart` | -- |
| FileCacheService creates own Dio (bypasses interceptors) | `file_cache_service.dart` | 13 |
| TTS service creates own Dio instance | `tts_service.dart` | 27 |
| `session_expired_dialog.dart` creates new SecureStorageUtil | `session_expired_dialog.dart` | 26 |

---

## MEDIUM - Should Fix

### Incomplete Features

| Feature | Status | File |
|---------|--------|------|
| Search | Non-functional placeholder (no TextField, no BLoC) | `search_screen.dart` |
| My Books | Hardcoded dummy data, no API integration | `mybook.dart:100-141` |
| Notifications | Hardcoded dummy data, no BLoC | `notification_page.dart:10-30` |
| Rewards | Hardcoded dummy data, no backend integration | `rewards_page.dart` |
| eBooks list | Hardcoded dummy data from catbox.moe URLs | `ebook_list_page.dart:31` |
| Audiobooks list | Hardcoded dummy data | `audiobook_list_page.dart:37` |
| "Add to Wallet" | Button does nothing (`onPressed: () {}`) | `format_screen.dart:411` |
| Change Password | Route does not exist in router | `settings_screen.dart:81` |
| Receipt upload | Collected but never dispatched to upload | `book_donation_page.dart:222-241` |
| Book image upload | Path sent as string, not multipart upload | `book_donation_page.dart:223` |
| Profile editing | No route exists in app_router | -- |
| Account deletion | Not implemented (GDPR concern) | -- |
| EPUB bookmarks | Not implemented | `epub_reader_page.dart` |
| PDF bookmark persistence | Lost on page exit (stored in widget state) | `pdf_reader_page.dart:43` |
| Filter/sort in Categories | Empty onPressed handler | `category_tab.dart:172` |
| Digital/Audio/Video book donation | "Coming Soon" snackbar | `format_screen.dart:96,112,122` |

### Accessibility

| Issue | Details |
|-------|---------|
| Zero `Semantics` widgets | Entire codebase has no accessibility annotations |
| Zero font scaling support | No `MediaQuery.textScaler` usage anywhere |
| Hardcoded colors break dark mode | `ebook_detail_page.dart`, `ebook_list_page.dart`, `audiobook_list_page.dart`, `pdf_reader_page.dart`, `epub_reader_page.dart` |
| Bottom nav has no labels/tooltips | `bottom_navigation_widget.dart` -- icons only, no text |
| Mini audio player has no accessibility labels | `mini_audio_player.dart` -- no Semantics on play/pause |

### Code Quality

| Issue | File | Details |
|-------|------|---------|
| 100+ `print()` statements in production code | Multiple files | Leak sensitive data (tokens, API responses) |
| 13 `// ignore:` comments suppressing warnings | `main.dart:61`, `add_banner.dart:206,214,228,233`, `admin_donation_detail_page.dart:166`, `update_book_page.dart:287,289`, `add_edit_question_page.dart:240,243,281,284` | Suppress real issues |
| 2 competing BottomNav implementations | `bottom_nav_layout.dart` (broken) vs `bottom_navigation_widget.dart` (active) | Dead code |
| 2 competing GoogleSignInBloc implementations | `auth/presentation/blocs/google_sign_in/` and `auth/presentation/blocs/sign_in/google_sign_in/` | Duplicate directory |
| Dead Home page stub | `home/presentation/pages/home_page.dart` | Unused |
| `BottomNavLayout` references HomeBloc not in widget tree | `layout/bottom_nav_layout.dart:36` | Will crash at runtime |
| Donate book event imports FormData from dio | `donate_book_event.dart:4` | Violates clean architecture |
| Duplicate route `/onboarding-questionnaire` | `app_router.dart:97,122-125` | Dead code |
| Route argument type cast crash risk | `app_router.dart:103,129,132,141,154,159,164` | Unsafe `as` casts |
| BannerCarousel auto-scroll recursive Future.delayed | `main_tab.dart:270-281` | Memory leak risk |
| `_MonthlyStatsCard` FutureBuilder recreates Future on rebuild | `main_tab.dart:609-691` | Duplicate API calls |
| ExploreBloc directly depends on DataSource | `explore_bloc.dart:8-10` | Violates clean architecture |
| ThemeNotifier fetches SharedPreferences on every toggle | `theme_notifier.dart:15-19` | Should cache instance |
| AppPreferences fetches SharedPreferences on every call | `app_preferences.dart` | Should cache instance |
| DonateMoneyPage `_onPaymentError` missing mounted check | `donate_money_page.dart:134-139` | Crash risk |
| DonateMoneyPage `_onExternalWallet` missing mounted check | `donate_money_page.dart:142-147` | Crash risk |
| Duplicate DI configurations conflict | `injection.dart` + `injection.config.dart` | `reset()` wipes generated config |
| macOS bundle ID mismatch (`com.example.readBuddyApp`) | `firebase_options.dart:76` | Leftover template value |

---

## Architecture Recommendations

### 1. BLoC Lifecycle Management
- Move all BLoC providers to screen-level or use `BlocProvider.value()`.
- Never create BLoCs inside `build()` methods.
- Change `registerFactory` to `registerLazySingleton` for BLoCs that should persist.

### 2. DI Cleanup
- Remove `injection.config.dart` (generated but conflicts with manual config).
- Keep manual `injection.dart` only.
- Eliminate `getIt` usage inside datasources -- use constructor injection instead.

### 3. Error Handling
- Adopt a single pattern: all datasources should use `ExceptionHandler` (already exists in core).
- Never swallow errors silently (return empty lists on failure).
- Never rethrow without context -- wrap in meaningful domain exceptions.

### 4. Network Layer
- Add `CancelToken` support for request cancellation on navigation.
- Add response caching (DioCacheManager or similar).
- Reduce timeouts to 30s max with exponential backoff on retry.
- Remove duplicate auth token injection (keep interceptor only).
- Add certificate pinning.

### 5. Remove Dead Code
- Delete `BottomNavLayout`, `home_page.dart`, duplicate `GoogleSignInBloc`.
- Delete dummy data files once real APIs are integrated.
- Remove commented-out routes and JWT tokens from source.

### 6. Testing
- Currently **zero tests** in the project.
- Add minimum: unit tests for BLoCs, widget tests for critical screens, integration tests for auth flow.
- Enable CI test execution in GitHub Actions.

### 7. Environment Configuration
- Move hardcoded backend URL to `--dart-define` or `.env` files.
- Support dev/staging/production environment switching.
- Remove hardcoded OAuth client IDs -- use environment variables.

---

## Launch Checklist

### Must Complete

- [ ] Remove password from `AppUser` entity and ensure backend never returns it
- [ ] Fix BLoC lifecycle (book_page build(), HomeBloc factory, root providers)
- [ ] Add proper Android release signing config
- [ ] Enable Proguard/minification for release builds
- [ ] Reduce network timeouts to 30s max
- [ ] Implement Search with real API integration
- [ ] Implement My Books with real API integration
- [ ] Implement Notifications with real API integration
- [ ] Add `/change-password` route
- [ ] Add `/profile` or `/edit-profile` route
- [ ] Remove all 100+ print() statements from production code
- [ ] Remove all dead code files
- [ ] Fix async void bug in profile internet check
- [ ] Add account deletion option (GDPR compliance)

### Should Complete

- [ ] Add certificate pinning for network security
- [ ] Add response caching layer
- [ ] Add CancelToken support for request cancellation
- [ ] Add pagination for all list views
- [ ] Add Semantics widgets for accessibility
- [ ] Add font scaling support
- [ ] Fix hardcoded colors breaking dark mode
- [ ] Add minimum test coverage (unit, widget, integration)
- [ ] Move environment configuration to dart-define or .env
- [ ] Add exponential backoff to retry interceptor
- [ ] Implement receipt/image upload for donations
- [ ] Persist PDF/EPUB bookmarks
- [ ] Implement EPUB highlights persistence
- [ ] Add lock screen notification controls for audio player

---

## Detailed Security Findings

| Severity | Count | Key Issues |
|----------|-------|------------|
| CRITICAL | 3 | Password stored client-side, backend returns password, password in re-registration payload |
| HIGH | 7 | Tokens logged, no cert pinning, hardcoded OAuth IDs, weak password policy, debug signing, no minification, OTP stored |
| MEDIUM | 6 | Firebase keys in source, hardcoded backend URL, excessive PII in storage, plaintext auth state, no rate limiting, minimal validation |
| LOW | 5 | Verbose logging, error messages, bundle ID mismatch, email enumeration, no input sanitization |

### CRITICAL Security Details

1. **Password in Secure Storage:** `secure_storage_utils.dart:24` stores `appUser.password` in the JSON blob. `app_user.dart:108` includes password in `toResendPayload()`.

2. **Backend Returns Password:** `app_user_model.dart:43` deserializes `user['password']` from login response. The backend should never return password data.

3. **Password Sent in Re-registration:** `app_user.dart:108` includes stored password in `toResendPayload()`.

---

*Review completed on 2026-06-28. This document should be used as a prioritized backlog for pre-production fixes.*
