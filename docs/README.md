# ReadBuddy App

## Technical Document

Version: 1.0

Author: Kunal Gharate

Date: July 6, 2026

Status: Final

---

## Overview

ReadBuddy is a community book-sharing and reading companion platform built with Flutter. It connects book owners, donors, and readers through a unified mobile application. The app supports physical book borrowing and donation, eBook reading (PDF/EPUB), audiobook playback with background support, and video book streaming. It includes role-based dashboards for Admins and Librarians to manage books, users, donations, and book requests.

The application follows Clean Architecture with BLoC state management, manual dependency injection via GetIt, and connects to a Node.js REST API backend hosted on Render.

---

## Purpose

The purpose of ReadBuddy is to make books accessible to everyone by building a community-driven ecosystem where users can share, donate, borrow, and read books across multiple formats. The platform encourages reading habits through rewards, Prime membership, and a seamless digital reading experience — all while enabling administrators to efficiently manage the entire lifecycle of books, donations, and requests.

---

## Scope

### Included

- User registration and authentication (email/password with OTP verification, Google sign-in, password reset)
- Onboarding flow with preference questionnaire
- Book browsing, search, and detailed viewing
- Book borrowing with pickup and delivery options
- Book donation (physical) and monetary donations via Razorpay
- eBook reading (PDF and EPUB formats)
- Audiobook playback with background audio support
- Video book viewing
- Prime membership system with tiered benefits
- Reading rewards, streaks, and challenges
- Admin dashboard for managing books, users, categories, banners, donations, and requests
- Librarian dashboard for fulfilling book requests and managing donations
- Push notifications for request and donation status updates
- Light and dark theme support

### Excluded

- Social login beyond Google Sign-In
- Biometric authentication
- In-app chat or messaging between users
- Offline reading of eBooks and audiobooks
- Multi-language localization support
- Web and desktop deployment (mobile-first)
- E-commerce or paid book sales
- AI-powered book recommendations
- ePub creation or editing tools

---

## Requirements

### Functional Requirements

- Users can register with email and password, verify OTP, and sign in.
- Users can sign in using Google.
- Users can reset their password via email.
- Users can browse, search, and view book details.
- Users can borrow physical books with pickup or delivery options.
- Users can donate physical books and contribute money via Razorpay.
- Users can read eBooks (PDF/EPUB) in-app with text-to-speech support.
- Users can listen to audiobooks with background playback.
- Users can earn Prime membership by donating books or paying.
- Users can view reading rewards, streaks, and challenges.
- Admins can manage books, categories, banners, users, donations, and book requests.
- Librarians can fulfill book requests and manage donations.
- Users receive push notifications for request and donation updates.

### Non-functional Requirements

- API response time under 2 seconds for standard requests.
- Secure storage of tokens and sensitive data using Flutter Secure Storage.
- Offline awareness — graceful handling of network loss with connectivity wrapper.
- Token refresh mechanism for seamless session management.
- Image caching and lazy loading for optimized performance.
- Background audio playback without app suspension.
- Scalable architecture via feature-based Clean Architecture modules.

---

## Architecture

```
Presentation Layer (Pages / Widgets)
          │
          ▼
State Management (Blocs / Cubits)
          │
          ▼
Domain Layer (Entities / Use Cases / Repository Interfaces)
          │
          ▼
Data Layer (Data Sources / Repository Implementations / Models)
          │
          ▼
Remote API (Dio / Node.js Backend) — Local Storage (SharedPreferences / SecureStorage)
```

### Design Pattern

Clean Architecture with three layers per feature: presentation (Bloc + UI), domain (entities, use cases, repository interfaces), and data (models, data sources, repository implementations).

### State Management

flutter_bloc (Blocs and Cubits) — each feature has its own Bloc or Cubit registered via GetIt. BlocObserver logs lifecycle events for debugging.

### Dependency Injection

Manual GetIt registration in a single file (lib/core/di/injection.dart) organized by layer: utils, data sources, repositories, use cases, Blocs, Cubits.

### Database

No local SQL database. Persistent storage relies on SharedPreferences (user preferences, theme mode) and FlutterSecureStorage (tokens, session data). File caching for images via cached_network_image and custom file cache service.

### API Layer

Dio HTTP client with custom interceptors for Bearer token injection, automatic token refresh on 401/403 responses, retry-once logic for TLS errors and timeouts, and request/response logging.

---

## Components

### Authentication Module

Handles sign-up, login, OTP verification, Google sign-in, and password reset.

Dependencies: AuthRemoteDataSource, SecureStorageUtils, UserCubit.

### Book Module

Manages book listing, search, filtering, and detail views.

Dependencies: BookRemoteDataSource, CategoryRemoteDataSource.

### Book Request Module

