# ARROWW — Play Store Release Checklist

Prepared locally, before a Google Play Console account/app listing exists.
Everything below is grounded in the actual current implementation — nothing
here is aspirational or guessed.

For the finalized, copy-paste-ready store listing text (title, short
description, full description), see `docs/play_store_store_listing.md`.

## App identity

- **App name:** ARROWW
- **Package / application ID:** `com.arrowescape.game`
- **Current versionName:** 1.0.0
- **Current versionCode:** 1
- **Minimum SDK:** 24 (Android 7.0)
- **Target/compile SDK:** 36 (Android 16)

## Current release artifacts

Built and verified (upload-key signed, not debug-signed — see Release
checklist below). These are the exact files to upload once a Play
Console app entry exists:

- **AAB (primary Play Store artifact):**
  `build/app/outputs/bundle/release/app-release.aab`
- **APK (for direct-install testing, not for Play Store upload):**
  `build/app/outputs/flutter-apk/app-release.apk`

These are build outputs (gitignored via `/build/`), not checked into
version control — rebuild with `flutter build appbundle --release` /
`flutter build apk --release` if they are ever deleted or the signing
configuration changes.

## Primary category recommendation

**Games → Puzzle.** ARROWW is a single-player logic puzzle (clear a grid of
arrows in the right order so each one can escape) with no other genre
elements (no action, no cards, no trivia).

## Short description / full description

Finalized and copy-paste-ready in `docs/play_store_store_listing.md`
(kept there, not duplicated here, so there is one place to copy from
when filling the Play Console form).

## Key features (for store bullet points)

- A growing collection of levels across a progressive difficulty curve
  (50 levels in this release — see App identity above for the exact
  current count; kept out of the wording itself so this list stays
  accurate as more levels are added in future updates)
- Simple one-tap controls
- Star rating + best-move tracking per level
- Hint, Undo, and Extra Moves tools
- Fully playable offline
- No ads, no in-app purchases, no account required
- Optional local reminder notifications (Tuesday & Saturday)

## Suggested keywords

puzzle, logic puzzle, brain game, arrow puzzle, offline game, no ads,
casual puzzle, grid puzzle, single player puzzle

*(Play Store no longer has a dedicated "keywords" field — these are for
informing the title/description word choice, not for direct entry.)*

## Content rating preparation notes

Based on the actual app content:
- No violence, no blood, no horror
- No profanity or crude humor (all in-app text is checked in
  `lib/screens/`, `lib/services/notification_service.dart`)
- No gambling, no simulated gambling
- No user-generated content, no chat, no social features
- No real-money purchases of any kind

Expected outcome when completing Google's content-rating questionnaire
(IARC): the lowest available rating tier (e.g. "Everyone" / "PEGI 3"),
pending actual questionnaire completion in Play Console — this document
does not submit or determine the rating itself.

## Data-safety preparation notes

**Based only on the current codebase** (see Phase 12 audit in the session
report for the exact inspection performed):

- **Data collected:** none. No form fields, no account creation, no
  contact/identity capture anywhere in `lib/`.
- **Data shared with third parties:** none. There is no analytics SDK, ad
  SDK, or backend integration in `pubspec.yaml` or `lib/`.
- **Data sent off-device:** none. The only network-capable code is
  `lib/services/connectivity_service.dart`, which performs a DNS lookup
  (`InternetAddress.lookup('example.com')`) purely to detect whether the
  device has internet access, for the Shop tab's offline messaging. No
  application data is sent in that request or anywhere else.
- **Local storage only:** all game progress, settings, and the
  notification message-rotation index are stored on-device via
  `shared_preferences` (`lib/storage/game_storage.dart`). Nothing is
  synced to a server or cloud account.
