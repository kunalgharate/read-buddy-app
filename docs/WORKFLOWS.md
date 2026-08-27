# ReadBuddy — Workflows

---

## Registration
Sign Up → Email Verification OTP → Questionnaire → Home

## Onboarding
4 Intro Screens → "Sign In" button → mark seen → Questionnaire or Home

## Login
Email/Password Login | Google Sign-In | Forgot Password (OTP reset)
→ Check Role:
- admin → Admin Dashboard
- user → Home (if onboarding done) or Questionnaire
- librarian → Librarian Dashboard

## Donate Books
Pickup (from home) or Drop (to library)

## Get Prime
Donate a Book (receive Prime) or Buy Prime (Razorpay payment)
→ Prime badge on profile → Unlocks ability to request books

## Request Book
Pickup or Drop → Status tracking → Validity extend

## Return Book
Pickup or Drop

## Read eBook
Opens PDF or EPUB reader

## Listen Audiobook
Opens audiobook player with background playback

## Watch Video
Implemented — in-app video player with Chewie

---

## Admin
- Manage books, categories, banners, users, donations, book requests, onboarding questions (CRUD)
- Book request processing: Admin accepts or rejects (with reason)
  - Accept (pickup) → delivery fee payment → processing → mark as delivered
  - Accept (drop off) → mark as delivered
- Return process should work as expected

## Library (Librarian)
- Book request management
- Donation management
- Library dashboard

## Notifications
Push notifications for request approval, pickup reminders, delivery updates, donation verification, overdue returns
