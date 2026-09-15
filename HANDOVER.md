# Feet and Pedals MVP1 — Handover

Written 2026-09-15 to hand this project off from a Claude Code **cloud**
session to a **local** one. Read this first, then `README.md` (setup/build
instructions) and `docs/eventiq-api-notes.md` (API contract details) for
the rest.

## What this is

A Flutter app (Android + iOS, one codebase) for feetandpedals.com's event
ticketing — built from scratch per
`Feet_and_Pedals_MVP1_Mobile_App_Technology_and_Scope.md` (the scope doc,
in repo root). Scope is intentionally just **Discover → Register → Pay →
Ticket**, not the long-term athlete-ecosystem vision.

**Repo:** `feetandpedals/FeetandPedals` on GitHub
**Branch:** `claude/feetandpedals-mobile-app-hipeun` — everything described
here is committed and pushed there.

## Status in one line

UI/UX and data layer are fully built and pass `flutter analyze`/`flutter
test` cleanly. The app runs today against realistic mock data (`flutter
run`, no flags needed). It is **not yet wired to the live backend** —
that's the main remaining work, and most of what's blocking it is
listed below.

## Why a cloud session couldn't finish this alone

Two hard environment limits kept recurring — worth knowing so the local
session doesn't waste time rediscovering them:

1. **No outbound network to feetandpedals.com** from the cloud sandbox
   (org egress allowlist) — not even SSH. All live-API verification in
   this project happened by handing the user `curl` commands to run in
   their own SSH session (`ssh feetandpedals.com@ssh-node-gb...`) and
   pasting results back.
2. **No Android SDK / emulator** in the cloud sandbox, and `dl.google.com`
   (where the SDK installer lives) is also blocked — so no APK could be
   built or run there. All Flutter tooling verification there was limited
   to `flutter analyze` / `flutter test` (both pass) plus a Dart-level
   spot-check of specific functions (date parsing, HTML stripping).

None of that applies to a local session — it should have normal network
and, per the user, Android Studio + Flutter SDK are already installed
locally. A real device/emulator test hasn't happened yet as of this
handover; that's the immediate next step.

## Tech stack

- **Flutter**, single codebase for Android + iOS (per the scope doc's
  explicit decision — see section 2 there).
- **Riverpod** for state management, **go_router** for navigation (with
  an auth redirect guard).
- **Dio** for networking, **flutter_secure_storage** for the auth token.
- **google_sign_in**, **flutter_facebook_auth**, **sign_in_with_apple**
  for social login (Apple is iOS-only in the UI; Google/Facebook on both
  platforms).
- **qr_flutter** for ticket QR codes.

## Architecture

```
lib/
  core/            # theme, router, network client, storage, social auth, formatters (incl. parseApiDate, stripHtml)
  models/          # plain Dart models, tolerant fromJson matching the live/documented Eventiq contract
  data/
    mock/          # in-memory sample catalog — REAL data pulled live from the API, not invented (see below)
    repositories/  # one interface + Mock/Api implementation per domain (auth, events, checkout, tickets, notifications)
  state/           # Riverpod providers/controllers
  features/        # one folder per screen, grouped by flow
  widgets/         # shared UI
```

Every domain has a `Mock*Repository` and an `Api*Repository` behind one
interface (`lib/data/repositories/`). The UI never touches either
directly — it's all through Riverpod providers in `lib/state/`. Switching
from mock to live is a `--dart-define` flag, not a rewrite:

```bash
flutter run --dart-define=API_BASE_URL=https://feetandpedals.com --dart-define=USE_MOCK_DATA=false
```

Default (`flutter run` with no flags) uses mock data — this is what's
been tested (via `flutter analyze`/`flutter test`) so far.

## What's built (every MVP1 screen)

Splash, login/signup (email + Google/Facebook/Apple social buttons),
forgot password, home (greeting, category row, featured events), event
listing (search + category filter chips), event details (Overview/
Categories/Location/FAQ tabs), 4-step registration (Participant/Category/
Add-ons/Review), payment (gateway list + Pay Now), payment result, my
tickets (Upcoming/Past + QR code), ticket detail, profile, edit profile,
notifications (All/Updates/Promotions), settings.

Brand: red/black/white per the approved mockup, "FEET AND PEDALS"
wordmark with a mountain glyph.

## API integration — what's confirmed live vs. still assumed

This is the single most important section for whoever continues this.
Full detail in `docs/eventiq-api-notes.md` — here's the summary.

**Confirmed live** (via real `curl` against `https://feetandpedals.com`,
run by the user, not from this session):
- Base URL is `https://feetandpedals.com` (already the default in
  `lib/core/config/env.dart`).
- `GET /api/categories` — 10 real categories, real ids now in
  `lib/data/mock/mock_data.dart`.
- `GET /api/events` — real event list; response is a **standard Laravel
  paginator** under `data` (`data.data[]`), not the generic Eventiq docs'
  `data.events[]` shape.
- `GET /api/event/details/{id}` — `data` **is** the event object directly
  (not nested under `data.event`). Caught two real bugs from this:
  - `details` is rich WYSIWYG HTML, not plain text — added
    `stripHtml()`/`EventDetails.detailsPlainText`.
  - A ticket type's `number_of_tickets` is **total inventory** (150–2,500
    in the sample), not a per-order limit — the registration screen was
    using it as one. Fixed to use the event's real `ticket_max_buy`.
