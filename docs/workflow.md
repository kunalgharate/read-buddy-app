# ReadBuddy — App Workflow

---

## 1. Onboarding

4 intro screens (World of Books → Donate → Request → Delivery)
- Sign In button visible throughout
- On completion → mark onboarding as seen
- Redirect → Questionnaire (first time) or Home (returning user)

---

## 2. Registration

Email/password sign-up
→ Email verification OTP
→ User preference questionnaire (genre, language, interests)
→ Redirect to Home

---

## 3. Login

**Email/password** or **Google Sign-In**

**Forgot password:** Email → OTP verification → Reset password

**After login — role-based redirect:**
| Role | Redirect |
|------|----------|
| User | Home (if onboarding done), else Questionnaire |
| Admin | Admin Dashboard |
| Librarian | Librarian Dashboard |

---

## 4. Donate Books

User donates a physical, eBook, audiobook, or video book.

**Fulfillment options:**
- **Pick Up** — agent collects from user's home
- **Drop** — user drops book at library

---

## 5. Get Prime

Two paths to Prime membership:
- **Donate a book** → receive Prime status as reward
- **Buy Prime** → pay via Razorpay

**Prime benefits:**
- Prime badge on profile
- Unlocks ability to request multiple books simultaneously

---

## 6. Request a Book

Requires Prime membership.

**Fulfillment options:**
- **Pick Up** — book delivered to user's home
- **Drop** — user collects from library

**Request lifecycle:**
- Pending → Accepted / Declined
- Scheduled → In Transit → Delivered
- **Validity extend** — user can extend reading period
- **Return** — Pick Up (agent collects) or Drop (user returns to library)

---

## 7. Read / Listen / Watch

| Format | Experience |
|--------|------------|
| eBook (PDF/EPUB) | In-app reader via `syncfusion_flutter_pdfviewer` / `flutter_epub_viewer` |
| Audiobook | Audio player with background playback via `just_audio` |
| Video Book | In-app video player |

---

## 8. Notifications

Push notifications for:
- Request approval / decline
- Pickup reminders
- Delivery updates
- Donation verification
- Overdue return reminders

---

## 9. Admin Dashboard

| Section | Actions |
|---------|---------|
| Book Categories | CRUD |
| Books | Add, edit, delete book listings |
| Book Variants | Add PDF / EPUB / audio / video variants |
| Users | View, manage user accounts |
| Banners | CRUD promotional banners |
| Donations | View and verify incoming donations |
| Book Requests | View, accept, decline, update status |
| Onboarding Questions | CRUD questionnaire questions |
| Library Management | Assign books to libraries, manage stock |

---

## 10. Librarian Dashboard

| Section | Actions |
|---------|---------|
| Book Request Management | Accept, schedule, mark delivered |
| Donation Management | Receive and verify donated books |
| Library Dashboard | View available books and stock levels |
