---
inclusion: always
---

# ReadBuddy Mobile — Product Overview

ReadBuddy is a donation-based book sharing platform. This is the Flutter mobile app serving end users, librarians, and admins.

## Membership Model
- **Non-Prime**: Can browse, donate. Cannot borrow or access content (eBook/audio/video).
- **Becoming Prime**: Donate ₹100+ (instant) OR donate a book (admin approves).
- **Prime**: Full access to borrow, read, listen, watch.
- **Non-Prime Content Access**: Show `showPrimeRequiredDialog()` → redirect to donation page.

## User Roles
- **End User**: Browse, donate, borrow (if Prime), read/listen/watch, manage profile
- **Librarian**: Accept/reject book requests, deliver books, add books
- **Super Admin**: Manage everything — users, libraries, books, categories, banners

## Core Features
1. **Auth**: Sign in, sign up, Google sign in, email verification, forgot password
2. **Onboarding**: Preference questionnaire after first registration
3. **Home**: Latest, recommended, trending books + category browse
4. **Book Formats**: Physical request, eBook reader (PDF/EPUB), Audiobook player, Videobook player
5. **Donation**: Book donation (pickup/drop-off) + Money donation (Razorpay)
6. **Book Request**: Create request → admin approves → schedule pickup/delivery → receive → return
7. **Settings**: Dark/Light theme, notifications toggle, address management
8. **Single-Device Session**: Only 1 device active. Show `showSessionExpiredDialog()` if kicked out.
9. **Notifications**: Firebase FCM for request updates, delivery alerts
10. **Admin Dashboard**: Book requests, donation management, user management (librarian app features)

## Business Rules
- Non-prime users CANNOT access read/listen/watch — always show donation prompt
- One BookVariant per book+language — UI sends formats to existing variant via merge
- Librarians see only their library's requests
- Session replaced → force logout → show dialog → redirect to sign in

## Backend
- Base URL: configured in `api_constants.dart`
- All API calls via Dio with auth interceptor
- `SESSION_REPLACED` code → don't retry, show dialog
- `NOT_PRIME` code → show donation prompt
