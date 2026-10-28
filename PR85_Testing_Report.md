# Testing Report - PR #85

**Date:** 2026-10-27  
**Tester:** Deborah Thomas  
**PR:** #85 - Return/Pickup Payment Flow Fixes  
**Branch Tested:** READBUDDY-2-book-return-flow-rebuild  

## Summary

Tested the changes from PR #85 on both return pickup and borrow payment flows. The Test Pay flow has been made to work (bypassing Razorpay checkout as intended), but **actual Razorpay payments are still failing with authentication errors** in both tested flows.

## Test Results

### 1. Return Book → Pickup from Home → ₹25 Payment
| Test Case | Result | Notes |
|---|---|---|
| Test Pay (bypass flow) | ✅ Working | Successfully completes without opening Razorpay checkout |
| Actual Razorpay Payment | ❌ Failed | Error: "Failed to start payment: Exception: Authentication failed." |

**Steps Reproduced:**
1. Open the Readbuddy mobile app
2. Navigate to My Requests → Select eligible book for return
3. Choose "Pickup from Home"
4. Proceed to ₹25 payment screen
5. Tap actual payment button → Authentication failed
6. Tap Test Pay → Works successfully

### 2. Borrow Book → Payment
| Test Case | Result | Notes |
|---|---|---|
| Test Pay (if available) | ⚠️ Not Working / Not Available | As reported, Test Pay is not working for the borrow flow |
| Actual Razorpay Payment | ❌ Failed | Error: "Failed to start payment: Exception: Authentication failed." |

**Steps Reproduced:**
1. Open the Readbuddy mobile app
2. Initiate a borrow request for a book that requires payment
3. Proceed to payment screen
4. Tap payment button → Authentication failed

## Root Cause Analysis

The error "Authentication failed" is thrown directly by the Razorpay Checkout SDK. This occurs when the `key_id` passed to `Razorpay.open()` does not belong to the same Razorpay account that created the `order_id`. 

On the Flutter side:
- The app is correctly using the `razorpayKey` returned by the `create-order` API (as implemented per PR #85 requirements)
- The app no longer uses hardcoded keys
- Key validation is in place

This indicates the issue is with the **backend Razorpay configuration and order creation**.

## Action Required (Backend)

Please verify and correct the following:

1. **Key Pair Consistency** - Ensure `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` belong to the same Razorpay account and are in the same mode (both Test or both Live)
2. **Order Creation** - Confirm the order creation API uses the same key pair as what's in `RAZORPAY_KEY_ID`
3. **Key Match** - Verify the `razorpayKey` returned by the create-order endpoint matches the credentials used to create that specific order_id

## Recommendation

The backend needs to fix the Razorpay key/secret pair configuration. Once corrected, both payment flows should authenticate successfully and open the Razorpay gateway as expected.

**Status:** Blocked - Awaiting backend configuration fix
