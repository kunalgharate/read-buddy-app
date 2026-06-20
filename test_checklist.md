# ReadBuddy - Features Test Checklist

Use this checklist during your testing session to verify each feature. Check off the items as they pass verification.

---

## 🟢 1. Authentication & Roles
- [ ] **Login & Registration (User)**
  - *Steps*: Register a new user account, verify email, and log in.
  - *Expected Result*: Successful sign-in redirects to the standard `HomeScreen`.
- [ ] **Login & Registration (Admin)**
  - *Steps*: Sign in with an account having `'admin'` role credentials.
  - *Expected Result*: Redirects to the `Admin Panel` dashboard.
- [ ] **Session Auto-load Check**
  - *Steps*: Close the app while logged in, relaunch.
  - *Expected Result*: Automatically logs in and populates user profile instantly (verifiable via Profile tab and detail screens).

---

## 🟢 2. Memberships & Donations
- [ ] **Physical Book Donation Flow**
  - *Steps*: Go to "Donate" tab, choose Courier or Library Drop-off, fill book details, upload cover/images.
  - *Expected Result*: Submits successfully and appears in the admin's donation tracker.
- [ ] **Monetary Donation (Make Prime Member)**
  - *Steps*: Navigate to Payment/Donation screen, complete a mock Razorpay payment.
  - *Expected Result*: User profile instantly displays gold "Prime Member" badge, and homepage replaces the donation card with banner slides.

---

## 🟢 3. Book Catalog & Variants
- [ ] **Add Parent Book with Variants**
  - *Steps*: Click "+ Book" -> Complete Step 1 (basic info) and Step 2 (condition & cover). In Step 3, configure language variants (e.g. English, Hindi) and formats (Hardcover, Ebook, Audiobook).
  - *Expected Result*: Submits successfully. Variants are retrieved from MongoDB.
- [ ] **Show Book Details**
  - *Steps*: Click on a book on home or search page.
  - *Expected Result*: Displays the covers, author, description, and list of available variants/format chips.
- [ ] **Add Variant UI Access Restriction**
  - *Steps*: Log in as a normal user, open a book you **do not** own.
  - *Expected Result*: The "Add Variant" button is completely hidden.
- [ ] **Admin/Owner Variant Management**
  - *Steps*: Log in as the book owner or admin, open the book details.
  - *Expected Result*: The "Add Variant" button is visible and allows adding new language/format combinations.

---

## 🟢 4. Borrowing & Orders
- [ ] **Request Book (Fulfillment Option)**
  - *Steps*: Open book details, click "Request to Book", select PICKUP, DELIVERY, or MEETUP.
  - *Expected Result*: Request succeeds. Admin sees the user's entered address during request verification.
- [ ] **Show Book in Orders**
  - *Steps*: Go to "My Books" navigation tab.
  - *Expected Result*: Shows active borrowings, order status, and request logs.
- [ ] **Return Book**
  - *Steps*: Mark a borrowed book as returned.
  - *Expected Result*: Updates the user's active checkout listing.

---

## 🟢 5. Multimedia Readers
- [ ] **eBook Reader (PDF / EPUB)**
  - *Steps*: Open an eBook variant or eBook details, select a language, click "Read Now".
  - *Expected Result*: Launches the PDF/EPUB viewer showing book content.
- [ ] **Audio Book Narration**
  - *Steps*: Open an Audiobook variant, click play.
  - *Expected Result*: Launches the media player showing seek controls, track name, and duration counter.

---

## 🟡 6. Partially Implemented & Pending Features (Under Construction)
- [ ] **Show Nearest Library via Location**
  - *Steps*: In the drop-off donation flow, search pincodes or grant GPS location permission.
  - *Expected Result*: Lists near library branches. *(Note: Map visual pin rendering is pending).*
- [ ] **Create Library / Assign Librarian**
  - *Steps*: Attempt to create a branch library or associate a librarian account.
  - *Expected Result*: *(Note: Currently a backend placeholder; frontend UI is pending).*
- [ ] **Video Book**
  - *Steps*: In `BookFormatBottomSheet`, select "Video book".
  - *Expected Result*: Shows a SnackBar saying "Coming Soon!". *(Note: Media player integration is pending).*
