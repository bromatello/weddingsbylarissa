# Copilot / Agent Instructions for weddingsbylarissa

Quick, actionable guidance for AI assistants working on this repository.

## Project snapshot (big picture)
- Static website composed of plain HTML, CSS and images. No build system, no package.json, and no tests.
- Main files: root `index.html` and additional pages (e.g. `New_York_Wedding_Gallery.html`, `New_York_Celebrant_Popular_Questions.html`) with duplicate/similar content under `Content/` (e.g. `Content/index.html`).
- Styles and fonts live under `Content/CSS/` and `Content/Fonts/`. Images are under `Content/Images/`.
- Minor JS is inline in pages (modal gallery, navbar toggle, smooth scrolling). External libs: jQuery 3.3.1 and some third-party widgets (WeddingWire tracking scripts).

## How to run & validate changes locally
- There is no build step — open `index.html` (or `Content/index.html`) directly in a browser to preview changes.
- Use browser DevTools to validate scripts, images and CSS.
- When adding images, put them under `Content/Images/` and reference with a relative path (see examples below).

## Conventions & patterns to preserve
- Files use Windows-style relative paths in the repo (backslashes \); on the web prefer forward slashes (`Content/Images/your.jpg`). If normalizing paths, test in browser to ensure links still resolve.
- Naming: pages use descriptive, underscore-separated filenames e.g. `New_York_Celebrant_Popular_Questions.html` — follow this pattern when adding pages.
- Layout/styling: pages use W3.CSS-style classes (prefix `w3-`) and inline styles. Do not replace the styling system wholesale — prefer minimal, incremental edits unless a refactor is approved.
- Scripts: interactive features are implemented as small inline functions:
  - `onClick(element)` for the modal gallery (modal id `#modal01`, img `#img01`).
  - `toggleFunction()` for mobile navbar show/hide.
  - `myMap()` (Google Maps) is present but the Google Maps script tag is commented out.

## External integrations & sensitive values
- Google Analytics UA id present in multiple pages: `UA-53515617-1` — do not change this value without owner approval.
- WeddingWire widgets and trackers are included (`cdn1.weddingwire.com` scripts and `wpShowRated*()` calls). These are external dependencies — avoid offline modifications that remove or break them unless explicitly requested.

## Typical tasks & where to make changes
- Content/text updates: edit the appropriate HTML page in root or `Content/` folder (they often contain similar content). Example: update contact details in `index.html` and ensure corresponding pages (e.g. `Content/index.html`) are updated to remain consistent.
- Add an image: copy image into `Content/Images/`, add <img src="Content/Images/xxx.jpg"> with `onclick="onClick(this)"` if it should open in modal.
- Fix layout/visual bugs: modify `Content/CSS/WeddingsByLarissa.css` or `Content/CSS/font.css` and test by refreshing the HTML pages.
- Remove/replace libraries: if upgrading jQuery or modifying external scripts, run a browser smoke test for interactions (modal, smooth scroll, WeddingWire widgets).

## Safety, testing & PR guidance
- No automated tests: validate manually in a browser and in mobile viewport sizes (header/menu toggling is sensitive to screen size).
- Keep changes small and reversible. Provide a clear commit message describing WHY the change was made.
- When touching analytics or external widgets, warn the repo owner in the PR description and link the changed pages.

## Examples (concrete snippets from this repo)
- Modal gallery (do not break):
  - HTML: `<img src="Content/Images/p1_Winter_New_York_Wedding.jpg" onclick="onClick(this)" class="w3-hover-opacity">`
  - JS handling: `function onClick(element) { document.getElementById('img01').src = element.src; ... }`
- Contact block to update phone/email: present in `index.html` and `Content/index.html` with `+1 (917) 607-3147` and `LARISSA@WEDDINGSBYLARISSA.COM`.

## When in doubt
- Ask before changing analytics, legal meta (site verification), external widgets or Google Maps API keys.
- If asked to do a large refactor (e.g., convert to a static site generator), propose a plan and get approval — do not proceed with a blind large-scale conversion.

---
If you'd like, I can open a PR with this file or adjust content to match preferred tone/format. Please tell me what you'd like changed.
