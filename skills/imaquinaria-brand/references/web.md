# Artefactos Web — HTML / CSS / React

## Setup mínimo obligatorio

Todo artefacto web de Imaquinaria debe incluir este bloque en `<head>` o equivalente:

```html
<link href="https://fonts.googleapis.com/css2?family=Archivo:ital,wdth,wght@0,125,500;0,100,400;0,100,500&family=Noto+Serif+JP:wght@500&display=swap" rel="stylesheet">
```

Y estos tokens CSS en `:root` / `[data-theme="dark"]`:

```css
:root {
  /* Semantic — Light mode */
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

## Modo oscuro

```js
// Hook useTheme — lógica estándar
const saved = localStorage.getItem('theme') ||
  (matchMedia('(prefers-color-scheme:dark)').matches ? 'dark' : 'light');
document.documentElement.setAttribute('data-theme', saved);
```

Toggle: botón en esquina superior derecha de nav. Solo ícono (sol/luna), sin texto.

## Uso del logo en web

```html
<!-- Opción 1: logo completo (estándar) -->
<img src="assets/logo-full.png" alt="Imaquinaria" height="80">

<!-- Opción 2: solo isotipo (favicon, avatar) -->
<img src="assets/dragon-icon.png" alt="Imaquinaria" width="40" height="40">

<!-- Opción 3: wordmark SVG inline (cuando se necesita escalar sin pérdida) -->
<!-- Incrustar contenido de assets/wordmark.svg directamente en el HTML -->
```

## React — estructura de theming

```tsx
// theme/variables.css — importar en main.tsx
// Componentes usan var(--color-*) siempre, nunca valores literales

// Tailwind: solo utility classes del core (no JIT personalizado)
// Sin clases de color custom — las variables CSS manejan el theming
```

## Accesibilidad obligatoria

- Focus ring: `outline: 2px solid var(--color-accent); outline-offset: 2px`
- Todos los `<input>` tienen `<label for="...">` asociado
- Elementos decorativos: `aria-hidden="true"`
- Navegación: `role="navigation"` con `aria-label`
- `prefers-reduced-motion`: suprimir animaciones de bounce y glow
- Montos en CLP: `Intl.NumberFormat('es-CL', {style:'currency', currency:'CLP'})`
- Fechas: `Intl.DateTimeFormat('es-CL')`
- `lang="es"` en `<html>`

## Responsive — breakpoints

| Nombre | Rango | Comportamiento clave |
|--------|-------|----------------------|
| Móvil | ≤ 640px | Sidenav → bottom tab bar; columna única; botones full-width |
| Tablet | 641–1024px | Sidenav colapsado (íconos); grid 2 cols |
| Desktop | ≥ 1025px | Sidenav fijo 220px; grid 3 cols |

Touch targets mínimos en móvil: 44×44px.

## Scrollbar personalizado

```css
::-webkit-scrollbar { width: 4px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--color-border); border-radius: 99px; }
```
