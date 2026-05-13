# Donation Feature — Technical Solution Document

**Epic**: Donation System  
**PR**: [#38 — feat(donation): book donation module](https://github.com/kunalgharate/read-buddy-app/pull/38)  
**Branch**: `feature/donation-tab`  
**Figma**: [ReadBuddy Donation Screens](https://www.figma.com/design/CKKpWQA3jZ0j1QlJMIz0ux/ReadBuddy?node-id=4001-7374)

---

## 1. Overview

Complete donation system enabling users to donate books (physical/digital) with pickup or drop-off fulfillment, view donation impact stats, track donation status, and donate money via Razorpay.

---

## 2. Architecture

Follows the project's **Clean Architecture** pattern:

```
lib/features/donate/
├── data/
│   ├── datasources/
│   │   └── donate_remote_datasource.dart
│   ├── models/
│   │   ├── agent_model.dart
│   │   ├── book_donation_request_model.dart
│   │   └── donation_stats_model.dart
│   └── repositories/
│       └── donate_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── agent.dart
│   │   ├── book_donation_request.dart
│   │   ├── book_donation_response.dart
│   │   ├── donation_stats.dart
│   │   ├── user_book_status.dart
│   │   └── user_location.dart
│   ├── repositories/
│   │   └── donate_repository.dart
│   └── usecases/
│       ├── create_book_donation.dart
│       ├── get_donation_stats.dart
│       ├── get_nearest_agents.dart
│       ├── get_user_book_status.dart
│       └── upload_receipt.dart
└── presentation/
    ├── bloc/
    │   ├── donate_book_bloc.dart
    │   ├── donate_book_event.dart
    │   └── donate_book_state.dart
    ├── pages/
    │   ├── book_donation_page.dart (2-step form)
    │   ├── donate_book_form_page.dart
    │   └── donate_money_page.dart
    └── widgets/
        └── nearest_agents_widget.dart
```

---

## 3. API Endpoints

**Base URL**: `https://readbuddy-server-b54k.onrender.com/api`

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| `GET` | `/v1/donations/my-impact` | Fetch user's donation stats (books donated, students helped, book status list) | Bearer |
| `POST` | `/v1/donations/createBookDonation` | Submit a new book donation (multipart/form-data) | Bearer |
| `POST` | `/v1/donations/:id/uploadReceipt` | Upload receipt image for a donation | Bearer |
| `GET` | `/v1/libraries/details` | Get nearest pickup agents/libraries | Bearer |
| `GET` | `/donations` | Get all donations (existing endpoint) | Bearer |

### 3.1 API Constants (added)

```dart
static const String myImpact = '$baseUrl/v1/donations/my-impact';
static const String createBookDonation = '$baseUrl/v1/donations/createBookDonation';
static String uploadDonationReceipt(String donationId) => '$baseUrl/v1/donations/$donationId/uploadReceipt';
static const String nearestAgent = '$baseUrl/v1/libraries/details';
```

---

## 4. Data Models

### 4.1 BookDonationRequest (Entity → Model)

**Entity** (`book_donation_request.dart`):
```dart
class BookDonationRequest extends Equatable {
  final String fulfillmentType;    // 'PICKUP' or 'DROP_OFF'
  final BookDetails bookDetails;
  final PickupDetails? pickupDetails;
  final DropoffDetails? dropoffDetails;
  final String? bookImagePath;
  final String? receiptImagePath;
}

class BookDetails extends Equatable {
  final String bookName;           // server field: 'bookName' (not 'title')
  final String? category;
  final String? condition;
  final String? description;
  final String? language;
  final String? format;
}

class PickupDetails extends Equatable {
  final String? name;
  final String address;
  final String pincode;
  final String mobile;             // server field: 'mobile' (not 'phoneNumber')
  final double? latitude;
  final double? longitude;
}

class DropoffDetails extends Equatable {
  final String libraryId;
}
```

**Model** (`book_donation_request_model.dart`) — converts to `FormData`:
```dart
// Payload structure sent to server:
{
  "fulfillmentType": "PICKUP" | "DROP_OFF",
  "bookDetails": {
    "bookName": "...",
    "category": "...",
    "condition": "...",
    "description": "...",
    "language": "...",
    "format": "..."
  },
  "pickup": {                      // key: 'pickup' (not 'pickupDetails')
    "name": "...",
    "address": "...",
    "pincode": "...",
    "mobile": "...",
    "latitude": ...,
    "longitude": ...
  },
  // OR
  "dropoff": {                     // key: 'dropoff' (not 'dropoffDetails')
    "libraryId": "..."
  },
  "bookImage": <MultipartFile>,    // optional
  "receiptImage": <MultipartFile>  // optional, dropoff only
}
```

### 4.2 DonationStats (Response)

```dart
class DonationStats extends Equatable {
  final int booksDonated;
  final int studentsHelped;
  final List<BookStatusItem> bookStatusList;
}

class BookStatusItem extends Equatable {
  final String id;
  final String title;
  final String format;
  final String status;
  final String? condition;
  final String? fulfillmentType;
  final String? createdAt;
  final String? categoryName;
  final String? coverImageUrl;
}
```

**API Response** (`GET /v1/donations/my-impact`):
```json
{
  "impact": {
    "booksDonated": "4",
    "studentsHelped": "20"
  },
  "bookStatusList": [
    {
      "_id": "abc123",
      "title": "The Jungle Book",
      "format": "Physical",
      "status": "donation_created",
      "condition": "Good",
      "fulfillmentType": "PICKUP",
      "createdAt": "2024-01-15T10:30:00Z",
      "category": { "name": "Fiction" },
      "coverImageUrl": "https://..."
    }
  ]
}
```

### 4.3 Agent (Nearest Libraries)

```dart
class Agent extends Equatable {
  final String id;
  final String name;
  final String contactNumber;
  final String openHours;
  final AgentAddress location;
  final double rating;
  final int totalDeliveries;
  final bool isAvailable;
  final double distanceKm;
  final int? estimatedPickupTimeMin;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class AgentAddress extends Equatable {
  final String country;
  final String street;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final String address;
}
```

### 4.4 BookDonationResponse (Status Tracking)

```dart
class BookDonationResponse extends Equatable {
  final String id;
  final String donorId;
  final String title;
  final String format;
  final String fulfillmentType;
  final PickupDetailsResponse? pickupDetails;
  final DropoffDetailsResponse? dropoffDetails;
  final String status;
  final List<StatusTimelineItem> statusTimeline;
  final DateTime createdAt;
}

class StatusTimelineItem extends Equatable {
  final String status;
  final DateTime timestamp;
  final String? message;
}
```

---

## 5. Donation Status Flow

### Pickup Flow:
```
donation_created → pickup_requested → pickup_scheduled → picked_up → delivered → completed
```

### Drop-off Flow:
```
donation_created → book_shipped → in_transit → delivered → completed
```

### Status Display Mapping:
| API Status | Display Label | Color |
|------------|--------------|-------|
| `donation_created`, `pickup_requested`, `pending` | Pending | `#FFC107` (amber) |
| `accepted`, `processing`, `out_for_pickup` | In Progress | `#2196F3` (blue) |
| `completed`, `delivered`, `success` | Completed | `#4CAF50` (green) |
| `cancelled`, `rejected` | Cancelled | `#F44336` (red) |

---

## 6. BLoC Design

### DonateBookBloc

| Event | State Emitted | Description |
|-------|---------------|-------------|
| `LoadDonationStats` | `DonationStatsLoaded` / `DonateBookError` | Fetches impact stats + book list |
| `LoadNearestAgents` | `NearestAgentsLoaded` / `DonateBookError` | Fetches nearby libraries |
| `SubmitBookDonationEvent` | `BookDonationCreated` / `DonateBookError` | Creates donation via API |
| `UploadDonationReceiptEvent` | `ReceiptUploaded` / `DonateBookError` | Uploads receipt image |

---

## 7. DI Registration

```dart
// Data Source
getIt.registerLazySingleton<DonateRemoteDataSource>(
  () => DonateRemoteDataSourceImpl(dio: getIt<Dio>()),
);

// Repository
getIt.registerLazySingleton<DonateRepository>(
  () => DonateRepositoryImpl(remoteDataSource: getIt<DonateRemoteDataSource>()),
);

// Use Cases
getIt.registerLazySingleton(() => GetDonationStats(repository: getIt<DonateRepository>()));
getIt.registerLazySingleton(() => GetNearestAgents(repository: getIt<DonateRepository>()));
getIt.registerLazySingleton(() => CreateBookDonation(repository: getIt<DonateRepository>()));
getIt.registerLazySingleton(() => UploadReceipt(repository: getIt<DonateRepository>()));

// BLoC
getIt.registerFactory(() => DonateBookBloc(
  getDonationStats: getIt<GetDonationStats>(),
  getNearestAgents: getIt<GetNearestAgents>(),
  createBookDonation: getIt<CreateBookDonation>(),
  uploadReceipt: getIt<UploadReceipt>(),
));
```

---

## 8. Routes

| Route | Page | Description |
|-------|------|-------------|
| `/donation` | `DonationPage` | Donation dashboard (placeholder) |
| `/donate-book-form` | `DonateBookFormPage` | Simple book form |
| `/donate-money` | `DonateMoneyPage` | Money donation page |
| `/book-donation` | `BookDonationPage` | 2-step donation flow (new) |
| `/donated-books` | `DonatedBooksPage` | List of all donated books |
| `/donated-book-detail` | `DonatedBookDetailPage` | Single donation detail (new) |

---

## 9. UI Screens

### 9.1 DonationTab (Home Tab)
- Impact stats cards (Books Donated, Students Helped) — from API
- Recent Donations list (max 5 items) with status badges
- "Donate a Book" button → opens `BookFormatBottomSheet`
- "Donate Money" button → opens `RazorpayBottomSheet`
- Pull-to-refresh support

### 9.2 BookDonationPage (2-Step Form)
- **Step 1**: Book details (name, category, condition, format, language, cover image)
- **Step 2**: Fulfillment selection
  - **Pickup**: name, address, pincode, mobile, nearest agent selection
  - **Drop-off**: library selection, receipt upload

### 9.3 DonatedBookDetailPage
- Cover image header
- Title + status badge
- Info grid (format, language, condition)
- Donation info (donor, date, ID)

---

## 10. Interceptor Enhancement

Token refresh logic updated to handle both:
- `401 Unauthorized` — standard token expiry
- `403 Forbidden` with `token` in error/message — token-expired variant

---

## 11. PR #38 Review Summary

### What's Relevant (Donation Feature — KEEP):
| Category | Files |
|----------|-------|
| Core | `api_constants.dart`, `app_interceptor.dart`, `injection.dart` (donation registrations only) |
| Donate Feature | All files under `lib/features/donate/` (data, domain, presentation) |
| Donated Books | Updated files under `lib/features/donated_books/` |
| DonationTab | `lib/features/home/presentation/widgets/DonationTab.dart` |
| Routes | `lib/routes/app_router.dart` (donation routes) |
| Format Screen | `lib/features/home/presentation/widgets/Format_screen.dart` (BookFormatBottomSheet) |

### What's UNRELATED (Should Be Removed from PR):

| Category | Files | Reason |
|----------|-------|--------|
| **Mock Data** | `assets/mock_data/book_categories.json` | Not used by real API |
| **Mock Data** | `assets/mock_data/donation_stats.json` | Not used by real API |
| **Mock Data** | `assets/mock_data/nearest_agents.json` | Not used by real API |
| **Mock Data** | `assets/mock_data/user_book_status.json` | Not used by real API |
| **New Feature** | `lib/features/categories/` (entire folder) | Separate feature, uses local mock data |
| **New Feature** | `lib/features/monthly_stats/` (entire folder) | Separate feature, not donation-related |
| **Styling** | `lib/features/audiobook/` changes | Import path reformatting only |
| **Styling** | `lib/features/auth/` changes | Import path reformatting only |
| **Styling** | `lib/features/books/` changes | Import path reformatting only |
| **Styling** | `lib/features/bookcrud/` changes | Import path reformatting only |
| **Styling** | `lib/features/ebook/` changes | Import path reformatting only |
| **Styling** | `lib/features/homebooks/` changes | Import path reformatting only |
| **Styling** | `lib/features/profile/` changes | Import path reformatting only |
| **Styling** | `lib/features/question_crud/` changes | Import path reformatting only |
| **Styling** | `lib/features/questionaries/` changes | Import path reformatting only |
| **Styling** | `lib/features/rewards/` changes | Import path reformatting only |
| **Styling** | `lib/features/user_preference/` changes | Import path reformatting only |
| **Misc** | `analyze_errors.txt` | Debug artifact |
| **Misc** | `.kiro/hooks/format-on-save.kiro.hook` | IDE config |
| **Misc** | `lib/features/category_crud/` changes | Unrelated refactoring |
| **Misc** | `lib/features/onboarding/` changes | Unrelated |
| **Misc** | `lib/features/splash/` changes | Unrelated |

### Issues Found:

| # | Issue | Severity | Location |
|---|-------|----------|----------|
| 1 | **Mock data files included** — `assets/mock_data/` should not be in PR | Medium | `assets/mock_data/` |
| 2 | **Categories feature uses local JSON** — reads from `assets/mock_data/book_categories.json` instead of real API | High | `lib/features/categories/` |
| 3 | **`getUserBookStatus()` throws UnimplementedError** — dead code in repository | Low | `donate_repository_impl.dart` |
| 4 | **`getUserLocation()` throws UnimplementedError** — dead code in repository | Low | `donate_repository_impl.dart` |
| 5 | **169 files changed** — only ~30 are donation-related; rest are import reformatting or unrelated features | High | Entire PR |
| 6 | **DonateBookBloc registered as `registerFactory`** — correct for per-screen usage, just verify intent | Low | `injection.dart` |
| 7 | **No error type differentiation** — all errors wrapped as generic `Exception('...')` instead of typed failures | Low | `donate_repository_impl.dart` |
| 8 | **Debug prints in production code** — `kDebugMode` guards are good, but consider removing before merge | Low | `donate_book_bloc.dart`, `donate_remote_datasource.dart` |

---

## 12. Recommended PR Cleanup

To reduce the PR from 169 → ~30 files (donation-only):

```bash
# Files to REMOVE from the PR (revert to main):
git checkout main -- assets/mock_data/
git checkout main -- analyze_errors.txt
git checkout main -- .kiro/hooks/
git checkout main -- lib/features/categories/
git checkout main -- lib/features/monthly_stats/
git checkout main -- lib/features/audiobook/
git checkout main -- lib/features/auth/
git checkout main -- lib/features/books/
git checkout main -- lib/features/bookcrud/
git checkout main -- lib/features/ebook/
git checkout main -- lib/features/homebooks/
git checkout main -- lib/features/profile/
git checkout main -- lib/features/question_crud/
git checkout main -- lib/features/questionaries/
git checkout main -- lib/features/rewards/
git checkout main -- lib/features/user_preference/
git checkout main -- lib/features/onboarding/
git checkout main -- lib/features/splash/
git checkout main -- lib/features/category_crud/
git checkout main -- lib/features/dashboard/
git checkout main -- lib/core/mixins/
git checkout main -- lib/core/widgets/
git checkout main -- lib/core/utils/error_handler.dart
git checkout main -- lib/core/utils/secure_storage_utils.dart
git checkout main -- lib/core/network/dio_client.dart
git checkout main -- lib/main.dart
git checkout main -- lib/layout/
git checkout main -- pubspec.yaml  # only if no new donation deps were added
```

### Files to KEEP:
- `lib/features/donate/` (entire folder)
- `lib/features/donated_books/` (updated files)
- `lib/features/home/presentation/widgets/DonationTab.dart`
- `lib/features/home/presentation/widgets/Format_screen.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/core/network/api_constants.dart` (new endpoints)
- `lib/core/utils/app_interceptor.dart` (token refresh fix)
- `lib/core/di/injection.dart` (donation DI only)
- `lib/routes/app_router.dart` (donation routes)

---

## 13. Next Steps

1. **Remove mock data** — delete `assets/mock_data/` and the `categories` feature that depends on it
2. **Split PR** — create separate PRs for `monthly_stats`, `categories`, and import reformatting
3. **Test API integration** — verify `my-impact`, `createBookDonation`, and `nearestAgent` endpoints work with real server
4. **Remove unimplemented methods** — `getUserBookStatus()` and `getUserLocation()` or implement them
5. **Add Money Donation API** — current `DonateMoneyPage` has no API integration (Razorpay TBD)
6. **Status tracking screen** — `BookDonationResponse` entity exists but no dedicated tracking UI yet
