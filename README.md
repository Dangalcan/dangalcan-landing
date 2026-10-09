# dangalcan-landing

The personal landing page of Daniel Galván Cancio (Dangalcan).

It is a hand-written static site with no framework, no build step and no dependencies.
GitHub Pages serves the files exactly as they are in this repository.

```
index.html                  the page, semantic markup only (no style="")
favicon.svg                 the "D" mark
assets/css/tokens.css       palette, fonts, type scale, spacing and the cascade layer order
assets/css/base.css         reset, page background and shared primitives (.wrap, .section, .label, .display)
assets/css/components.css   one block per area of the page, in page order, BEM class names
assets/js/site.js           the two clocks, the marquee loop and the reveal on scroll
assets/fonts/*.woff2        Space Grotesk, JetBrains Mono and Fraunces, latin subset, self-hosted
assets/fonts/OFL-*.txt      their licences (SIL OFL 1.1, redistributed with the files)
assets/img/portrait.jpg     the hero illustration
assets/img/og.png           the share image shown in link previews (1200 x 630)
scripts/check.sh            static checks, run by CI before every deploy
scripts/og/                 og.html, the source of the share image, and render.ps1, which renders it
.github/workflows/pages.yml deploy to GitHub Pages on every push to master
```

## Working on it

There is nothing to install. Open `index.html`, or serve the directory to get the same
behaviour as production.

```bash
python -m http.server 8777
```

Then open <http://127.0.0.1:8777>. Before pushing, run the same checks CI runs.

```bash
bash scripts/check.sh
```

They make sure every file the page or the stylesheets reference exists, that nothing loads
from a third-party origin, and that there are no inline styles or placeholder links.

## How the CSS is organised

The three stylesheets share four cascade layers, declared at the top of `tokens.css` in this
order `tokens, base, components, utilities`. A later layer always wins over an earlier one,
whatever the selector, so a component can restyle a primitive without `!important`.

- **Tokens first.** Every colour, font, letter-spacing step and spacing value is a custom
  property in `tokens.css`. Components read them and never hard-code their own.
- **Primitives in `base.css`.** `.label` is the small mono caption used everywhere,
  `.display` is the serif display face (an `<em>` inside it becomes the light italic),
  `.section` gives the vertical rhythm, with `--flush` and `--alt` modifiers.
- **Components in `components.css`.** One block per area of the page, in the order they
  appear. Styles are mobile first and each block carries its desktop rules in a nested
  `@media (width > 900px)`.
- **Card colours.** A repository card inverts on hover by swapping three local properties,
  `--card-bg`, `--card-fg` and `--card-muted`. The featured card sets them permanently.

## Common changes

**Add or change a repository card.** In `index.html`, copy one `<article class="repo-card">`
inside `.repo-grid` and change the link, the title, the description, `data-lang` and the
date. The whole card is clickable through the title link. Add
`<span class="repo-card__pin label">Pinned</span>` before the arrow to show the pin badge.

**Add a language colour.** Add one line next to the others under *Language colours* in
`components.css`, with the colour GitHub uses.

```css
[data-lang="go"] { --lang: #00add8; }
```

**Change the palette, fonts or spacing.** Edit `tokens.css`. To replace a font, drop the
new `woff2` into `assets/fonts/`, add its licence, and update the `@font-face` block.

**Change the share image.** Edit `scripts/og/og.html` and run `.\scripts\og\render.ps1`
ender.ps1`
from PowerShell. It renders the page with Edge to `assets/img/og.png` at 1200 x 630. LinkedIn
caches previews, so after a change its Post Inspector can force a refresh.

**Change the domain.** The site URL is written in four places in the `<head>` of
`index.html`, the canonical link, `og:url`, `og:image` and the JSON-LD block. Change them
together. Link previews need absolute URLs, so they cannot be relative.

**Keep every claim backed.** Awards and publications link to a public source, such as the
handle of a paper or a DOI. A new claim gets its link at the same time it is added.

**Add a section.** Use `<section class="section" id="...">` with a `.wrap` and a
`.section-head` inside, add its block to `components.css` in page order, and link it from
`.topbar__nav` if it should be in the menu.

## Deploying

`.github/workflows/pages.yml` runs `scripts/check.sh` on every push to `master`, copies
`index.html`, `favicon.svg` and `assets/` into `_site/`, and publishes that to GitHub Pages.
The README, the scripts and the workflows are not published.

One-time setup in the repository is *Settings > Pages > Source = GitHub Actions*.
`workflow_dispatch` re-runs the same deploy by hand.

All URLs in the page are relative, so the site works both at the root of a user site
(a repository named `Dangalcan.github.io`) and under a project path
(`dangalcan.github.io/dangalcan-landing/`).

## Conventions worth keeping

- **No invented numbers.** Every figure on the page has a record behind it, either GitHub
  (repositories, account age) or a public result (the ETSII award, the CERN challenge).
  If a number cannot be checked, it does not go on the page.
- **Fonts are vendored.** No Google Fonts request and no third-party origin. The check
  script fails the deploy if one appears.
- **No inline styles.** Every visual decision lives in the stylesheets, so a change in one
  place reaches the whole page.
- **Plain prose.** Text on the page avoids em dashes, semicolons and colons. Labels use the
  middle dot (·) as separator.
- **Everything degrades.** With JavaScript off the page reads in full, the clocks show their
  placeholder and the marquee stands still. With `prefers-reduced-motion` there is no
  animation and nothing starts hidden.

## Licence

The bundled fonts are SIL OFL 1.1, and their licence texts travel with the files in
`assets/fonts/`.
