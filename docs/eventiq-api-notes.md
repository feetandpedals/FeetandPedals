# Eventiq API — notes from the official docs + live verification

Distilled from the `documentation_v2.1.zip` package (Eventiq's own docs site)
supplied for this project, and cross-checked live against
`https://feetandpedals.com` itself. Where the two disagree, live evidence
wins — this file says which source each fact rests on.

## Base URL — confirmed live

`https://feetandpedals.com` is the base URL, confirmed two ways:

1. `app_installation.html`: "Use your admin URL as the base URL... if your
   admin URL is `https://your_domain.com/admin` then the base URL is
   `https://your_domain.com`" — the admin panel is at
   `feetandpedals.com/admin`.
2. **Live-verified**: `curl https://feetandpedals.com/api/categories`
   returned a real `200` with real category data (see below). This is the
   default in `lib/core/config/env.dart` now.

```bash
flutter run --dart-define=API_BASE_URL=https://feetandpedals.com --dart-define=USE_MOCK_DATA=false
```

## Live-verified: `GET /api/categories`

```
curl -i https://feetandpedals.com/api/categories
```
returned real data — 10 categories: Running, Cycling, Swimming, Hiking,
Trekking, Triathlon, "Trail running / Ultra", Nature Walks, Duathlon,
Swimathon (their real ids are now in `lib/data/mock/mock_data.dart`).

**Important correction to the docs**: the response is a **standard Laravel
paginator directly under `data`** —
`{status, message, data: {current_page, data: [...], first_page_url, ...}}`
— matching the *reference app's* assumption, **not** the generic docs'
bare-array example (`data: [...]`). Fields on each category (`id`, `name`,
`image`, `image_url`) do match both sources.

This casts doubt on the generic docs' custom envelope for `/api/events`
(`data.events` + `data.pagination`) and `/api/event/details/{id}`
(`data.event`) too — those are unverified for this specific deployment.
`lib/data/repositories/event_repository.dart` now tries the standard-
paginator shape first and falls back to the documented shape, but **this
still needs a live check**:

```bash
curl -i https://feetandpedals.com/api/events
curl -i "https://feetandpedals.com/api/event/details/<a-real-event-id-from-the-events-response>"
curl -i https://feetandpedals.com/api/gateways
```
If you (or whoever has terminal access to the box) can run these three and
paste the output back, I can drop the guessing entirely.

## Auth

Laravel Sanctum, bearer tokens. `POST /api/login` / `POST /api/registration`
return `{ status, data: { user, token, token_type }, message }`. Tokens are
stored in `personal_access_tokens` and revoked on logout.

**`/api/social-login` does not exist in stock Eventiq** — confirmed absent
from the documented endpoint list. This needs to be built for Google/
Facebook/Apple sign-in to work against the real backend (see the app's
`auth_repository.dart` comment for the expected request/response shape).

## Response envelope shapes (important — this is where the reference app's
## source and the official docs disagree, and the docs win)

- `GET /api/events` → `data.events` (array) + `data.pagination` + `data.filters`
  — **not** a bare Laravel paginator directly under `data`, despite what the
  reference app's `PaginatedResponse` model would suggest.
- `GET /api/event/details/{id}` → `data.event` (nested), not `data` itself.
- `GET /api/user` → `data.user` (nested).
- `POST /api/event-ticket/purchase/{event}` → `data` is the purchase object
  directly (`id`, `trx`, `status`, `final_amount`, ...) — the purchase `id`
  is not wrapped as `purchase_id`.
- Event location: the documented shape is a single flat `address` string,
  not the nested `{city, state, country, ...}` object the reference app's
  `Location` model uses. The app now accepts either.
- Event favorite flag: documented as `is_favorited`; the reference app uses
  `is_favorite`. The app accepts either.

`lib/data/repositories/event_repository.dart` and `checkout_repository.dart`
now parse the documented shapes.

## Payment gateways — corrected

Eventiq ships **PayPal, Stripe, SSLCommerz, Flutterwave, Paystack, and Bank
(manual)** (`payment-gateways.html`) — not India-specific rails like UPI/
Net Banking/GrabPay, which the app's mock data wrongly assumed earlier.
`GET /api/gateways` returns whichever of these the admin has enabled and
configured with live credentials. Manual "Bank" payments are admin-approved
after the customer submits a transaction reference — there's no instant
confirmation for that one.

Per `payment-gateways.html`: "Eventiq validates payments using the gateway
response/return flow. No webhook configuration is required for the
built-in gateways" — this is worth flagging against the MVP1 scope doc's
webhook-based payment architecture (section 6); confirm with the backend
team which model this specific deployment actually uses.

## Participant details — likely needs a backend addition

The documented `POST /api/event-ticket/purchase/{event}` payload is just
`{ selected_date, tickets: [{id, name, price, quantity}], total_amount }` —
no attendee name/DOB/gender/emergency-contact fields. Stock Eventiq
ticketing doesn't appear to persist per-participant race-entry data. Since
the MVP1 scope doc explicitly requires a "Registration / Participant
Details" screen, this is either a Feet and Pedals-specific customization
already on the backend, or something that still needs to be added — worth
confirming directly. The app sends a `participant` object alongside the
documented fields either way, so it's captured if the backend supports it.

## Not yet reconciled / still to verify against the live API

- Exact `checkout-confirmation` request/response shape (not covered in the
  docs bundle — currently based on the reference app's source only).
- Whether `category` (documented query param) expects a category id or a
  slug/name.
- Full notification/volunteer/organizer-follow endpoints exist in the docs
  but are out of MVP1 scope per the tech doc, so aren't wired up.
