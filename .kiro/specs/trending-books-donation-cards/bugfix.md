# Bugfix Requirements Document

## Introduction

This document addresses a bug where trending books are not being displayed in donation cards for non-prime members. Currently, non-prime users see only a static donation card with text encouraging book donation, but they should also have visibility into popular trending books available in the platform. This affects the user experience for non-prime members who should be able to discover popular books even without prime membership.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a non-prime user views the home screen THEN the system displays only a static donation card without any trending books

1.2 WHEN trending books are fetched from the API THEN the system stores them in HomeLoaded state but does not display them in the donation card for non-prime users

1.3 WHEN a non-prime user looks at the donation card THEN the system shows only "Support a Reader" text and "Donate a book and make a difference" description without any book recommendations

### Expected Behavior (Correct)

2.1 WHEN a non-prime user views the home screen THEN the system SHALL display trending books within or alongside the donation card

2.2 WHEN trending books are fetched from the API THEN the system SHALL display them prominently in the donation card area for non-prime users

2.3 WHEN a non-prime user looks at the donation card THEN the system SHALL show both the donation call-to-action AND trending books to encourage engagement

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a prime user views the home screen THEN the system SHALL CONTINUE TO display the banner carousel instead of donation cards

3.2 WHEN trending books are fetched THEN the system SHALL CONTINUE TO store them in the HomeLoaded state for all users

3.3 WHEN the donation button is tapped THEN the system SHALL CONTINUE TO navigate to the donation flow

3.4 WHEN trending books are displayed in other sections THEN the system SHALL CONTINUE TO show them in the existing "Latest" and "Recommended" sections

3.5 WHEN the API fails to fetch trending books THEN the system SHALL CONTINUE TO show the donation card without crashing