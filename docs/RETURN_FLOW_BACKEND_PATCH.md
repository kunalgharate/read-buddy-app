# Return Flow — Backend Patch (launch blockers)

Target file: `routes/UserRoutes.js` (backend repo deployed on Render:
`readbuddy-server-*`). Line numbers are from the current `master` and may have
drifted — locate handlers by route path, not by line.

The Flutter client is already written against the post-patch contract
(`lib/features/book_request/data/datasources/book_request_remote_datasource.dart`),
so **no further frontend changes are needed after these patches deploy**.

---

## Patch 1 — return `razorpayKey` + `currency` from pickup create-order

**Route:** `PATCH /users/return-requests/:id/pickup/payment/create-order`
(~line 2397)

**Problem:** the success response only returns `orderId` and `amount`. The
Flutter client cannot open Razorpay checkout without the public key, so the
₹25 home-pickup payment is completely blocked.

**Change:** find the success response — it is the object containing
`"Order generated successfully"` — and add two fields:

```js
// BEFORE
res.status(200).json({
  success: true,
  message: "Order generated successfully",
  orderId: order.id,
  amount: order.amount,
});

// AFTER
res.status(200).json({
  success: true,
  message: "Order generated successfully",
  orderId: order.id,
  amount: order.amount,
  razorpayKey: process.env.RAZORPAY_KEY_ID,
  currency: order.currency || "INR",
});
```

Rules:

- The key **must** be named `razorpayKey` exactly (the client also accepts
  `razorpay_key` / `key` as fallbacks — `keyId` is **not** read here).
- `RAZORPAY_KEY_ID` is public by design (the delivery-fee endpoint already
  returns it as `keyId` at `routes/BookRequestRoutes.js:1002`). Never expose
  `RAZORPAY_KEY_SECRET`.
- `amount` stays in paise (`order.amount`, e.g. `2500`) — client expects that.
- If `config/razorpay.js` exports the key, using that import instead of
  `process.env` directly is fine, as long as the value is the same key id that
  created the order.

**Expected response after patch:**

```json
{
  "success": true,
  "message": "Order generated successfully",
  "orderId": "order_xxxxx",
  "amount": 2500,
  "razorpayKey": "rzp_xxxxx",
  "currency": "INR"
}
```

---

## Patch 2 — accept + persist `returnScheduledDate` / `returnScheduledSlot`

**Route:** `PATCH /users/return-requests/:id/pickup/payment/verify-payment`
(~line 2532)

**Problem:** the client sends the chosen pickup schedule with the payment
verification, but the handler only reads
`{ paymentId, orderId, signature, pickupAddress }`, so the slot chosen by the
user is silently dropped and the detail page renders an empty
Scheduled Date / Time Slot.

**Change 2a — read the fields from the body** (schedule fields optional-but-
persisted-when-present; the client always sends both once a date/time is
picked, and the page validates they are non-empty before paying):

```js
const {
  paymentId,
  orderId,
  signature,
  pickupAddress,
  returnScheduledDate,
  returnScheduledSlot,
} = req.body;
```

If the handler validates required fields explicitly, keep
`paymentId/orderId/signature/pickupAddress` required and additionally reject
with 400 when `returnScheduledDate` is present but is not a valid ISO-8601 string
(e.g., validate against `/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?$/`), or when
`returnScheduledSlot` is present but empty.

**Change 2b — persist them in the existing `findOneAndUpdate` `$set`**
(the block at ~lines 2580–2593 that already sets `status`, `returnMethod`,
`returnPaymentStatus` and `returnPickupAddress`):

```js
$set: {
  status: "returning",
  returnMethod: 'PICKUP',
  returnPaymentStatus: 'PAID',
  returnPickupAddress: pickupAddress,          // already there
  ...(returnScheduledDate
    ? { returnScheduledDate: new Date(returnScheduledDate) }
    : {}),
  ...(returnScheduledSlot ? { returnScheduledSlot } : {}),
}
```

Notes:

- `returnScheduledDate` is stored as a `Date` (same shape `POST
  /v1/book-requests/:id/initiate-return` uses) — the client reads it back as
  an ISO string from `GET /v1/book-requests/my`.
- `returnScheduledSlot` is stored as the raw string, e.g. `"10:00 AM"`
  (same format initiate-return receives).
- Schema fields already exist (initiate-return writes them and `GET /my`
  returns them) — no model change required.
- If the handler assigns fields on a loaded doc instead of `$set`, add
  `bookRequest.returnScheduledDate` / `bookRequest.returnScheduledSlot`
  alongside the existing `returnPickupAddress` assignment before `save()`.

---

## Patch 3 (recommended) — make verify-payment idempotent

**Problem:** after one successful verify, a retry (e.g. the client lost the
response) hits the `status: 'delivered'` filter, matches nothing, and returns
400 — the user sees "Payment verification failed" even though the return is
already scheduled and paid.

**Change:** change the initial lookup to load by ID without the `status: 'delivered'` filter (e.g., `findById(req.params.requestId)`). Right after the book request is loaded, short-circuit if already paid, and otherwise apply the delivered-status precondition:

```js
if (!bookRequest) return res.status(404).json({ success: false, message: 'Not found' });

if (bookRequest.returnPaymentStatus === 'PAID') {
  // Already verified — persist any schedule that arrives on the retry,
  // then report success so client retries are safe.
  if (returnScheduledDate && !bookRequest.returnScheduledDate) {
    bookRequest.returnScheduledDate = new Date(returnScheduledDate);
  }
  if (returnScheduledSlot && !bookRequest.returnScheduledSlot) {
    bookRequest.returnScheduledSlot = returnScheduledSlot;
  }
  await bookRequest.save();
  return res.status(200).json({
    success: true,
    alreadyVerified: true,
    message: "Payment already verified",
    data: bookRequest,
  });
}

if (bookRequest.status !== 'delivered') {
  return res.status(400).json({ success: false, message: "Book must be delivered first" });
}
```

This mirrors `POST /v1/book-requests/:id/payment/verify`, which already
returns `{ success: true, alreadyVerified: true }` on retry.

---

## Verification (after deploy)

1. `PATCH /users/return-requests/{id}/pickup/payment/create-order`
   (auth, request in `delivered`) → response contains `razorpayKey` +
   `currency`, `amount` in paise.
2. Complete Razorpay checkout → `PATCH .../verify-payment` with
   `{ paymentId, orderId, signature, pickupAddress, returnScheduledDate, returnScheduledSlot }`
   → 200; then `GET /v1/book-requests/my` shows `status: "returning"`,
   `returnPaymentStatus: "PAID"`, `returnPickupAddress`, `returnScheduledDate`,
   `returnScheduledSlot`.
3. Repeat the same verify call → 200 with `alreadyVerified: true` (Patch 3).
4. Confirm Render env: `RAZORPAY_KEY_ID` and `RETURN_PAYMENT_AMOUNT="25"` are set.
5. Dev `Pay ₹25 (TEST)` button sends `signature: "demo_bypass"` — confirm this
   endpoint's signature check has a demo bypass for non-production envs,
   otherwise remove/keep hidden the TEST button
   (`collect_from_library_page.dart`, `_payReturnPickupTest`).

## Known gap not covered here

There is no Razorpay webhook: if the app is killed between checkout success
and the verify call, the payment stays pending and the user has no way to retry
the verification since the app loses the payment/order IDs in memory. A webhook route
(`express.raw()` + HMAC validation of `razorpay-signature`) is the durable
fix but is not required for launch.
