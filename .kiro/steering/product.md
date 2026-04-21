---
inclusion: always
---

# ReadBuddy — Product Overview

ReadBuddy is a donation-based book sharing platform. Users donate physical books, eBooks, audiobooks, and video books to the system. These books get circulated to other users who join the app.

## Key Features
- **Book Donation**: Users donate books (physical, eBook, audiobook, video) to the platform
- **Book Circulation**: Donated books are shared with other users
- **Prime Membership**: Premium users can access multiple books simultaneously
- **Multi-Format Reading**: Physical books, PDF/EPUB eBooks, audiobooks, video books
- **Multi-Language**: English, Hindi, Marathi support
- **Admin Dashboard**: Content management for books, categories, banners, questions
- **Onboarding**: Questionnaire-based user preference collection

## Target Users
- Book readers who want free access to books
- Book donors who want to share their collection
- Admins who manage the book library

## Backend
- Node.js on Render.com (free tier — cold starts expected)
- Base URL: `https://readbuddy-server.onrender.com/api`
- API endpoints: #[[file:lib/core/network/api_constants.dart]]
