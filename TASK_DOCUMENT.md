# ReadBuddy Bug Fix Task Document

## Branch: `fix/ui-bugs-and-features`

---

## Tasks Overview

| # | Task | Severity | Status |
|---|------|----------|--------|
| 1 | Profile page dark mode support | Medium | ⬜ TODO |
| 2 | Profile elements visibility in dark mode | Medium | ⬜ TODO |
| 3 | Category module dark mode support | Medium | ⬜ TODO |
| 4 | Change Password navigation fix | High | ⬜ TODO |
| 5 | Dashboard pending requests count not updating | High | ⬜ TODO |
| 6 | Dashboard pickups today count not updating | High | ⬜ TODO |
| 7 | Dashboard delivered this week count not updating | High | ⬜ TODO |
| 8 | Search functionality not working | High | ⬜ TODO |
| 9 | Onboarding screen orientation/overflow issue | Medium | ⬜ TODO |
| 10 | Google Sign-In button missing on login screen | Low | ⬜ TODO |

---

## Execution Plan

### Phase 1: High Severity (Critical Fixes)

#### Task 4: Change Password Navigation
- **File:** `lib/features/settings/settings_screen.dart`
- **Issue:** Tapping "Change Password" does nothing
- **Fix:** Add proper navigation to a Change Password screen or route
- **Validate:** Tap button → screen opens

#### Task 5/6/7: Dashboard Stats Not Updating
- **Files:** Admin dashboard screen, librarian dashboard, related BLoC
- **Issue:** Pending requests, pickups today, delivered this week counts don't refresh
- **Fix:** Ensure dashboard reloads data after returning from actions (accept/reject/deliver)
- **Validate:** Perform action → return to dashboard → counts update

#### Task 8: Search Not Working
- **Files:** `lib/features/search/presentation/screens/search_screen.dart`, related data source
- **Issue:** Search shows no results
- **Fix:** Verify API integration, check query params, fix filtering logic
- **Validate:** Type query → results appear

### Phase 2: Medium Severity (Theme & UI)

#### Task 1/2: Profile Dark Mode
- **Files:** `lib/features/profile/presentation/pages/screen/profile_screen.dart`
- **Issue:** Profile doesn't adapt to dark theme
- **Fix:** Use `Theme.of(context)` colors instead of hardcoded colors
- **Validate:** Enable dark mode → profile renders correctly

#### Task 3: Category Dark Mode
- **Files:** `lib/features/home/presentation/widgets/category_tab.dart`
- **Issue:** Category module stays light in dark mode
- **Fix:** Replace hardcoded background/text colors with theme-aware colors
- **Validate:** Enable dark mode → category screen adapts

#### Task 9: Onboarding Landscape Overflow
- **Files:** `lib/features/onboarding/onboarding_screens.dart`, `onboarding_widget.dart`
- **Issue:** ~150px bottom overflow in landscape
- **Fix:** Wrap in SingleChildScrollView or make layout responsive
- **Validate:** Rotate device → no overflow, options selectable

### Phase 3: Low Severity

#### Task 10: Google Sign-In Button
- **Files:** `lib/features/auth/presentation/pages/sign_in_page.dart`
- **Issue:** Google Sign-In button not visible
- **Fix:** Ensure the Google Sign-In button widget is rendered (may have been removed/hidden)
- **Validate:** Login screen shows Google button, tapping initiates OAuth flow

---

## Workflow Per Task

1. **Analyze** — Read relevant files, understand current code
2. **Implement** — Make the fix
3. **Validate** — Run `flutter analyze`, check for errors
4. **Lint** — Ensure zero issues
5. **Build** — `flutter build apk --debug`
6. **Next task** — Move to next item

---

## Final Checklist

- [ ] All 10 tasks completed
- [ ] `flutter analyze` → 0 issues
- [ ] `flutter build apk --debug` → success
- [ ] All changes committed to `fix/ui-bugs-and-features`
- [ ] Push to remote
