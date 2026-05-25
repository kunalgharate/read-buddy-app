# Donation Feature — Jira Tickets

## Epic: Donation System
**Summary**: Build complete donation system for book and money donations with pickup/drop-off logistics and status tracking

**Description**: Users can donate books (physical, eBook, audiobook) and money to the ReadBuddy platform. Book donations include a form with book details, images, condition, and delivery method (drop-off or pickup). Money donations go through a payment gateway. All donations have status tracking from creation to completion.

**Figma**: https://www.figma.com/design/CKKpWQA3jZ0j1QlJMIz0ux/ReadBuddy?node-id=4001-7374

---

## Story 1: Donation Dashboard Tab
**Summary**: Display donation dashboard with impact stats, donation actions, and book status

**Acceptance Criteria**:
- Impact stats from API (Books Donated, Students Helped)
- "Donate a Book" and "Donate Money" buttons
- Book status list with badges (Completed/Pending/In Transit)
- Pull-to-refresh

---

## Story 2: Book Donation Form
**Summary**: Multi-step form for donating a book with details, images, and condition

**Acceptance Criteria**:
- Format selection (Physical/Digital)
- Book details: Title, Author, Genre, Language, ISBN
- Condition: New/Good/Fair/Poor
- Cover photo + additional images (max 4)
- POST /donations/book on submit
- Success confirmation with donation ID

---

## Story 3: Book Delivery Method Selection
**Summary**: User chooses drop-off or pickup for physical book donation

**Drop-off**: User ships to library. Status: Created → Shipped → In Transit → Delivered → Completed
**Pickup**: Librarian picks up. User enters address, name, phone. Status: Created → Pickup Requested → Scheduled → Picked Up → Delivered → Completed

**Acceptance Criteria**:
- Two options: "Drop to Library" / "Request Pickup"
- Drop-off shows library address
- Pickup form: address, name, phone, preferred date
- Confirmation screen before submission

---

## Story 4: Donation Status Tracking
**Summary**: Track donation status from creation to completion

**Statuses**: donation_created, book_shipped, in_transit, pickup_requested, pickup_scheduled, picked_up, delivered, completed, cancelled

**Acceptance Criteria**:
- Progress stepper/timeline on donation detail
- Current status highlighted
- GET /donations/:id for updates

---

## Story 5: Money Donation Flow
**Summary**: Allow users to donate money via payment gateway

**Acceptance Criteria**:
- Preset amounts: ₹50, ₹100, ₹200, ₹500
- Custom amount input (min ₹10)
- Payment gateway (Razorpay)
- Success screen with receipt
- POST /donations/money with amount + transaction ID

---

## Story 6: Admin — Donation Management
**Summary**: Admin dashboard to manage donation statuses

**Acceptance Criteria**:
- View all donations with filters
- Update status through flow
- Assign pickup to librarian
- GET/PATCH /admin/donations
