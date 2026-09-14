# Shared debug keystore

`debug.keystore` in this folder is a checked-in, **debug-only** Android
signing keystore, wired up in `android/app/build.gradle.kts` so every dev
machine and CI build produces the same debug-signed APK — which matters
because its certificate fingerprint is what Google Sign-In and Facebook
Login check against.

- **Not secret**: password/alias/key-password are all the Android-standard
  debug defaults (`android` / `androiddebugkey` / `android`). This is the
  normal, expected way to handle a *debug* keystore — never do this for a
  release/Play Store signing key.
- **Fingerprints** (for registering with Google Cloud Console and Meta for
  Developers — see the app's README for exactly where each goes):

  ```
  SHA-1:   AF:70:E7:D4:E9:03:BD:08:BF:73:DA:34:24:B2:1A:2A:51:1A:54:02
  SHA-256: 69:91:81:8E:11:71:7A:2A:FB:A9:9E:49:E1:E4:CE:BB:D1:DF:E4:0F:9E:D9:99:59:18:C2:B2:71:1A:0D:D9:32
  Facebook Key Hash (base64): r3Dn1OkDvQi/c9o0JLIaKlEaVAI=
  ```

- Regenerate any time with:
  ```bash
  keytool -genkey -v -keystore debug.keystore -storetype JKS \
    -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
  ```
  (if you do, the SHA-1/Key Hash above change and must be re-registered
  with Google/Facebook).

## Release signing — not set up yet

`buildTypes.release` in `build.gradle.kts` currently signs release builds
with this same debug keystore so `flutter build apk --release` works out
of the box. **Do not ship a Play Store build signed this way.** Before a
real release:

1. Generate a real release keystore (kept private, never committed):
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias upload
   ```
2. Add `android/key.properties` (already gitignored) pointing to it.
3. Update `signingConfigs`/`buildTypes.release` in `build.gradle.kts` to
   use it instead of the debug config.
4. Register *that* keystore's SHA-1 with Google/Facebook too (apps
   typically register both debug and release fingerprints).