- **Permissions requested:** `INTERNET` (for the connectivity check
  above) and `POST_NOTIFICATIONS` (Android 13+, for the optional local
  reminder notifications; auto-merged from the
  `flutter_local_notifications` plugin's own manifest). No camera,
  microphone, location, contacts, storage, or telephony permissions are
  requested anywhere.
- **Account/login:** none. The app has no sign-in of any kind.
- **Data deletion:** uninstalling the app deletes all locally stored data
  (standard Android app-uninstall behavior); there is no server-side copy
  to separately delete.
- **Device identifiers / crash reporting:** none. Checked the full
  dependency tree in `pubspec.lock` (not just direct `pubspec.yaml`
  entries) for anything that could read an advertising ID, device ID, or
  report crashes off-device — found none. A few transitive packages
  (`http`, `path_provider`, `uuid`) are pulled in by `flutter_local_notifications`'s
  own internals or by the dev-only `flutter_launcher_icons` tool, but are
  never imported or called by ARROWW's own code (`lib/`) — confirmed via
  a direct import search, not assumed.

This should map to Play Console's Data Safety form as: **"No data
collected"**, with **"Data is not shared with third parties"** — subject
to your own final confirmation when actually completing that form, since
only you can make the formal declaration to Google.

## Permissions actually used

The complete, exact list from `android/app/src/main/AndroidManifest.xml`
plus what dependencies auto-merge in:

| Permission | Source | Why |
|---|---|---|
| `INTERNET` | declared directly in the app manifest | The connectivity check described above (`ConnectivityService`), used by the Shop tab and the Check Connection screen to show accurate offline messaging. No data is transmitted. |
| `POST_NOTIFICATIONS` | auto-merged from the `flutter_local_notifications` plugin | Android 13+ runtime permission for the optional Tuesday/Saturday local reminder notifications. |
| `VIBRATE` | auto-merged from the `flutter_local_notifications` plugin | Standard notification vibration; also used incidentally by the app's own haptic feedback (`HapticService`) on supported devices. |

No camera, microphone, location, contacts, storage, telephony, or
Bluetooth permissions are requested anywhere in the app or its
dependencies.

## Ads declaration status

**No ads.** No ad SDK is present in dependencies or code.

## IAP / subscription status

**None.** The in-game Shop (Hints, Undos, Extra Moves) spends only the
local, non-purchasable in-game coin currency earned by playing — see
`lib/screens/shop_tab.dart`'s own on-screen disclaimer: "Spend coins you
earn by playing. No real-money purchases." There is no `in_app_purchase`
package or billing integration in `pubspec.yaml`.

## Account/login requirement

**None.** No sign-in, no user accounts, no identity of any kind.

## Notifications behavior

Two optional local (on-device, no backend) reminder notifications:
Tuesday and Saturday at 7:00 PM local device time, rotating through a
pool of 15 pre-written, non-monetized messages. Fully controllable via
the **Settings → Notifications** toggle; off by default is not the
case — on by default, subject to the standard Android notification
permission prompt. See `lib/services/notification_service.dart` and
`lib/state/settings_controller.dart`.

## Privacy-policy requirement checklist

- [ ] Publish the existing in-app privacy policy text
      (`lib/screens/privacy_policy_screen.dart`) at a **public URL**
      (Play Console requires a hosted URL, not just in-app text) —
      e.g. a simple static page, GitHub Pages, or similar.
- [ ] Confirm the hosted text matches the in-app text (or update
      in-app text to match, if the hosted version needs Play-specific
      additions).
- [ ] Add that URL to the Play Console listing's Privacy Policy field.
- [ ] Re-check this policy any time new data behavior is added in the
      future (the in-app text already anticipates this: "If a future
      release adds online features... this policy will be updated
      before those features are enabled").

## Store screenshot requirements checklist

- [ ] Phone screenshots: minimum 2, up to 8; JPEG or 24-bit PNG (no
      alpha); each side between 320px and 3840px, with the longer side
      no more than twice the shorter side.
- [ ] Capture from the actual physical device (or an emulator at a
      representative resolution) — Home, a mid-game board, the
      Level-Complete overlay, and the Levels map are natural choices
      given the existing UI.
- [ ] Optional: 7-inch and 10-inch tablet screenshots if a tablet
      layout is ever explicitly supported (not currently a distinct
      layout target).

## App icon requirement checklist

- [x] 512×512 PNG, 32-bit with alpha, for the Play Store listing itself
      (separate from the launcher icon already generated via
      `flutter_launcher_icons` into `android/app/src/main/res/mipmap-*`)
      — generated at **`docs/play_store_icon_512.png`**, rendered
      directly from the same vector geometry (`tool/launcher_icon/arroww_icon.dart`)
      as the real launcher icon, via the new
      `tool/launcher_icon/render_store_icon.dart` script (run with
      `flutter test tool/launcher_icon/render_store_icon.dart`). This
      matches on-device branding exactly, isn't a resampled copy, and
      does not modify `assets/icon/` or any generated Android resource
      — it's purely an additional export for the Play Console upload.
- [ ] Upload `docs/play_store_icon_512.png` to the Play Console listing
      when the account exists.

## Feature graphic requirement checklist

- [ ] 1024×500 PNG or JPEG (no alpha), shown at the top of the store
      listing.
- [ ] Not yet created — this is new design work, not something derivable
      from existing in-app assets alone (the launcher icon's square
      artwork isn't the right aspect ratio). Plan to design one using the
      existing ARROWW color palette (`lib/theme/app_colors.dart`) and
      arrow motif for visual consistency with the app itself.

## Notes from this audit

The "prototype build" / "early prototype" / "simulated purchases"
wording previously flagged here has been removed from all user-facing
screens (About, Privacy Policy, Terms, Settings' Rate Us dialog, and the
Shop banner) in a later pass. Re-verified clean via a direct text search
across `lib/screens/` — no production-inappropriate wording remains. The
release AAB/APK were rebuilt afterward to include this correction; see
"Current release artifacts" above for the resulting file timestamps.

## Testing checklist (Play Console process, once an account exists)

- [ ] Internal testing track: upload the signed AAB, add yourself as a
      tester, confirm install-from-Play-Console works.
- [ ] Closed testing track: recruit the required minimum testers (Google
      currently requires **12 testers opted in for 14 continuous days**
      before Production access is granted to a new developer account —
      confirm the exact current figure in Play Console, as Google can
      change this).
- [ ] Verify the release notes field is filled in for every track.

## Release checklist

- [x] `flutter analyze` clean
- [x] `flutter test` full suite passing
- [x] `compileSdk`/`targetSdk` = 36 (Android 16), meeting current Play
      requirements
- [x] Release build is signed with a dedicated upload key (not the debug
      keystore) — see the session's signing verification report
- [x] 64-bit native libraries present (arm64-v8a, x86_64) alongside
      armeabi-v7a
- [x] 16KB page-size alignment verified on all bundled native libraries
- [ ] Google Play Console developer account created (**Play-Console-
      dependent, not completable locally**)
- [ ] App entry created in Play Console
- [ ] Store listing (description, screenshots, feature graphic, icon)
      uploaded
- [ ] Content rating questionnaire completed
- [ ] Data Safety form completed
- [ ] Privacy policy URL added
- [ ] AAB uploaded to a testing track
- [ ] Closed testing requirement satisfied (12 testers / 14 days)
- [ ] Production access requested and granted
- [ ] Production release submitted
