# Feet and Pedals® — Mobile App (MVP1)

A Flutter app (Android + iOS, one codebase) for the Feet and Pedals®
sports-event ticketing platform: discover events, register, pay, and hold
your ticket with its QR code.

This is MVP1 as scoped in `Feet_and_Pedals_MVP1_Mobile_App_Technology_and_Scope.md`:
a focused ticketing experience (**Discover → Register → Pay → Ticket**), not
the long-term athlete ecosystem.

## Status

- UI/UX: fully built for every MVP1 screen (splash, login/signup with
  social login, home, event listing + search/filters, event details,
  4-step registration, payment, payment result, my tickets + QR, ticket
  detail, profile, edit profile, notifications, settings).
- Data layer: a clean repository interface per domain (`lib/data/repositories`)
  with two implementations each — a **mock** implementation (in-memory,
  India/INR sample data) and an **API** implementation that calls the real
  Laravel/Eventiq REST endpoints. The UI only ever talks to the interface,
  so flipping from mock to live data is a config change, not a rewrite.
- The API endpoint paths in `lib/core/network/api_endpoints.dart` mirror the
  contract already implemented by the Eventiq reference Flutter app 1:1
  (see "Where the API contract came from" below). **Not yet connected to
  the real feetandpedals.com backend** — see "What's needed to go live".

## Getting started

```bash
flutter pub get
flutter run                 # runs against mock data by default
```

To point at the real API instead of mock data:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://<real-api-host> \
  --dart-define=USE_MOCK_DATA=false
```

(`lib/core/config/env.dart` documents both flags.)

## Architecture

```
lib/
  core/            # theme, router, network client, storage, social auth, formatters
  models/          # plain Dart models, tolerant fromJson matching the Laravel/Eventiq contract
  data/
    mock/          # in-memory sample catalog (India cities, INR pricing)
    repositories/  # one interface + Mock/Api implementation per domain
  state/           # Riverpod providers/controllers (auth, events, cart/checkout, tickets, notifications)
  features/        # one folder per screen, grouped by flow
  widgets/         # shared UI (event card, brand mark, social login buttons, states)
```

State management: **Riverpod**. Routing: **go_router**, with an auth
redirect guard so unauthenticated users always land on `/login` and
authenticated users skip straight past it. Networking: **Dio**, with the
auth token attached automatically via `TokenStorage` (flutter_secure_storage
— platform keychain/keystore).

## Where the API contract came from

Feet and Pedals' backend runs the existing Laravel/Eventiq platform.
`lib/core/network/api_endpoints.dart` and every model's `fromJson` are
built against **two** sources, cross-checked against each other:

1. The **Eventiq reference Flutter app**'s source (`AppStrings`, its model
   classes) — endpoint paths.
2. Eventiq's own **official API documentation** (`documentation_v2.1.zip`)
   — response envelope shapes, which occasionally disagree with what the
   reference app's models assume. The docs won those disagreements; see
   `docs/eventiq-api-notes.md` for the specifics (event list/detail
   envelope nesting, favorite-flag field name, location shape, purchase-id
   field, the real payment gateway list).

The UI itself is a complete redesign per the scope doc's brand/UX
direction (red/black/white, no Eventiq visual DNA carried over).

## What's needed to go live

This sandbox can't reach `feetandpedals.com` directly — its network egress
is allow-listed by the organization and that domain isn't on it (confirmed:
requests are actively rejected, not just timing out), and raw SSH is
blocked the same way — so the following still need to come from the Feet
and Pedals team or be verified by someone who can reach the site directly.

1. ~~Confirm the base URL~~ **Done** — the admin panel is at
   `feetandpedals.com/admin`, so `API_BASE_URL` now defaults to
   `https://feetandpedals.com` in `lib/core/config/env.dart` (per Eventiq's
   own install docs: base URL = admin URL with `/admin` dropped). This
   hasn't been verified reachable from this sandbox — worth a sanity check
   (e.g. `curl https://feetandpedals.com/api/categories`, a public,
   unauthenticated endpoint) from a machine that isn't network-restricted.
2. **A test account** on that backend (or confirm registration is open) so
   I can validate login → register → pay → ticket end-to-end against real
   data, not just the mock layer.
3. **Confirm/build `/social-login`** — this endpoint doesn't exist in
   stock Eventiq (confirmed via the docs). See `docs/eventiq-api-notes.md`
   for the expected request/response shape to hand to the backend dev.
4. **Confirm the open questions in `docs/eventiq-api-notes.md`** —
   mainly the exact `checkout-confirmation` shape and whether participant
   details (name/DOB/gender/emergency contact) are actually persisted
   anywhere on the backend today.
5. **Social login credentials** (unrelated to feetandpedals.com access —
   these come from each provider's own console):
   - Google: OAuth client IDs for Android (with the app's release/debug
     SHA-1 registered) and iOS, dropped into
     `android/app/google-services.json` and `ios/Runner/Info.plist`
     (`GIDClientID` + URL scheme — see the commented block already in
     `Info.plist`).
   - Facebook: App ID + Client Token, into
     `android/app/src/main/res/values/strings.xml` (referenced from the
     commented `<meta-data>` block in `AndroidManifest.xml`) and the
     commented block in `Info.plist`.
   - Apple: enable the "Sign in with Apple" capability in the Xcode
     project (iOS only — Android doesn't need it).
6. **Which payment gateways are actually enabled** — Eventiq supports
   PayPal, Stripe, SSLCommerz, Flutterwave, Paystack, and manual Bank
   transfer (not India-specific rails like UPI — the mock data's earlier
   guess there was wrong and has been corrected). `GET /api/gateways`
   will tell the app which are live; no gateway API keys need to reach the
   mobile app itself.

Everything else — every screen, the whole data layer, the social-login UI
and SDK wiring — is already built and works today against the mock layer.

## Social login

Google and Facebook sign-in are available on **both** Android and iOS.
Apple Sign-In is offered on **iOS only** (`SocialLoginButtons` hides it on
Android — Apple doesn't require or expect it there). See
`lib/core/services/social_auth_service.dart` for the SDK wrapper and the
setup notes above for the platform credentials each provider needs.

## Building

```bash
flutter build apk --release     # Android
flutter build ios --release     # iOS (requires Xcode, macOS)
```

Building an iOS `.ipa` requires Xcode on macOS and cannot be done from this
Linux sandbox; the `ios/` project is fully scaffolded and ready to open in
Xcode. Producing a signed Android APK also requires the Android SDK, which
isn't installed in this sandbox (the code has been validated with
`flutter analyze` and `flutter test`, both passing).
