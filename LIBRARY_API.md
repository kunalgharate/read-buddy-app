# Library Management — Complete API Documentation

## Overview

Libraries are physical locations where books are stored. Admin can create libraries, assign users as librarians to manage them, and users interact with libraries for book pickup/drop-off during donations.

---

## Data Models

### Library Schema
```json
{
  "_id": "ObjectId",
  "name": "String (default: XYZ Library)",
  "imageUrl": "String (Cloudinary URL)",
  "address": {
    "street": "String",
    "city": "String",
    "state": "String",
    "country": "String (default: India)",
    "pincode": "String",
    "latitude": "Number",
    "longitude": "Number"
  },
  "contactNumber": "String",
  "openHours": "String",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### User (relevant fields)
```json
{
  "_id": "ObjectId",
  "name": "String",
  "email": "String",
  "userRole": "user | librarian | admin",
  "assignedLibrary": "ObjectId (ref: Library) | null"
}
```

---

## API Endpoints

### Base URLs
- Libraries: `{{baseUrl}}/api/v1/libraries`
- Admin: `{{baseUrl}}/api/admin`

---

## 1. Library CRUD (Admin Only)

### POST `/api/v1/libraries` — Create Library

**Access:** Admin only (adminAuth middleware)  
**Content-Type:** application/json

```json
// Request
{
  "name": "Central Library Raipur",
  "imageUrl": "https://res.cloudinary.com/.../library.jpg",
  "address": {
    "street": "Civil Lines, Near Bus Stand",
    "city": "Raipur",
    "state": "Chhattisgarh",
    "country": "India",
    "pincode": "492001",
    "latitude": 21.2514,
    "longitude": 81.6296
  },
  "contactNumber": "+919876543210",
  "openHours": "Mon-Sat 9AM-8PM"
}

// Response 201
{
  "success": true,
  "library": {
    "_id": "6a4...",
    "name": "Central Library Raipur",
    "address": { ... },
    "contactNumber": "+919876543210",
    "openHours": "Mon-Sat 9AM-8PM",
    "createdAt": "2026-06-29T...",
    "updatedAt": "2026-06-29T..."
  }
}
```

**Required fields:** `name`  
**Optional fields:** everything else (address, contactNumber, openHours, imageUrl)  
**latitude/longitude:** Required for "nearest library" feature on app

---

### GET `/api/v1/libraries` — List All Libraries (Public)

**Access:** Public (no auth needed)  
**Query params:**
- `city` — filter by city name (case-insensitive regex)
- `page` — page number (default: 1)
- `limit` — items per page (default: 50)

```
GET /api/v1/libraries?city=Raipur&page=1&limit=10
```

```json
// Response 200
{
  "success": true,
  "total": 3,
  "libraries": [
    {
      "_id": "6a4...",
      "name": "Central Library Raipur",
      "address": {
        "city": "Raipur",
        "state": "Chhattisgarh",
        "latitude": 21.2514,
        "longitude": 81.6296,
        ...
      },
      "contactNumber": "+919876543210",
      "openHours": "Mon-Sat 9AM-8PM"
    }
  ]
}
```

---

### GET `/api/v1/libraries/details` — All Libraries (For App - Nearest Agents)

**Access:** Auth required  
**Use case:** Flutter app fetches this for donation drop-off library selection & nearest agent display

```json
// Response 200
{
  "success": true,
  "libraries": [
    {
      "_id": "6a4...",
      "name": "Central Library Raipur",
      "address": { "latitude": 21.2514, "longitude": 81.6296, ... }
    }
  ]
}
```

**Flutter usage:** Use latitude/longitude to calculate distance from user's location and show nearest libraries.

---

### GET `/api/v1/libraries/:id` — Single Library

**Access:** Public

```json
// Response 200
{ "success": true, "library": { ... } }

// Response 404
{ "error": "Library not found" }
```

---

### PUT `/api/v1/libraries/:id` — Update Library

**Access:** Admin only  
**Content-Type:** application/json

```json
// Request — only send fields you want to change
{
  "name": "Updated Library Name",
  "address": {
    "city": "Nagpur",
    "latitude": 21.1458,
    "longitude": 79.0882
  },
  "openHours": "Mon-Sun 8AM-9PM"
}

// Response 200
{ "success": true, "library": { ... } }
```

---

### DELETE `/api/v1/libraries/:id` — Delete Library

**Access:** Admin only

```json
// Response 200
{ "success": true, "message": "Library deleted" }
```

---

## 2. Assign/Unassign Librarian (Admin Only)

### PATCH `/api/admin/users/:userId/assign-library` — Assign User as Librarian

**Access:** Admin only  
**What it does:**
1. Validates library exists
2. Sets `assignedLibrary` on user
3. Auto-changes `userRole` to `librarian`

```json
// Request
{ "libraryId": "6a4..." }

