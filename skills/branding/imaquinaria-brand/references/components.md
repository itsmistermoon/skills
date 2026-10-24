# UI Components — Imaquinaria Brand

## Buttons

### Primary (main action)
```css
background: var(--color-accent);       /* #E81036 */
color: #fff;
border-radius: var(--radius-md);       /* 10px */
font-family: 'Archivo', sans-serif;
font-weight: 500;
padding: 8px 18px;
border: none;
```
Hover: `background: var(--color-accent-dark)` (#B90C2B)

### Secondary (alternative action)
```css
background: transparent;
color: var(--color-accent);
border: 0.5px solid var(--color-accent);
border-radius: var(--radius-md);
```
Hover: `background: rgba(232,16,54,0.08)`

### Ghost (tertiary action)
```css
background: transparent;
color: var(--color-text-muted);
border: 0.5px solid var(--color-border);
border-radius: var(--radius-md);
```
Hover: `color: var(--color-text)`

### Premium (Kamon)
```css
background: var(--color-premium);     /* #4D2559 light / #7A5789 dark */
color: #fff;
border-radius: var(--radius-md);
```
Hover: `opacity: 0.85` (token `--color-premium-dark` removed)

### Sizes
- Normal: `padding: 8px 18px; font-size: 13px`
- Small: `padding: 5px 12px; font-size: 12px`
- Icon: `padding: 8px` (square)

---

## Inputs and forms

```css
.input-field {
  font-family: 'Archivo', sans-serif;
  font-size: 13px;
  padding: 9px 12px;
  border-radius: var(--radius-md);
  border: 0.5px solid var(--color-border);
  background: var(--color-surface);
  color: var(--color-text);
  outline: none;
}
.input-field:focus {
  border-color: var(--color-accent);
}
.input-label {
  font-size: 11px;
  font-weight: 500;
  color: var(--color-text);
}
```

Required fields: mark with `*` in `var(--color-accent)`.

---

## Level badges

Level badges do NOT use the accent color — they are neutral.

Each level uses its own token group. Example for level N (1–4):
```css
.badge-level-N {
  background: var(--level-N-bg);
  color: var(--level-N-text);
  border: 0.5px solid var(--level-N-border);
  font-family: 'Archivo', sans-serif;
  font-variation-settings: 'wdth' 125;
  font-weight: 500;
  font-size: 11px;
  padding: 3px 10px;
  border-radius: 20px;
}
```

Level names at Imaquinaria: Rōnin (1), Samurai (2), Hatamoto (3), Daimyō (4). All use the same token pattern — there is no color exception for Daimyō.

---

## Kamon badge (Premium Tier)

```css
.badge-premium {
  background: var(--color-premium-badge-bg);
  color: var(--color-premium-badge-text);
  border: 0.5px solid var(--color-premium-badge-border);
  font-family: 'Archivo', sans-serif;
  font-variation-settings: 'wdth' 125;
  font-weight: 500;
  font-size: 11px;
  padding: 3px 10px;
  border-radius: 20px;
}
```

---

## XP progress bar

```css
.progress-track {
  height: 5px;
  background: var(--color-border);
  border-radius: 99px;
  overflow: hidden;
}
.progress-fill {
  height: 100%;
  background: var(--color-premium);   /* ALWAYS purple, never red */
  border-radius: 99px;
  transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}
```

---

## Cards

### Main card
```css
background: var(--color-surface);
border: 0.5px solid var(--color-border);
border-radius: var(--radius-lg);          /* 16px */
box-shadow: var(--shadow-sm);
```

### Secondary / compact card
```css
border-radius: var(--radius-md);          /* 10px */
```

In dark mode: no `box-shadow` — elevation comes from the color difference.

---

## Stamp cards (stamp grid)

### Container
```css
.stamp-grid {
  display: grid;
  gap: 6px;
  /* columns: set from total_stamps, max 4 per row on mobile */
}
```

### Individual stamp
```css
.stamp {
  aspect-ratio: 1;
  border-radius: var(--radius-md);
  border: 0.5px solid var(--color-border);
  background: var(--color-bg);
  display: flex;
  align-items: center;
  justify-content: center;
}
.stamp.filled {
  background: var(--color-accent);   /* #E81036 */
  border-color: transparent;
}
.stamp svg { width: 55%; height: 55%; }
.stamp.filled svg { fill: #fff; }
.stamp:not(.filled) svg { fill: var(--color-border); }
```

Animation when a new stamp is filled:
```css
@keyframes stamp-in {
  0%   { transform: scale(0) rotate(-15deg); opacity: 0; }
  70%  { transform: scale(1.15) rotate(3deg); }
  100% { transform: scale(1) rotate(0deg); opacity: 1; }
}
/* duration: 500ms, easing: cubic-bezier(0.34, 1.56, 0.64, 1) */
```

---

## Status chips

```css
/* Base */
.chip {
  display: inline-flex; align-items: center; gap: 4px;
  font-size: 11px; padding: 2px 8px;
  border-radius: var(--radius-sm);
  background: var(--color-bg);
  color: var(--color-text-muted);
  border: 0.5px solid var(--color-border);
}
/* Completed / success */
.chip-success { background: rgba(34,197,94,.1); color: #15803d; border-color: transparent; }
/* Pending / warning */
.chip-warn    { background: rgba(234,179,8,.1); color: #a16207; border-color: transparent; }
/* Error / cancelled */
.chip-danger  { background: rgba(239,68,68,.1); color: #dc2626; border-color: transparent; }
```

---

## Data tables

```css
.data-table { width: 100%; border-collapse: collapse; }
.data-table th {
  font-size: 10px; font-weight: 500;
  letter-spacing: .08em; text-transform: uppercase;
  color: var(--color-text-muted);
  padding: .5rem .75rem; text-align: left;
  border-bottom: 0.5px solid var(--color-border);
}
.data-table td {
  font-size: 13px; padding: .65rem .75rem;
  border-bottom: 0.5px solid var(--color-border);
  color: var(--color-text);
}
.data-table tr:last-child td { border-bottom: none; }
.data-table tr:hover td { background: var(--color-bg); }
```

---

## Navigation

### Desktop (sidenav)
- Fixed width: 220px
- Background: `var(--color-surface)`, right border: `0.5px solid var(--color-border)`
- Active item: `color: var(--color-accent)`, `border-left: 2px solid var(--color-accent)`

### Mobile (bottom tab bar)
- Background: `var(--color-surface)`
- Active item: `color: var(--color-accent)`
- Minimum touch targets: 44×44px

---

## Microinteractions — standard timing

| Interaction | Duration | Easing |
|-------------|----------|--------|
| Purchase recorded | 600ms | ease-out |
| Stamp earned | 500ms | cubic-bezier(.34,1.56,.64,1) |
| Level up | 800ms | ease + glow pulse |
| View navigation | 250ms | ease |
| Button hover | 200ms | ease |

`prefers-reduced-motion`: suppress bounce and glow; keep only color changes.
