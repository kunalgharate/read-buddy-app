---
inclusion: fileMatch
fileMatchPattern: ["**/library_inventory/**", "**/city_*", "**/city_location*", "**/main_tab*", "**/borrow_order/**"]
---

# City-Based Library Inventory

## Architecture
```
CityNotifier (ValueNotifier<String?> singleton)
  └── persists city to SharedPreferences
  └── auto-detects via GPS (LocationService.instance)
  └── recent cities list (max 5)

CityLocationBar (widget)
  └── Zomato-style bar → _CityPickerSheet bottom sheet
  └── GPS detect + recent locations + manual type

LibraryInventoryBloc (BLoC)
  └── Events: LoadLibraryInventory, AddBookToLibraryEvent, UpdateInventoryEvent, DeleteInventoryEvent, BrowseCityBooks
  └── States: LibraryInventoryLoaded, InventoryAdded, InventoryUpdated, InventoryDeleted, CityBooksLoaded, LibraryInventoryError
```

## Home Page (main_tab.dart)
- CityLocationBar at top (above banner)
- _CityBooksSection replaces old global Latest/Recommended
- _MainTabState manages LibraryInventoryBloc + listens to CityNotifier changes
- Books shown: horizontal CityBookCard list with availability badges

## Borrow Flow
- LibraryPickerSheet — shows libraries in user's city with availability
- Returns LibraryPickResult (libraryId, variantId, formatId, formatType)
- AddBookToCart event takes: bookId, variantId, formatId, libraryId (optional)
- Full chain: Event → BLoC → UseCase → Repository → DataSource → POST /api/v1/borrow-orders/add-book

## API Endpoints
| Endpoint | Constant | Purpose |
|----------|----------|---------|
| `$baseUrl/v1/library-inventory` | `ApiConstants.libraryInventory` | Admin CRUD |
| `$baseUrl/v1/library-inventory/browse` | `ApiConstants.libraryInventoryBrowse` | City browse |
| `$baseUrl/v1/library-inventory/$id` | `ApiConstants.libraryInventoryById(id)` | Single record |

## Key Files
- `lib/core/services/city_notifier.dart` — City state singleton
- `lib/core/widgets/city_location_bar.dart` — Location picker UI
- `lib/features/library_inventory/` — Full feature module (14 files)
- `lib/features/home/presentation/widgets/main_tab.dart` — City-filtered home
- `lib/features/library/presentation/pages/library_detail_page.dart` — Admin "Add Book" + "View Books"