Handles borrowing requests with pickup/delivery workflows, admin approval, and return processing.

Dependencies: BookRequestRemoteDataSource, UserCubit, ConnectivityService.

### Donation Module

Manages physical book donations (pickup/drop-off), monetary donations via Razorpay, and Prime reward assignment.

Dependencies: DonateRemoteDataSource, RazorpayFlutter, UserCubit.

### eBook Module

Provides in-app PDF and EPUB reading with text-to-speech support.

Dependencies: Syncfusion PDF Viewer, flutter_epub_viewer, TtsService.

### Audiobook Module

Manages audiobook playback with background audio support and a persistent mini-player.

Dependencies: just_audio, audio_service, FileCacheService.

### Admin Dashboard

Provides CRUD management for books, categories, banners, users, donations, and book requests.

Dependencies: BookRemoteDataSource, CategoryRemoteDataSource, BannerRemoteDataSource, UserRemoteDataSource.

### Librarian Dashboard

Manages book request fulfillment and donation processing.

Dependencies: BookRequestRemoteDataSource, DonateRemoteDataSource.

---

## Workflow

### Book Borrowing Flow

```
User browses books
        │
        ▼
User selects a book and taps Request
        │
        ▼
System checks Prime membership
        │
        ▼
If not Prime → Show Prime upgrade prompt
        │
        ▼
User selects pickup or delivery
        │
        ▼
Request submitted → Status: Pending
        │
        ▼
Admin / Librarian approves request
        │
        ▼
User collects book or receives delivery
        │
        ▼
User reads and returns book
        │
        ▼
Request marked as Completed
```

### Book Donation Flow

```
User taps Donate
        │
        ▼
User selects Book Donation or Money Donation
        │
        ├── Book Donation
        │       │
        │       ▼
        │   Fill book details → Select pickup or drop-off
        │       │
        │       ▼
        │   Submit → Admin reviews → Pickup scheduled or drop-off confirmed
        │       │
        │       ▼
        │   Book received → Prime membership granted
        │
        └── Money Donation
                │
                ▼
            Enter amount → Razorpay checkout
                │
                ▼
            Payment success → Impact stats updated
```

### Authentication Flow

```
User opens app
        │
        ▼
Splash screen → Check stored token
        │
        ├── Token valid → Navigate to Home
        │
        └── Token missing / expired
                │
                ▼
            Login screen displayed
                │
                ▼
            Email/Password or Google Sign-In
                │
                ▼
            API call → Receive JWT + Refresh Token
                │
                ▼
            Store tokens securely → Navigate to Home
```

---

## Data Models

### User

- id — Unique user identifier assigned by the server.
- name — Display name of the user.
- email — Email address used for login and communication.
- token — JWT access token for authenticated API requests.
- refreshToken — Token used to obtain a new access token on expiry.
- role — User role: user, admin, or librarian.
- isPrime — Boolean indicating Prime membership status.
- avatar — URL to the user's profile picture.

### Book

- id — Unique book identifier.
- title — Title of the book.
- author — Author name.
- category — Book category reference.
- language — Language of the book.
- variants — List of format variants (hardcover, eBook, audiobook).
- description — Book summary or blurb.
- coverImage — URL of the book cover image.
- rating — Average user rating.
- availableCopies — Number of copies available for borrowing.

### BookVariant

- id — Unique variant identifier.
- type — Format type: hardcover, eBook, audiobook, video.
- price — Price of the variant (if applicable).
- fileUrl — URL to the digital file (for eBooks, audiobooks, videos).
- isbn — ISBN for physical copies.
- pageCount — Page count (for hardcover and eBook).
- duration — Duration in minutes (for audiobooks and videos).

### BookRequest

- id — Unique request identifier.
- userId — Reference to the requesting user.
- bookId — Reference to the requested book.
- type — Request type: pickup or delivery.
- status — Current status: pending, approved, picked_up, delivered, returned, cancelled.
- deliveryAddress — Address for delivery requests.
- requestDate — Date the request was created.
- returnDate — Date the book was returned.

### Donation

- id — Unique donation identifier.
- userId — Reference to the donating user.
- type — Donation type: book or money.
- status — Current status: pending, approved, picked_up, completed, cancelled.
- items — List of donated book details (for book donations).
- amount — Monetary donation amount.
- paymentId — Razorpay payment transaction ID (for money donations).
- donationDate — Date of the donation.

---

## API Details

