# ReadBuddy — Library & Volunteer System Design

**Date:** 2026-06-30  
**Status:** Design Document — Ready for Implementation

---

## System Overview

ReadBuddy operates a **volunteer-based community library network**. Books are donated by users and stored at physical library locations managed by volunteers. Users can borrow books either by picking up from a nearby library or requesting home delivery.

```
┌─────────────┐         ┌─────────────────┐         ┌──────────────┐
│   USER      │────────▶│    LIBRARY      │◀────────│  VOLUNTEER   │
│ (donor/     │ donates │ (physical       │ manages │  (assigned   │
│  borrower)  │ borrows │  location)      │         │   librarian) │
└─────────────┘         └─────────────────┘         └──────────────┘
                               │
                               │ belongs to
                               ▼
                        ┌─────────────────┐
                        │ SUPER LIBRARY   │
                        │ (regional hub / │
                        │  fallback)      │
                        └─────────────────┘
```

---

## Core Concepts

### Library
A physical location (government library, community center, volunteer's home) where donated books are stored and managed. Each library has:
- A physical address with GPS coordinates
- Operating hours and contact info
- One or more assigned volunteers (librarians)
- An inventory of books (future scope)

### Super Library
A regional hub library that serves as the **fallback** when no nearby library exists for a user. Super libraries:
- Always appear in donation drop-off selection
- Act as central collection points for a region
- Can be one per city/state or a single national hub
- Set by admin via `isSuperLibrary: true`

### Volunteer (Librarian)
A user assigned to a library by the admin. Volunteers:
- Manage book donations on behalf of the library
- Accept/reject book pickup requests
- Handle inventory at their library
- Are NOT directly connected to end users — they work through the library
- A government library may have multiple volunteers; a home library has one

### User Address
A saved delivery address for the end user. Used when:
- Requesting a book with "Deliver to me" option
- Admin/volunteer needs to schedule a pickup from donor's home

---

## Architecture

### What Exists → What Changes

| Current | New |
|---------|-----|
| `Agent` entity/model | **Remove** — replaced by Library |
| `AgentModel.fromJson()` | Use `LibraryModel` everywhere |
| `GetNearestAgents` usecase | → `GetNearestLibraries` |
| `nearest_agents_widget.dart` | → `nearest_libraries_widget.dart` |
| Basic `AddressManagementScreen` | → Full structured address with lat/lng |

### Feature Structure

```
lib/features/library/
├── data/
│   ├── datasources/
│   │   └── library_remote_datasource.dart
│   ├── models/
│   │   └── library_model.dart
│   └── repositories/
│       └── library_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── library_entity.dart
│   ├── repositories/
│   │   └── library_repository.dart
│   └── usecases/
│       ├── get_libraries.dart
│       ├── get_super_libraries.dart
│       ├── get_library_by_id.dart
│       ├── create_library.dart
│       ├── update_library.dart
│       ├── delete_library.dart
│       ├── toggle_super_library.dart
│       ├── assign_librarian.dart
│       ├── unassign_librarian.dart
│       └── get_librarians.dart
└── presentation/
    ├── bloc/
    │   ├── library_bloc.dart
    │   ├── library_event.dart
    │   └── library_state.dart
    ├── pages/
    │   ├── library_list_page.dart        (admin)
    │   ├── create_library_page.dart      (admin)
    │   ├── library_detail_page.dart      (admin + user)
    │   └── assign_librarian_page.dart    (admin)
    └── widgets/
        ├── library_card.dart
        ├── library_selector.dart         (user — donation drop-off)
        └── location_picker_widget.dart
```

```
lib/features/address/
├── data/
│   ├── datasources/
│   │   └── address_remote_datasource.dart
│   ├── models/
│   │   └── address_model.dart
│   └── repositories/
│       └── address_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── address_entity.dart
│   ├── repositories/
│   │   └── address_repository.dart
│   └── usecases/
│       ├── get_addresses.dart
│       ├── create_address.dart
│       ├── update_address.dart
│       └── delete_address.dart
└── presentation/
    ├── bloc/
    │   ├── address_bloc.dart
    │   ├── address_event.dart
    │   └── address_state.dart
    ├── pages/
    │   └── address_management_page.dart
    └── widgets/
        ├── address_card.dart
        ├── address_form.dart
        └── address_selector.dart         (book request — pick delivery address)
```

```
lib/core/services/
└── location_service.dart                 (GPS + distance calculation)
```

---

## Data Models

### Library Entity

```dart
class LibraryEntity {
  final String id;
  final String name;
  final String? imageUrl;
  final LibraryAddress address;
  final String contactNumber;
  final String openHours;
  final bool isSuperLibrary;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class LibraryAddress {
  final String street;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final double latitude;
  final double longitude;
}
```

### Address Entity (User's saved addresses)

```dart
class AddressEntity {
  final String id;
  final String label;          // Home, Work, Other
  final String name;           // Recipient name
  final String phone;          // 10-digit mobile
  final String addressLine1;   // Flat/House/Building
  final String addressLine2;   // Street/Area
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final bool isDefault;
}
```

---

## API Endpoints

### Library APIs

| Method | Endpoint | Access | Purpose |
|--------|----------|--------|---------|
| POST | `/api/v1/libraries` | Admin | Create library |
| GET | `/api/v1/libraries` | Public | List all libraries (paginated, filter by city) |
| GET | `/api/v1/libraries/details` | Auth | All libraries with coordinates (for distance calc) |
| GET | `/api/v1/libraries/super` | Public | Get super libraries only (fallback for donations) |
| GET | `/api/v1/libraries/:id` | Public | Single library details |
| PUT | `/api/v1/libraries/:id` | Admin | Update library |
| DELETE | `/api/v1/libraries/:id` | Admin | Delete library |
| PATCH | `/api/v1/libraries/:id/toggle-super` | Admin | Toggle super library status |
| PATCH | `/api/admin/users/:userId/assign-library` | Admin | Assign volunteer to library |
| PATCH | `/api/admin/users/:userId/unassign-library` | Admin | Remove volunteer from library |
| GET | `/api/admin/librarians` | Admin | All librarians with their libraries |
| GET | `/api/admin/libraries/:libraryId/librarians` | Admin | Librarians for specific library |

### Address APIs (User)

| Method | Endpoint | Access | Purpose |
|--------|----------|--------|---------|
| POST | `/api/addresses` | Auth | Add new address |
| GET | `/api/addresses` | Auth | Get all user's addresses |
| PUT | `/api/addresses/:id` | Auth | Update address |
| DELETE | `/api/addresses/:id` | Auth | Delete address |

---

## User Flows

### Flow 1: Admin Creates a Library

```
1. Admin opens Library Management → taps "Add Library"
2. Form fields: name, contact, open hours, image (optional)
3. Address input:
   Option A: Enter manually (street, city, state, pincode)
   Option B: Tap "Use Current Location" → GPS fills lat/lng + reverse geocode fills address
4. Toggle "Super Library" switch (off by default)
5. Submit → POST /api/v1/libraries
6. After creation → navigate to Assign Librarian page
7. Search users → Select user → PATCH assign-library
```

### Flow 2: User Donates Book (Drop-off)

```
1. User selects "Drop Off at Library" in donation form
2. App gets user's current location (LocationService)
3. Fetch libraries: GET /api/v1/libraries/details
4. Calculate distance from user to each library
5. Show list sorted by nearest first
6. If no library within reasonable range → show super libraries
7. User selects a library → library ID saved in donation request
```

### Flow 3: User Requests Book (Delivery)

```
1. User taps "Request Book" → selects "Deliver to Me"
2. Fetch saved addresses: GET /api/addresses
3. Show address list with default highlighted
4. User selects address (or taps "Add New Address")
5. Selected address sent with book request
```

### Flow 4: User Adds/Manages Address

```
1. Settings → My Addresses (or inline during book request)
2. "Add Address" form:
   - Label (Home/Work/Other)
   - Recipient name, phone
   - Address line 1, Address line 2
   - City, State, Pincode
   - Location: "Use Current Location" OR manual entry
   - Set as default toggle
3. Save → POST /api/addresses
```

### Flow 5: User Picks Up Book from Library

```
1. User taps "Collect from Library" option
2. App shows nearest libraries with distance (km)
3. User taps a library → sees detail (address, hours, contact, map link)
4. User confirms → book request created with pickup from that library
5. Future: show available books at that library
```

---

## Location Service

### Package: `geolocator` (free, works on Android + iOS)

```dart
class LocationService {
  /// Get user's current GPS coordinates
  Future<Position> getCurrentLocation();
  
  /// Calculate distance between two coordinates (in km)
  double calculateDistance(double lat1, double lng1, double lat2, double lng2);
  
  /// Sort libraries by distance from user
  List<LibraryEntity> sortByNearest(List<LibraryEntity> libraries, Position userLocation);
  
  /// Check if location permission is granted, request if not
  Future<bool> requestLocationPermission();
}
```

### Distance Calculation
- Use Haversine formula (built into `geolocator` package)
- Show distance as: "2.3 km away", "500 m away"
- Consider a library "nearby" if within 25 km
- If none within 25 km → show super libraries with actual distance

---

## Admin Screens

### Library List Page (Admin)
- List of all libraries as cards
- Each card shows: name, city, volunteer count, super badge
- FAB: "Add Library"
- Tap card → Library detail/edit
- Swipe or long-press → delete

### Create/Edit Library Page (Admin)
- Name (required)
- Image upload (optional — Cloudinary)
- Contact number
- Open hours
- Address section:
  - "Use Current Location" button (fills lat/lng + reverse geocodes address)
  - Manual fields: street, city, state, pincode
  - Lat/Lng (auto-filled or manual)
- "Mark as Super Library" toggle
- Save button

### Assign Librarian Page (Admin)
- Search users by name/email
- Show user list
- Tap user → confirm assign to this library
- Show currently assigned volunteers with option to remove

---

## What Gets Removed

| File/Concept | Reason |
|---|---|
| `lib/features/donate/domain/entities/agent.dart` | Replaced by LibraryEntity |
| `lib/features/donate/data/models/agent_model.dart` | Replaced by LibraryModel |
| `lib/features/donate/domain/usecases/get_nearest_agents.dart` | → GetNearestLibraries |
| `lib/features/donate/presentation/widgets/nearest_agents_widget.dart` | → Library selector |
| Old `AddressManagementScreen` in settings/ | → Proper address feature with clean arch |

---

## Implementation Order

| Phase | What | Depends on |
|-------|------|-----------|
| 1 | Location service (`geolocator` setup) | Nothing |
| 2 | Library feature (entity, model, datasource, repo, usecases, bloc) | Phase 1 |
| 3 | Admin library pages (create, list, detail, assign librarian) | Phase 2 |
| 4 | Remove Agent, update donate flow to use Library | Phase 2 |
| 5 | Address feature (entity, model, datasource, repo, usecases, bloc) | Nothing |
| 6 | Address pages (management, selector for book request) | Phase 5 |
| 7 | Integration — book request uses address selector, donation uses library selector | Phase 4 + 6 |

---

## Future Scope (Not in Current Sprint)

- Library inventory view (which books are at which library)
- Available books at nearby library (browse before pickup)
- Map view with library pins
- Volunteer dashboard (librarian-specific UI)
- Delivery tracking between libraries
- Book transfer between libraries
- Rating/reviews for libraries

---

## Dependencies to Add

```yaml
# pubspec.yaml
dependencies:
  geolocator: ^6.0.0         # GPS location
  geocoding: ^3.0.0           # Reverse geocode (lat/lng → address)
```

No paid APIs required. `geolocator` uses native GPS, and `geocoding` uses the device's built-in geocoder.

---

*Document prepared for implementation. Confirm to proceed with Phase 1 (Location Service).*
