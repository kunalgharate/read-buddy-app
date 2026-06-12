# ReadBuddy - Book Variants Implementation Documentation

This document explains the Clean Architecture implementation of the **Book Creation with Variants** feature, highlighting all changes, file paths, and functionality details.

---

## 1. Domain Layer (Entities & Repository Contracts)

We established domain entities to represent the concept of a Parent Book with multiple language-specific variants and formats:

- **[parent_book_entity.dart](file:///c:/Users/HP/AndroidStudioProjects/read-buddy-app/lib/features/bookcrud/domain/entities/parent_book_entity.dart)** [NEW]:
  - Represents the main parent book details.
  - Contains fields: `id`, `title`, `author`, `publisher`, `description`, `coverImageUrl`, `coversingleImage` (local File), `categories` (List), `tags` (List), and `status` (Draft / Published).
- **[book_variant_entity.dart](file:///c:/Users/HP/AndroidStudioProjects/read-buddy-app/lib/features/bookcrud/domain/entities/book_variant_entity.dart)** [NEW]:
  - Defines language variants (e.g. English, Hindi, Marathi).
  - Models format subtypes (`hardcover`, `ebook`, `audiobook`) with details such as ISBN, copies count, availability, local filenames, and audio track duration.
- **[variant_repository.dart](file:///c:/Users/HP/AndroidStudioProjects/read-buddy-app/lib/features/bookcrud/domain/respository/variant_repository.dart)** [NEW]:
  - Abstract repository interface defining operations to get, save, and delete parent books and their variants.

---

## 2. Data Layer (Models & SharedPreferences Persistence)

We implemented serialization and data sync contracts under the data layer:

- **[parent_book_model.dart](file:///c:/Users/HP/AndroidStudioProjects/read-buddy-app/lib/features/bookcrud/data/model/parent_book_model.dart)** [NEW]:
  - Extends `ParentBookEntity` and implements JSON mapping (`fromJson`/`toJson` and `fromEntity`).
- **[book_variant_model.dart](file:///c:/Users/HP/AndroidStudioProjects/read-buddy-app/lib/features/bookcrud/data/model/book_variant_model.dart)** [NEW]:
  - Extends `BookVariantEntity` and `BookFormatEntity` and handles nested format serialization to structure database entries.
- **[variant_repository_impl.dart](file:///c:/Users/HP/AndroidStudioProjects/read-buddy-app/lib/features/bookcrud/data/repositories/variant_repository_impl.dart)** [NEW]:
  - SharedPreferences-backed repository implementation.
  - Stores all configured book variants locally, linking them to their respective parent book ID.
- **[injection.dart](file:///c:/Users/HP/AndroidStudioProjects/read-buddy-app/lib/core/di/injection.dart)** [MODIFY]:
  - Registered the lazy singleton `VariantRepository` as `VariantRepositoryImpl` to make it accessible to UI pages using `getIt<VariantRepository>()`.

---

## 3. Presentation Layer (UI & Forms Wizard)

We modified the book creation page flow to include language and format customizers:

- **[addbook_stepper.dart](file:///c:/Users/HP/AndroidStudioProjects/read-buddy-app/lib/features/bookcrud/presentation/widgets/addbook_stepper.dart)** [MODIFY]:
  - Extended the horizontal wizard stepper from 2 steps to 3 steps.
  - Registered Step 3: "Manage Variants" using `AddBookVariantsSection`.
- **[add_book_page2.dart](file:///c:/Users/HP/AndroidStudioProjects/read-buddy-app/lib/features/bookcrud/presentation/pages/Add/add_book_page2.dart)** [MODIFY]:
  - Accepts an `onContinue` callback parameter.
  - Replaced the direct BLoC command/popup transition with `widget.onContinue(completeBook)` to delegate control to Step 3.
- **[add_book_variants_section.dart](file:///c:/Users/HP/AndroidStudioProjects/read-buddy-app/lib/features/bookcrud/presentation/widgets/add_book_variants_section.dart)** [NEW]:
  - Implements the complete user interface for language and format variant configuration.
  - Displays the selected **Parent Book Preview Card** at the top.
  - **Animated Format Selectors**: Employs custom animated selectable cards (Hardcover, E-Book, Audiobook) with distinct colors.
  - **Dashed Upload Components**: Custom uploader layout utilizing a custom painter `_DashedRectPainter` to draw dashed border frames.
  - **Simulated Progress & Speed**: Simulates document/audio uploads with linear progress bars showing progress percentage, upload rate (e.g. `2.4 MB/s`), and file format/size badges.
  - **Copies Count Controller**: Replaces basic copy text inputs with an interactive increment/decrement widget featuring tap controls.
  - **Duplicate Language Validation**: The language picker blocks selections of duplicate languages (already added items display `(Already Added)` and are disabled).
  - **File Type Suffix Verification**: E-book file selects require `.pdf` or `.epub`. Audiobook track selects require `.mp3`, `.wav` or `.m4a` format.
  - **Draft/Publish Integration**: Tapping "Save Draft" or "Publish" calls the local repository to store variant details and fires BLoC events to upload parent books to backend servers.

---

## 4. Summary of Added/Modified File Paths

- **Entities**:
  - `lib/features/bookcrud/domain/entities/parent_book_entity.dart`
  - `lib/features/bookcrud/domain/entities/book_variant_entity.dart`
  - `lib/features/bookcrud/domain/respository/variant_repository.dart`
- **Data & DI**:
  - `lib/features/bookcrud/data/model/parent_book_model.dart`
  - `lib/features/bookcrud/data/model/book_variant_model.dart`
  - `lib/features/bookcrud/data/repositories/variant_repository_impl.dart`
  - `lib/core/di/injection.dart`
- **Widgets & Pages**:
  - `lib/features/bookcrud/presentation/widgets/add_book_variants_section.dart`
  - `lib/features/bookcrud/presentation/widgets/addbook_stepper.dart`
  - `lib/features/bookcrud/presentation/pages/Add/add_book_page2.dart`
- **Documentation**:
  - `variants_changes.md`
  - `PROJECT_GUIDE.md`
