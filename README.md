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

Feet and Pedals' backend runs the existing Laravel/Eventiq platform. To
avoid guessing endpoint shapes, `lib/core/network/api_endpoints.dart` and
every model's `fromJson` were reverse-engineered from the **Eventiq
reference Flutter app** supplied for this purpose (see the scope doc,
section 3) — its `AppStrings` endpoint list and model classes are mirrored
exactly (`/api/login`, `/api/events`, `/api/event/details/{id}`,
`/api/event-ticket/purchase/{id}`, `/api/checkout-confirmation`,
`/api/my-tickets`, etc.), while the UI itself is a complete redesign per
the scope doc's brand/UX direction (red/black/white, no Eventiq visual
DNA carried over).

## What's needed to go live

This sandbox can't reach `feetandpedals.com` directly (network egress is
allow-listed, and raw SSH is blocked too), so the following still need to
come from the Feet and Pedals team:

1. **Real API base URL** for `--dart-define=API_BASE_URL=...` above.
2. **Confirmation the endpoint contract matches** what's in
   `api_endpoints.dart`, or a list of where the real backend differs —
   this is the "API audit" the scope doc calls for in section 10. In
   particular `/social-login` is not part of the Eventiq reference app and
   is marked as **missing, needs to be built** in `auth_repository.dart`.
3. **A test account** on the real backend to validate login → register →
   pay → ticket end-to-end.
4. **Social login credentials** (unrelated to feetandpedals.com access —
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
5. **Payment gateway config** — MVP1 assumes the mobile app never marks an
   order paid itself; Laravel confirms it server-side via the gateway's
   webhook (scope doc, section 6). No client-side payment SDK keys should
   be needed beyond what `/gateways` already returns.

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
