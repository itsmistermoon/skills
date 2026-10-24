---
name: imaquinaria-brand
description: >
  Applies Imaquinaria's brand identity — colors, typography, logo, UI
  components — to any artifact representing the brand: web components, HTML
  email, print/presentation materials, or social media assets. Trigger
  whenever the output touches Imaquinaria's visual identity, even partially:
  logos, loyalty-program visuals (stamp cards, level badges, Kamon tier),
  promotional materials, or any branded touchpoint.
---

# Imaquinaria Brand Guidelines

Imaquinaria is a physical pop-culture and geek store in Temuco, Chile. Its loyalty program is called **El Sendero del Bushidō**. Before producing any visual artifact, read this full guide.

---

## 1. Brand identity in one sentence

Origami + Japanese culture + geek culture. Geometric, clean, with character. The red origami dragon is the visual synthesis of all of that.

---

## 2. Color palette

### Primary colors (always available)

| Token | Hex | RGB | Use |
|-------|-----|-----|-----|
| `--color-accent` (light mode) | `#E81036` | rgb(232,16,54) | Primary actions, CTAs, logo, wordmark |
| `--color-accent` (dark mode) | `#FF5372` | rgb(255,83,114) | Primary actions on dark backgrounds |
| `--color-accent-dark` | `#B90C2B` | rgb(185,12,43) | Hover, logo shadows, dark dragon facets |
| `--color-accent-hover` | `#FF5372` | rgb(255,83,114) | Hover states in light mode |
| Brand black | `#211A23` | rgb(33,26,35) | Main text, dark brand background |
| Brand white | `#F5F4F2` | rgb(245,244,242) | Light backgrounds, text on red |

### Secondary colors (loyalty program)

| Token | Hex | Use |
|-------|-----|-----|
| `--color-premium` (light) | `#4D2559` | Kamon badge, XP bar |
| `--color-premium` (dark) | `#7A5789` | Kamon in dark mode |
| `--color-premium-light` | `#9B7AA8` | Soft backgrounds for premium elements |

### Progression level tokens (1–4, light + dark)

| Group | Tokens | Use |
|-------|--------|-----|
| Level 1 (Rōnin) | `--level-1-bg/border/text` | Rōnin badge |
| Level 2 (Samurai) | `--level-2-bg/border/text` | Samurai badge |
| Level 3 (Hatamoto) | `--level-3-bg/border/text` | Hatamoto badge |
| Level 4 (Daimyō) | `--level-4-bg/border/text` | Daimyō badge |

### Kamon badge tokens (Premium Tier)

| Token | Use |
|-------|-----|
| `--color-premium-badge-bg` | Badge background |
| `--color-premium-badge-border` | Badge border |
| `--color-premium-badge-text` | Badge text |

### Surface colors (UI)

| Token | Light mode | Dark mode |
|-------|-----------|-----------|
| `--color-bg` | `#F5F4F2` | `#0F0C15` |
| `--color-surface` | `#FAFAF8` | `#17121F` |
| `--color-text` | `#211A23` | `#F0EDED` |
| `--color-text-muted` | `#5A5258` | `#9E9399` |
| `--color-border` | `#E2DFE0` | `#201A2E` |
| `--color-overlay` | `rgba(33,26,35,0.5)` | ← same value |

### Color usage rules — CRITICAL

- `#E81036` **ONLY** for primary actions, CTAs, logo and wordmark. Never as a decorative page background.
- `#DC143C` (standard CSS crimson) **is NOT** Imaquinaria's red. If it appears in code, it is an error.
- Purple **ONLY** for the Premium Tier (Kamon) and the XP progress bar. Never as an action color.
- Red and purple **NEVER** in the same visual hierarchy within the same component.
- All color values must come from CSS tokens (`var(--color-*)`) in web artifacts. Never hardcode hex values in components.

---

## 3. Typography

### Font families

| Variable | Family | Use |
|----------|--------|-----|
| `--font-display` | **Archivo** (wdth=125, weight=500) | Titles, headings, Bushidō level names |
| `--font-body` | **Archivo** (wdth=100, weight=400) | Body text, general UI |
| `--font-accent` | **Noto Serif JP** (weight=500) | "El Sendero del Bushidō", subtitles with Japanese cultural flavor |

### Critical display configuration

Titles use Archivo in the **semi-expanded** variant — without it the design loses its distinctive character:

```css
.font-display {
  font-family: 'Archivo', sans-serif;
  font-variation-settings: 'wdth' 125;
  font-weight: 500;
  letter-spacing: -0.005em;
}
```

Google Fonts import:
```html
<link href="https://fonts.googleapis.com/css2?family=Archivo:ital,wdth,wght@0,125,500;0,100,400;0,100,500&family=Noto+Serif+JP:wght@500&display=swap" rel="stylesheet">
```

### Type scale

