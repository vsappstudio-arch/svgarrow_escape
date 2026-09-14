# ARROWW Privacy Policy — hosting instructions

`index.html` in this folder is a complete, self-contained privacy policy
page: no external stylesheets, no fonts, no scripts, no analytics, no
tracking of any kind. It only describes ARROWW's actual current behavior
(see `docs/play_store_release_checklist.md` for the underlying code audit
this text is based on).

## Hosting status: LIVE

Google Play requires the privacy policy to be reachable at a **public
HTTPS URL** before you can submit a listing — an in-app screen or a local
file is not sufficient. That requirement is met:

1. **Support email is set.** The "Contact" section on the page contains
   the real address: `vsappstudio@gmail.com`.
2. **This repository is pushed to GitHub, and GitHub Pages is enabled**
   for it (`docs/` folder, `main` branch).
3. **The page is confirmed live and correct**, at:

   ```
   https://vsappstudio-arch.github.io/svgarrow_escape/privacy-policy/
   ```

   Verified by fetching the URL directly (HTTP 200) and diffing its
   content byte-for-byte against `index.html` in this folder — identical.
4. **Confirm the hosted page still matches this file** whenever it's
   updated in the future (e.g. if new functionality changes what data the
   app touches — see the "Changes to this policy" section on the page
   itself, and update the in-app Privacy Policy screen,
   `lib/screens/privacy_policy_screen.dart`, to match at the same time).
   Since Pages serves directly from this repo's `docs/` folder, no
   redeploy step is needed beyond committing and pushing the update.
5. **Add the URL above** to the Play Console listing's Privacy Policy
   field once a Play Console app entry exists.

## Keeping this in sync with the in-app version

The in-app Privacy Policy screen (`lib/screens/privacy_policy_screen.dart`)
and this page should always describe the same facts, even though the
wording doesn't need to be character-for-character identical. If ARROWW's
actual behavior changes (e.g. a future feature starts using the network
for more than the offline-detection check), update **both** places, and
update this policy's "Effective" date.
