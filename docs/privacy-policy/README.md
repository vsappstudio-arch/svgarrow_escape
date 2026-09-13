# ARROWW Privacy Policy — hosting instructions

`index.html` in this folder is a complete, self-contained privacy policy
page: no external stylesheets, no fonts, no scripts, no analytics, no
tracking of any kind. It only describes ARROWW's actual current behavior
(see `docs/play_store_release_checklist.md` for the underlying code audit
this text is based on).

## This page is NOT live anywhere yet

Google Play requires the privacy policy to be reachable at a **public
HTTPS URL** before you can submit a listing — an in-app screen or a local
file is not sufficient. Before submitting to Play Console, you need to:

1. **Fill in a real support email** — replace the placeholder text in the
   "Contact" section (`[SUPPORT EMAIL NOT YET SET — replace before
   publishing]`) with the actual address you want players to reach.
2. **Push this repository to GitHub, then enable GitHub Pages** (see the
   exact steps below — this repo's remote currently has nothing pushed
   to it yet, so Pages cannot go live until that happens).
3. **Confirm the hosted page matches this file** whenever this file is
   updated in the future (e.g. if new functionality changes what data the
   app touches — see the "Changes to this policy" section on the page
   itself, and update the in-app Privacy Policy screen,
   `lib/screens/privacy_policy_screen.dart`, to match at the same time).
4. **Add the final public URL** to the Play Console listing's Privacy
   Policy field once hosted.

### GitHub Pages — exact steps for this repository

Verified against the actual repository state (not assumed):

- **Actual GitHub remote:** `https://github.com/vsappstudio-arch/svgarrow_escape`
  — note this is **`svgarrow_escape`**, not `arrow_escape`. Any URL built
  from the `arrow_escape` name (including one that may have been assumed
  before this was checked) will 404 — the correct resulting Pages URL
  once live is:

  ```
  https://vsappstudio-arch.github.io/svgarrow_escape/privacy-policy/
  ```

- **Nothing has been pushed to `origin` yet.** `git ls-remote --heads
  origin` returns empty, and the local `master` branch has no upstream
  configured. GitHub Pages can only serve what's actually on GitHub, so
  the first required step — outside of anything this assistant can do
  without your explicit approval — is pushing your work.
- **The remote's default branch is `main`**, while the local branch here
  is `master`. Decide which branch you want Pages to build from (either
  is fine — GitHub Pages doesn't require the branch to be named `main`);
  just be consistent between what you push and what you select in the
  next step.

Once pushed, in the GitHub web UI:

1. Go to the repository → **Settings → Pages**.
2. Under **Build and deployment → Source**, choose **Deploy from a
   branch**.
3. Under **Branch**, select the branch you pushed to, and set the folder
   to **`/docs`**. Save.
4. GitHub builds and publishes the site — this usually takes anywhere
   from under a minute to a few minutes. The **Pages** settings page
   will show a banner with the live URL and a checkmark once it's ready.
5. Confirm it's actually live by opening
   `https://vsappstudio-arch.github.io/svgarrow_escape/privacy-policy/`
   in a browser (or re-running the same check this assistant used:
   `curl -I` the URL and confirm a `200` status, not `404`).

## Keeping this in sync with the in-app version

The in-app Privacy Policy screen (`lib/screens/privacy_policy_screen.dart`)
and this page should always describe the same facts, even though the
wording doesn't need to be character-for-character identical. If ARROWW's
actual behavior changes (e.g. a future feature starts using the network
for more than the offline-detection check), update **both** places, and
update this policy's "Effective" date.