| Element | Family | wdth | Weight | Size |
|---------|--------|------|--------|------|
| Page title | Archivo | 125 | 500 | 2rem–2.5rem |
| Section heading | Archivo | 125 | 500 | 1.5rem |
| Program name | Noto Serif JP | — | 500 | 1.25rem |
| Body | Archivo | 100 | 400 | 1rem |
| Label / caption | Archivo | 100 | 500 | 0.875rem |
| Level badge | Archivo | 125 | 500 | 0.75rem |

---

## 4. Logo and brand assets

### Available assets (in `assets/`)

| File | Contents | When to use |
|------|----------|-------------|
| `assets/wordmark.svg` | "IMAQUINARIA" wordmark as pure SVG paths | When only the brand name is needed on web/screen |
| `assets/dragon-icon.png` | Origami dragon mark alone, transparent background | Favicon, avatar, app icon, use independent of the name |
| `assets/logo-full.png` | Full composition: dragon above + wordmark below | Standard use in headers and brand materials |

### Standard logo composition

```
[ORIGAMI DRAGON]        ← mark centered, approx. 60% of the total width
    [IMAQUINARIA]       ← wordmark centered below, same width as the dragon
```

The wordmark is **pure SVG paths** (not text set in a font). **Never try to recreate the wordmark typographically with the original font.** The base font is **Lemon Milk Bold** (custom/commercial, not available on Google Fonts).

If the brand name is needed as **editable text** (emails, documents, materials where the SVG cannot be embedded), use the closest substitute available on Google Fonts:

```
League Spartan, ExtraBold 800, uppercase
```

Import:
```html
<link href="https://fonts.googleapis.com/css2?family=League+Spartan:wght@800&display=swap" rel="stylesheet">
```

```css
.wordmark-substitute {
  font-family: 'League Spartan', sans-serif;
  font-weight: 800;
  text-transform: uppercase;
  color: #E81036;
  letter-spacing: 0.02em;
}
```

Always clarify in code, with a comment, that this is a substitute and not the official wordmark.

### Logo colors

- **Main color of the dragon and wordmark:** `#E81036`
- **Dragon shadows/dark facets:** `#B90C2B` and darker (down to ~`#8B0010`)
- The dragon has a 3D folded-paper effect with a light gradient → shadow on the planes

### Permitted logo versions

| Version | Background | Description |
|---------|-----------|-------------|
| Color (standard) | White / light | Red logo on white/light background — primary use |
| Inverted | Black / dark `#211A23` | White logo on dark background |
| Monochrome red | Transparent | Mark only, for digital use |

**Never:** distort proportions, change logo colors, add effects (shadow, gradient) to the wordmark, or use the mark below 24px.

### Clear space

The logo must have a minimum margin equal to the height of the letter "I" in the wordmark on all sides.

---

## 5. Spacing and borders

```css
--radius-sm: 6px;    /* inputs, badges, chips */
--radius-md: 10px;   /* secondary cards, buttons */
--radius-lg: 16px;   /* main cards, modals */
--radius-xl: 24px;   /* bottom sheets, large panels */

--shadow-sm: 0 1px 3px rgba(33,26,35,0.08);
--shadow-md: 0 4px 12px rgba(33,26,35,0.10);
```

In dark mode shadows are suppressed — elevation is communicated only by the difference in surface color.

---

## 6. UI components with specific rules

See `references/components.md` for detailed specs of:
- Buttons (primary, secondary, ghost, premium)
- Inputs and forms
- Level badges (Rōnin, Samurai, Hatamoto, Daimyō)
- Kamon badge (Premium Tier)
- XP progress bar
- Stamp cards and stamp grids
- Data tables
- Status chips

---

## 7. Loyalty program — El Sendero del Bushidō

### Levels

| Level | Name | Minimum XP | Multiplier | Reference emoji |
|-------|------|-----------|------------|-----------------|
| 1 | Rōnin | 0 XP | ×1.0 | 🗡️ |
| 2 | Samurai | 1,000 XP | ×1.2 | ⚔️ |
| 3 | Hatamoto | 5,000 XP | ×1.5 | 🏯 |
| 4 | Daimyō | 10,000 XP | ×2.0 | 👑 |

Each level uses its own token group `--level-{n}-bg/border/text` — never `--color-premium` directly on level badges.

### Premium Tier (Kamon at Imaquinaria)

- **Name at Imaquinaria:** Kamon
- **Price:** CLP $2,990/month
- **Badge tokens:** `--color-premium-badge-bg/border/text`

---

## 8. Dark mode

- Activated by `data-theme="dark"` on `<html>`
- Preference persisted in `localStorage` under the key `"theme"`
- If there is no saved preference, the system `prefers-color-scheme` is respected
- Every component must be designed for both modes simultaneously, never for just one

---

## 9. Application by artifact type

For detailed instructions per deliverable type, read the matching reference file:

| Artifact | Reference file |
|----------|----------------|
| Web components (HTML/CSS/React) | `references/web.md` |
| Transactional email (HTML email) | `references/email.md` |
| Presentation materials (PPTX) | `references/print.md` |
| Physical material / print | `references/print.md` |
| Social media / digital assets | `references/social.md` |