- `GET /api/gateways` — **this deployment has exactly one payment gateway
  enabled: Razorpay** (not the generic docs' PayPal/Stripe/SSLCommerz
  list). Confirms the India/₹ market strongly (Razorpay bundles UPI/
  cards/netbanking).
- 5 real live events are now the mock catalog (HindAyan Cycle Parade,
  Chalo Bharat Walkathon, CANNONBALL GURUGRAM, Almora & Kausani, Harvest
  Gold Global Race) with real ids, prices, ticket types, categories, and
  the real organizer ("Nisha jain") — this doubles as a regression
  fixture once wired to live data.

**Still needs a test account to confirm** (given, see below, but not yet
exercised against these endpoints):
- Exact `POST /api/login` / `POST /api/registration` response shape.
- `GET /api/user`, `GET /api/my-tickets` shapes.
- `POST /api/event-ticket/purchase/{event}` and
  `POST /api/checkout-confirmation` — the actual purchase flow. This is
  the biggest remaining unknown; a script for testing it end-to-end
  (login → profile → tickets → attempt a real ₹10 purchase) was handed to
  the user to run but results haven't come back yet as of this handover.
- Whether participant details (name/DOB/gender/emergency contact,
  collected by the Registration screen) are actually persisted anywhere
  server-side — the documented purchase payload has no fields for them.

**Confirmed NOT to exist yet:** `/api/social-login` — needs to be built
on the backend for Google/Facebook/Apple sign-in to produce a real Feet
and Pedals session. Request/response shape the app expects is documented
in `lib/data/repositories/auth_repository.dart`.

**Test credentials received** (from the user, for the real backend):
```
email: test@testuser.com
password: 12345678
```
A ready-to-run verification script (login → extract token → hit
`/api/user`, `/api/my-tickets`, attempt a purchase) is in the chat history
around the message where these credentials were shared — reconstruct it
from `docs/eventiq-api-notes.md`'s "still to verify" list if needed, or
just run the app against the live API directly now that a test account
exists.

## App identity & signing

- Package name / bundle ID: **`com.feetandpedals.app`** (renamed from the
  Flutter-default `com.feetandpedals.feetandpedals` via
  `change_app_package_name`).
- A **shared debug keystore** is checked into `android/keys/debug.keystore`
  (standard non-secret debug credentials: `android`/`androiddebugkey`/
  `android`) and wired into `android/app/build.gradle.kts`, so every
  machine/CI produces the same debug-signing fingerprint:
  ```
  SHA-1:   AF:70:E7:D4:E9:03:BD:08:BF:73:DA:34:24:B2:1A:2A:51:1A:54:02
  Facebook Key Hash: r3Dn1OkDvQi/c9o0JLIaKlEaVAI=
  Default Activity Class Name (for Facebook): com.feetandpedals.app.MainActivity
  ```
  See `android/keys/README.md`. **Release signing is not set up** —
  release builds currently sign with this same debug keystore (fine for
  dev, not for a real Play Store release; see that README for the
  release-signing walkthrough when it's time).

## Social login setup — Android-first, iOS on hold

**User's explicit decision**: focus on Android testing first; iOS
credential setup (Apple Sign-In capability, Google/Facebook iOS OAuth
client registration, `Info.plist` wiring) is deliberately deferred, not
forgotten. Nothing in the code needs to change to pick that back up later
— Apple Sign-In already only shows on iOS in the UI.

**In progress as of this handover:**
- Facebook: user was mid-way through Android platform setup in Meta for
  Developers (package name, Default Activity Class Name, Key Hash all
  given above). Still needed from the user: **App ID** and **Client
  Token** (Settings → Basic / Settings → Advanced → Security) — those are
  the only two values that need to reach the codebase (into
  `AndroidManifest.xml`'s commented `<meta-data>` block and
  `android/app/src/main/res/values/strings.xml`, both already stubbed).
- Google: not yet started as of this handover. Needs an **Android** OAuth
  client (package name + the SHA-1 above — no value goes in code, just
  needs registering) and a **Web application** OAuth client (its Client
  ID becomes `serverClientId` so the Laravel backend can verify tokens —
  this one matters even for Android-only testing).

## Immediate next steps (in likely order)

1. **Get the app running on a local Android emulator/device** —
   `flutter run` from the repo root, mock data by default. This hasn't
   happened yet; do this first to catch any real-device issues before
   going further.
2. **Run the live-API verification script** with the test credentials
   above (see `docs/eventiq-api-notes.md`'s "still to verify" section for
   what to check) to nail down the login/purchase response shapes, then
   flip `USE_MOCK_DATA=false` and test against the real backend.
3. **Get Facebook App ID + Client Token**, and set up Google's Web +
   Android OAuth clients, to unblock social login testing on Android.
4. Confirm with the backend team: `/api/social-login` (needs building)
   and whether participant details are persisted anywhere.

## Key files to know

- `README.md` — setup/build instructions, full "what's needed to go
  live" checklist.
- `docs/eventiq-api-notes.md` — the API contract, what's confirmed live
  vs. assumed, with the reasoning behind every correction made along the
  way.
- `android/keys/README.md` — the debug keystore, fingerprints, and the
  release-signing TODO.
- `lib/core/config/env.dart` — the two build flags (`API_BASE_URL`,
  `USE_MOCK_DATA`) that control everything about mock-vs-live.
- `lib/data/mock/mock_data.dart` — the real live-pulled sample catalog.