| Endpoint | Method | Description |
| --- | --- | --- |
| /auth/register | POST | Register a new user |
| /auth/login | POST | User login |
| /auth/google | POST | Google sign-in |
| /auth/verify-otp | POST | Verify OTP during registration |
| /auth/forgot-password | POST | Request password reset |
| /auth/refresh | POST | Refresh JWT token |
| /books | GET | List books with pagination |
| /books/:id | GET | Get book details |
| /books/:id/variants | GET | Get book variants |
| /categories | GET | List categories |
| /requests | POST | Create a book request |
| /requests | GET | List user requests |
| /requests/:id | PATCH | Update request status |
| /donations/books | POST | Submit a book donation |
| /donations/money | POST | Submit a money donation |
| /donations/impact | GET | Get user donation impact stats |
| /users/profile | GET | Get user profile |
| /users/profile | PATCH | Update user profile |
| /admin/books | POST | Add a new book |
| /admin/books/:id | PUT | Update a book |
| /admin/books/:id | DELETE | Delete a book |
| /admin/users | GET | List all users |
| /admin/requests | GET | List all book requests |
| /admin/donations | GET | List all donations |

### Request Example — Login

```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

### Response Example — Login

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "dGhpcyBpcyBhIHJlZnJl...",
  "user": {
    "id": "usr_12345",
    "name": "John Doe",
    "email": "user@example.com",
    "role": "user",
    "isPrime": false
  }
}
```

---

## Error Handling

| Error | Cause | Solution |
| --- | --- | --- |
| 400 | Invalid input data | Validate fields before submission |
| 401 | Missing or invalid token | Redirect to login; refresh token |
| 403 | Insufficient permissions | Show access denied message |
| 404 | Resource not found | Show not found screen |
| 409 | Duplicate resource | Inform user of conflict |
| 422 | Validation failed | Display field-level errors |
| 429 | Rate limit exceeded | Retry after delay |
| 500 | Internal server error | Show generic error; retry |
| Network | No internet connection | Show offline dialog; retry on reconnect |
| Timeout | Server unresponsive | Retry once; show timeout error |

---

## Security

- All API communication over HTTPS.
- JWT access tokens with short expiry for authenticated requests.
- Refresh tokens stored in FlutterSecureStorage for session renewal.
- Automatic token refresh via Dio interceptor on 401/403 responses.
- Biometric-protected storage available on supported devices.
- Razorpay payment integration with server-side verification.
- Input validation on both client and server side.
- No plain-text secrets or keys in client source code.

---

## Performance Considerations

- Book images loaded with cached_network_image for disk and memory caching.
- Lazy loading of book lists with pagination (page-based API calls).
- Debounced search input to reduce API calls.
- File cache service for audiobooks and eBooks to reduce re-downloads.
- Background audio playback via audio_service to avoid interruption.
- Connectivity-aware wrapper to prevent failed API calls during network loss.
- Dio interceptor retry logic to handle transient server failures.
- Efficient state management with Bloc — widgets rebuild only on relevant state changes.

---

## Testing

### Unit Tests

- Repository implementations with mocked data sources.
- Use case logic and edge cases.
- Data model serialization and deserialization.
- Utility functions (validators, helpers, string extensions).

### Widget Tests

- Login screen — form validation, button states, error display.
- Book detail screen — rendering of book info, variant selection.
- Navigation — bottom nav tab switching, route transitions.

### Integration Tests

- Complete authentication flow: register, verify OTP, login, token refresh.
- Book borrowing flow: browse, request, approve, return.
- Donation flow: submit book donation, track impact.

---

## Limitations

- Offline login is not supported — internet connection required for authentication.
- Offline reading of eBooks and audiobooks is not available.
- Maximum image upload size is limited by the server configuration.
- Push notifications are delivered only when the app permits notification permissions.
- Google Sign-In requires Google Play Services (limitation on some Chinese devices).
- Prime membership benefits are tied to server-side logic — no offline verification.
- Video book streaming depends on network bandwidth and server availability.
- The app is currently single-language (English) with no i18n support.

---

## Future Improvements

- Offline mode with local database (SQLite/Hive) for reading and basic browsing.
- Biometric authentication for app unlock and secure actions.
- Multi-language support (i18n) for broader accessibility.
- In-app chat system for users, donors, and librarians.
- AI-powered book recommendations based on reading history and preferences.
- ePub creation and editing tools for authors and publishers.
- Advanced analytics dashboard for admins with visual reports.
- Book review and rating system with user comments.
- Web and desktop deployment using responsive Flutter layouts.
- Subscription-based Prime membership with auto-renewal.

---

## References

- Project Repository: https://github.com/kunalgharate/read-buddy-app
- Flutter Documentation: https://docs.flutter.dev
- flutter_bloc: https://bloclibrary.dev
- Dio HTTP Client: https://pub.dev/packages/dio
- Razorpay Payment Gateway: https://razorpay.com/docs
- Syncfusion Flutter PDF: https://help.syncfusion.com/flutter
- just_audio: https://pub.dev/packages/just_audio
- audio_service: https://pub.dev/packages/audio_service
