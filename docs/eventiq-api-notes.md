# Eventiq API — notes from the official docs + live verification

Distilled from the `documentation_v2.1.zip` package (Eventiq's own docs
site) supplied for this project, and cross-checked live against
`https://feetandpedals.com` itself via `curl` (run from a terminal with
real access — this sandbox's network egress doesn't reach the domain).
Where the generic docs and live responses disagree, live evidence wins —
this file says which source each fact rests on.

## Base URL — confirmed live

`https://feetandpedals.com`. Confirmed two ways: the admin panel is at
`feetandpedals.com/admin` (per the install docs, base URL = admin URL
minus `/admin`), and `curl https://feetandpedals.com/api/categories`
returned a real `200` with real data. This is the default in
`lib/core/config/env.dart`.

```bash
flutter run --dart-define=API_BASE_URL=https://feetandpedals.com --dart-define=USE_MOCK_DATA=false
```

## Confirmed live: `GET /api/categories` and `GET /api/events`

Both return a **standard Laravel paginator directly under `data`** —
`{status, message, data: {current_page, data: [...], first_page_url, ...}}`
— matching the *reference app's* assumption, not the generic docs'
`data.events[]`/bare-array examples. `event_repository.dart` parses this
shape (with an unreachable documented-shape fallback kept only for
safety).

10 real categories: Running, Cycling, Swimming, Hiking, Trekking,
Triathlon, "Trail running / Ultra", Nature Walks, Duathlon, Swimathon —
their real ids are in `lib/data/mock/mock_data.dart`.

Real event fields (from a live `/api/events` response): `id`, `name`,
`banner`, `start_date`, `end_date`, `location` (nested object — matches
the reference app, not the docs' flat `address` string), `starting_price`,
`is_favorite` (not `is_favorited`), `event_share_url`.

**Date format caught by this check**: `start_date`/`end_date` come back as
`"Sep 30, 2026"` (`MMM d, yyyy`), **not ISO 8601**. `core/utils/formatters.dart`'s
`parseApiDate()` now tries both formats — used everywhere a model exposes
a `DateTime?` getter from an API date string.

**Location fields observed all-null except `address`**: `country`,
`state`, `city`, `city_id`, `place_id`, `city_name`, `latitude`,
`longitude` were `null` on every event in the sample; only `address` (a
free-text string, e.g. `"Chanakyapuri, New Delhi"`) was populated. So in
practice `EventLocation.displayLine` currently falls through to `address`
for every real event — worth confirming this isn't sample-specific.

## Confirmed live: `GET /api/gateways`

```json
{"status":true,"message":"All Gateways","data":[{"id":"01m234gt1dqs788xbwh3bkv4ma","name":"Razorpay","image":null,"gateway_type":"autometic","image_url":"..."}]}
```

Flat array directly under `data` (no paginator) — matches what
`checkout_repository.dart` already expected. **This deployment has exactly
one gateway enabled: Razorpay** (`gateway_type: "autometic"`, sic — a typo
in their own data for "automatic", i.e. API-integrated rather than manual/
bank-transfer). This strongly reinforces the India/₹ market: Razorpay
bundles UPI, cards, and net banking behind one checkout. The generic docs'
PayPal/Stripe/SSLCommerz/Flutterwave/Paystack/Bank list describes what
Eventiq *supports*, not what's live here — corrected the mock payment
option to just Razorpay.

## Not yet confirmed: `GET /api/event/details/{id}`

One attempt returned a 404, but the request used the literal placeholder
text instead of a real event id — inconclusive. Retry with a real id from
the `/api/events` response above, e.g.:

```bash
curl -i https://feetandpedals.com/api/event/details/01m1zp7vgjhyqkmc4apf7m7s2t
```

Until this is confirmed, `event_repository.dart`'s `fetchEventDetails`
tries the flat shape first (`data` *is* the event, matching the
reference-app/categories/events pattern) and falls back to the documented
`data.event` nesting.

## Auth (docs only, not yet live-verified — no credentials to test with)

Laravel Sanctum, bearer tokens. `POST /api/login` / `POST /api/registration`
documented to return `{ status, data: { user, token, token_type }, message }`.

**`/api/social-login` does not exist in stock Eventiq** — confirmed absent
from the documented endpoint list. Needs to be built for Google/Facebook/
Apple sign-in to work against the real backend (see `auth_repository.dart`
for the expected request/response shape).

## Participant details — likely needs a backend addition

The documented `POST /api/event-ticket/purchase/{event}` payload is just
`{ selected_date, tickets: [{id, name, price, quantity}], total_amount }` —
no attendee name/DOB/gender/emergency-contact fields, and stock Eventiq
ticketing doesn't appear to persist per-participant race-entry data. Since
the MVP1 scope doc explicitly requires a "Registration / Participant
Details" screen, this is either a Feet and Pedals-specific backend
addition already in place, or something that still needs building — worth
confirming directly with the backend dev. The app sends a `participant`
object alongside the documented fields either way, so it's captured if
the backend supports it.

## Still to verify live

- `GET /api/event/details/{id}` with a real id (see above).
- Exact `checkout-confirmation` request/response shape (not in the docs
  bundle — currently based on the reference app's source only; would need
  a real login + a real purchase to observe, so needs a test account).
- Whether `category` (the documented `/api/events` query param) expects a
  category id or a slug/name — only matters once category filtering is
  tested live.
- Auth response shape (needs a test account).
