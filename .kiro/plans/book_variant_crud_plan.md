# Book + BookVariant CRUD — Implementation Plan

## Confirmed Requirements
1. **Book Add** — Simple: title, author, publisher, description, categories (autocomplete), tags, coverImage. No location, no condition, no format/language/genre (those go in variants).
2. **Donors** — Every format in a variant has its own donorId. Multiple people can donate different copies/formats.
3. **Book Detail** — Show variants inline from the GET response (already included in book data).
4. **ownerId removed** — Donor info lives at the variant/format level only.
5. **No location on books** — Books are just metadata. Location handled elsewhere.

## Tasks (in order)

### Phase 1: Simplify Add Book ✅
- [x] Task 1.1 — Rewrite AddBookPage: title, author, publisher, description, category autocomplete, tags, coverImage
- [x] Task 1.2 — Remove 2-step stepper (BookStepper now wraps single AddBookPage)
- [x] Task 1.3 — Fix addBook remote data source (sends categories as JSON array, coverImage as file, removed hardcoded location/condition)
- [x] Task 1.4 — Fix updateBook to use multipart/form-data

### Phase 2: Fix Update Book
- [x] Task 2.1 — Fix updateBook to use multipart/form-data ✅ (done in Phase 1)
- [ ] Task 2.2 — Align UpdateBookPage with simplified fields

### Phase 3: Fix Variant Add
- [x] Task 3.1 — Fix file picker (use FileType.custom with proper extensions + error handling)
- [x] Task 3.2 — Fix donor search (UserModel.fromJson null-safe + debug logging)
- [x] Task 3.3 — Add videoParts to full variant submission flow (data source → repo → usecase → BLoC → widget)

### Phase 4: Book Detail — Show Variants Inline
- [x] Task 4.1 — Parse variants from GET response in BookCrudModel.fromJson
- [x] Task 4.2 — Display variants on detail page (language card + format tiles with type/details)

### Phase 5: Variant Update + Delete
- [x] Task 5.1 — Delete variant with confirmation dialog
- [x] Task 5.2 — BlocListener handles VariantCreated/VariantDeleted states with feedback

