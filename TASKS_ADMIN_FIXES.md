# ReadBuddy — Admin & Book Management Bug Fixes

## Branch: `fix/admin-and-book-management`

---

## Tasks

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Admin Management: No option to remove/delete admin accounts | Enhancement | ⬜ TODO |
| 2 | Pickup Book Requests displayed in wrong section (All Requests instead of Pickups) | High | ⬜ TODO |
| 3 | User address not visible during book request approval/rejection | High | ⬜ TODO |
| 4 | Unable to Add or Update Books without restarting the app | High | ⬜ TODO |

---

## Task 1: Remove/Delete Admin Option

**Scenario:** Login as Admin → Open Admin Panel  
**Expected:** Option to remove/delete existing admin accounts  
**Actual:** No such option available  
**Severity:** Enhancement  

**Investigation:**
- Check `admin_users_page.dart` for existing user management actions
- Add a delete/remove admin action with confirmation dialog
- Call the appropriate API endpoint to remove admin role

---

## Task 2: Pickup Requests in Wrong Section

**Scenario:** Login as User → Submit Book Request (Pickup) → Login as Admin → Open Pickup Requests  
**Expected:** Pickup requests appear under the Pickups section  
**Actual:** Pickup requests appear under All Requests instead of Pickups  
**Severity:** High  

**Investigation:**
- Check how admin book requests page filters by fulfillment method
- Verify the request entity contains `fulfillmentMethod` field
- Fix the filter logic to separate pickup requests from all requests

---

## Task 3: User Address Not Visible During Approval

**Scenario:** Submit Home Delivery request → Login as Admin → Open request → Click Approve/Reject  
**Expected:** Admin can see user's delivery address  
**Actual:** Address is not displayed  
**Severity:** High  

**Investigation:**
- Check `admin_book_requests_page.dart` or request detail page
- Verify `BookRequestEntity` contains delivery address fields
- Display address info (name, phone, address, pincode) in the admin approval view

---

## Task 4: Add/Update Books Fails Without App Restart

**Scenario:** Login as Admin → Open Books → Click Add Book or Update Book  
**Expected:** Books can be added/updated successfully  
**Actual:** Error displayed; works only after closing and reopening app. Update doesn't work even after restart.  
**Severity:** High  

**Investigation:**
- Check `BookCrudBloc` state management for stale state issues
- Check if the BLoC is registered as `registerLazySingleton` (stale instance) vs `registerFactory`
- Verify the Add Book and Update Book API calls and error handling
- Likely issue: Singleton BLoC retains error state from previous operations

---

## Execution Order

1. **Task 4** — Add/Update Books (most critical, blocks admin workflow)
2. **Task 2** — Pickup Requests filter (data display bug)
3. **Task 3** — User address visibility (missing data in UI)
4. **Task 1** — Remove Admin option (enhancement)

## Workflow Per Task

1. Analyze — Read relevant files, identify root cause
2. Implement — Make the fix
3. Validate — Run `flutter analyze`, verify zero errors
4. Build — `flutter build apk --debug`
5. Commit — Stage and commit with descriptive message
6. Next task — Move to next item

## Final Checklist

- [ ] All 4 tasks completed
- [ ] `flutter analyze` → 0 issues
- [ ] `flutter build apk --debug` → success
- [ ] All changes committed
- [ ] Push to remote branch
