# Web Artifacts — HTML / CSS / React

## Mandatory minimum setup

Every Imaquinaria web artifact must include this block in `<head>` or equivalent:

```html
<link href="https://fonts.googleapis.com/css2?family=Archivo:ital,wdth,wght@0,125,500;0,100,400;0,100,500&family=Noto+Serif+JP:wght@500&display=swap" rel="stylesheet">
```

And these CSS tokens in `:root` / `[data-theme="dark"]`:

```css
:root {
  /* Semantic — light mode */
  --color-bg:           #F5F4F2;
  --color-surface:      #FAFAF8;
  --color-text:         #211A23;
  --color-text-muted:   #5A5258;
  --color-accent:       #E81036;
  --color-accent-dark:  #B90C2B;
  --color-accent-hover: #FF5372;
  --color-premium:      #4D2559;
  --color-premium-light:#7A5789;
  --color-border:       #E2DFE0;
  --color-overlay:      rgba(33,26,35,0.5);

  /* Feedback */
  --color-success:    #1F8A5B;  --color-success-bg: #E6F4EC;
  --color-warning:    #B96B0C;  --color-warning-bg: #FCF1E0;
  --color-danger:     #B90C2B;  --color-danger-bg:  #FBE4E8;

  /* Level progression (1–4, tenant-agnostic) */
  --level-1-bg: #f0e4cc; --level-1-border: #c8a870; --level-1-text: #826336;
  --level-2-bg: #e3c88e; --level-2-border: #b8882a; --level-2-text: #6c5129;
  --level-3-bg: #b8903c; --level-3-border: #7a5a18; --level-3-text: #473520;
  --level-4-bg: #5a3e22; --level-4-border: #3a2410; --level-4-text: #bea173;

  /* Tier Premium badge */
  --color-premium-badge-bg:     #7A5789;
  --color-premium-badge-border: #4D2559;
  --color-premium-badge-text:   #F0DC98;

  /* Radii & shadows */
  --shadow-sm:   0 1px 3px rgba(33,26,35,0.08);
  --shadow-md:   0 4px 12px rgba(33,26,35,0.10);
  --radius-sm:   6px;
  --radius-md:   10px;
  --radius-lg:   16px;
  --radius-xl:   24px;
  --radius-pill: 999px;

  /* Type */
  --font-display: 'Archivo', sans-serif;
  --font-body:    'Archivo', sans-serif;
  --font-accent:  'Noto Serif JP', serif;
}

[data-theme="dark"] {
  --color-bg:           #0F0C15;
  --color-surface:      #17121F;
  --color-text:         #F0EDED;
  --color-text-muted:   #9E9399;
  --color-accent:       #FF5372;
  --color-accent-dark:  #E81036;
  --color-accent-hover: #FF768F;
  --color-premium:      #7A5789;
  --color-premium-light:#9B7AA8;
  --color-border:       #201A2E;

  --level-1-bg: #2e251f; --level-1-border: #4a3828; --level-1-text: #947969;
  --level-2-bg: #3d321a; --level-2-border: #604e28; --level-2-text: #c6a86d;
  --level-3-bg: #906830; --level-3-border: #c08840; --level-3-text: #f0dc98;
  --level-4-bg: #e8d0a0; --level-4-border: #c8a860; --level-4-text: #6a5030;

  --color-premium-badge-bg:     #2A1535;
  --color-premium-badge-border: #7A5789;
  --color-premium-badge-text:   #C6A86D;

  --shadow-sm: none;
  --shadow-md: none;
}
```

## Dark mode

```js
// useTheme hook — standard logic
const saved = localStorage.getItem('theme') ||
  (matchMedia('(prefers-color-scheme:dark)').matches ? 'dark' : 'light');
document.documentElement.setAttribute('data-theme', saved);
```

Toggle: button in the top-right corner of the nav. Icon only (sun/moon), no text.

## Using the logo on the web

```html
<!-- Option 1: full logo (standard) -->
<img src="assets/logo-full.png" alt="Imaquinaria" height="80">

<!-- Option 2: mark only (favicon, avatar) -->
<img src="assets/dragon-icon.png" alt="Imaquinaria" width="40" height="40">

<!-- Option 3: inline SVG wordmark (when it must scale without loss) -->
<!-- Inline the contents of assets/wordmark.svg directly into the HTML -->
```

## React — theming structure

```tsx
// theme/variables.css — import in main.tsx
// Components always use var(--color-*), never literal values

// Tailwind: core utility classes only (no custom JIT)
// No custom color classes — CSS variables handle theming
```

## Mandatory accessibility

- Focus ring: `outline: 2px solid var(--color-accent); outline-offset: 2px`
- Every `<input>` has an associated `<label for="...">`
- Decorative elements: `aria-hidden="true"`
- Navigation: `role="navigation"` with `aria-label`
- `prefers-reduced-motion`: suppress bounce and glow animations
- CLP amounts: `Intl.NumberFormat('es-CL', {style:'currency', currency:'CLP'})`
- Dates: `Intl.DateTimeFormat('es-CL')`
- `lang="es"` on `<html>`

## Responsive — breakpoints

| Name | Range | Key behavior |
|------|-------|--------------|
| Mobile | ≤ 640px | Sidenav → bottom tab bar; single column; full-width buttons |
| Tablet | 641–1024px | Collapsed sidenav (icons); 2-column grid |
| Desktop | ≥ 1025px | Fixed 220px sidenav; 3-column grid |

Minimum touch targets on mobile: 44×44px.

## Custom scrollbar

```css
::-webkit-scrollbar { width: 4px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--color-border); border-radius: 99px; }
```