// Response 200
{
  "success": true,
  "message": "Kunal Gharate assigned as librarian to Central Library Raipur",
  "user": {
    "_id": "667...",
    "name": "Kunal Gharate",
    "email": "kunal@example.com",
    "userRole": "librarian",
    "assignedLibrary": {
      "_id": "6a4...",
      "name": "Central Library Raipur",
      "address": { ... }
    }
  }
}
```

---

### PATCH `/api/admin/users/:userId/unassign-library` — Remove Library Assignment

**Access:** Admin only  
**What it does:**
1. Clears `assignedLibrary` (sets to null)
2. Resets `userRole` back to `user`

```json
// Response 200
{
  "success": true,
  "message": "Kunal Gharate unassigned from library, role reset to user",
  "user": { "_id": "...", "userRole": "user", "assignedLibrary": null }
}
```

---

### PATCH `/api/admin/users/:userId/make-librarian` — Make Librarian (without library)

**Access:** Admin only  
**Note:** Only changes role. Use `assign-library` to also link a library.

```json
// Response 200
{ "success": true, "message": "Kunal Gharate is now a Librarian", "user": { ... } }
```

---

## 3. Get Librarians (Admin Only)

### GET `/api/admin/librarians` — All Librarians with Their Libraries

**Access:** Admin only

```json
// Response 200
{
  "success": true,
  "total": 2,
  "librarians": [
    {
      "_id": "667...",
      "name": "Ashutosh Patil",
      "email": "ash@example.com",
      "userRole": "librarian",
      "assignedLibrary": {
        "_id": "6a4...",
        "name": "Central Library Raipur",
        "address": { "city": "Raipur", ... },
        "contactNumber": "+91...",
        "openHours": "Mon-Sat 9AM-8PM"
      }
    },
    {
      "_id": "668...",
      "name": "Priya Sharma",
      "email": "priya@example.com",
      "userRole": "librarian",
      "assignedLibrary": null
    }
  ]
}
```

---

### GET `/api/admin/libraries/:libraryId/librarians` — Librarians for Specific Library

**Access:** Admin only

```json
// Response 200
{
  "success": true,
  "total": 1,
  "librarians": [
    { "_id": "667...", "name": "Ashutosh Patil", "email": "ash@example.com" }
  ]
}
```

---

## 4. User Management (Related APIs)

### GET `/api/admin/users` — List All Users

**Access:** Admin only  
**Query params:**
- `role` — filter by role: `user`, `librarian`, `admin`
- `isPrime` — filter by prime status: `true` / `false`
- `search` — search by name or email
- `page`, `limit` — pagination

```
GET /api/admin/users?role=librarian&search=kunal&page=1&limit=20
```

---

### PATCH `/api/admin/users/:id/reset-role` — Reset to Regular User

Removes librarian/admin role, but does NOT clear assignedLibrary. Use `unassign-library` for full removal.

---

### PATCH `/api/admin/users/:id/block` / `/unblock` — Block/Unblock User

Blocks invalidate the session immediately.

---

## 5. Complete Flow for Frontend (Flutter)

### Flow A: Admin Creates Library & Assigns Librarian

```
Step 1: POST /api/v1/libraries
        Body: { name, address: { street, city, state, pincode, latitude, longitude }, contactNumber, openHours }
        → Save libraryId from response

Step 2: GET /api/admin/users?search=ashutosh
        → Find the user to make librarian, save userId

Step 3: PATCH /api/admin/users/:userId/assign-library
        Body: { libraryId: "<from step 1>" }
        → User is now librarian + assigned to library
```

### Flow B: User Donates Book (Drop-off)

```
Step 1: GET /api/v1/libraries/details
        → App shows all libraries on map using latitude/longitude
        → User selects nearest library

Step 2: POST /api/v1/donations/createBookDonation
        Body: {
          bookDetails: { bookName, category, condition, language },
          fulfillmentType: "DROP_OFF",
          dropoff: { libraryId: "<selected library _id>" }
        }
```

### Flow C: User Donates Book (Pickup)

```
Step 1: POST /api/v1/donations/createBookDonation
        Body: {
          bookDetails: { bookName, ... },
          fulfillmentType: "PICKUP",
          pickup: { name, mobile, address, pincode, latitude, longitude }
        }

Step 2: Admin assigns pickup via:
        PATCH /api/admin/donations/:id/assign-pickup
        Body: { librarianId, scheduledDate, scheduledTime }
```

### Flow D: Admin Views Librarian Dashboard

```
GET /api/admin/librarians                    → All librarians with libraries
GET /api/admin/libraries/:id/librarians      → Librarians for one library
GET /api/v1/libraries                        → All libraries
PATCH /api/admin/users/:id/assign-library    → Assign
PATCH /api/admin/users/:id/unassign-library  → Remove
```

---

## 6. Error Responses

| Status | Meaning |
|--------|---------|
| 400 | Missing required field / validation error |
| 401 | Not authenticated |
| 403 | Not admin (insufficient role) |
| 404 | Library or user not found |
| 500 | Server error |

```json
{ "error": "descriptive message" }
```

---

## 7. Location / Lat-Long Usage

The `address.latitude` and `address.longitude` fields on Library are used by the Flutter app to:
1. Show libraries on a map (Google Maps / Ola Maps)
2. Calculate distance from user's current location
3. Sort/filter by "nearest library"
4. Show in donation drop-off selection

**Important:** Always include latitude and longitude when creating/updating a library, otherwise the app can't show it on the map or calculate distance.
