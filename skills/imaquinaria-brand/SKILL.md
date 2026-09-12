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

Imaquinaria es una tienda física de cultura pop japonesa y geek en Temuco, Chile. Su programa de fidelización se llama **El Sendero del Bushidō**. Antes de producir cualquier artefacto visual, lee esta guía completa.

---

## 1. Identidad de marca en una frase

Origami + cultura japonesa + geek culture. Geométrico, limpio, con carácter. El dragón de origami rojo es la síntesis visual de todo eso.

---

## 2. Paleta de colores

### Colores primarios (siempre disponibles)

| Token | Hex | RGB | Uso |
|-------|-----|-----|-----|
| `--color-accent` (modo claro) | `#E81036` | rgb(232,16,54) | Acciones primarias, CTA, logo, wordmark |
| `--color-accent` (modo oscuro) | `#FF5372` | rgb(255,83,114) | Acciones primarias en fondos oscuros |
| `--color-accent-dark` | `#B90C2B` | rgb(185,12,43) | Hover, sombras del logo, facetas oscuras del dragón |
| `--color-accent-hover` | `#FF5372` | rgb(255,83,114) | Estados hover en modo claro |
| Negro de marca | `#211A23` | rgb(33,26,35) | Texto principal, fondo oscuro de marca |
| Blanco de marca | `#F5F4F2` | rgb(245,244,242) | Fondos claros, texto sobre rojo |

### Colores secundarios (programa de fidelización)

| Token | Hex | Uso |
|-------|-----|-----|
| `--color-premium` (claro) | `#4D2559` | Kamon badge, barra XP |
| `--color-premium` (oscuro) | `#7A5789` | Kamon en modo oscuro |
| `--color-premium-light` | `#9B7AA8` | Fondos suaves de elementos premium |

### Tokens de nivel de progresión (1–4, light + dark)

| Grupo | Tokens | Uso |
|-------|--------|-----|
| Nivel 1 (Rōnin) | `--level-1-bg/border/text` | Badge Rōnin |
| Nivel 2 (Samurai) | `--level-2-bg/border/text` | Badge Samurai |
| Nivel 3 (Hatamoto) | `--level-3-bg/border/text` | Badge Hatamoto |
| Nivel 4 (Daimyō) | `--level-4-bg/border/text` | Badge Daimyō |

### Tokens del badge Kamon (Tier Premium)

| Token | Uso |
|-------|-----|
| `--color-premium-badge-bg` | Fondo del badge |
| `--color-premium-badge-border` | Borde del badge |
| `--color-premium-badge-text` | Texto del badge |

### Colores de superficie (UI)

| Token | Modo claro | Modo oscuro |
|-------|-----------|-------------|
| `--color-bg` | `#F5F4F2` | `#0F0C15` |
| `--color-surface` | `#FAFAF8` | `#17121F` |
| `--color-text` | `#211A23` | `#F0EDED` |
| `--color-text-muted` | `#5A5258` | `#9E9399` |
| `--color-border` | `#E2DFE0` | `#201A2E` |
| `--color-overlay` | `rgba(33,26,35,0.5)` | ← mismo valor |

### Reglas de uso del color — CRÍTICAS

- `#E81036` **ÚNICAMENTE** para acciones primarias, CTA, logo y wordmark. Nunca como fondo decorativo de página.
- `#DC143C` (crimson CSS estándar) **NO ES** el rojo de Imaquinaria. Si aparece en código, es un error.
- El púrpura **ÚNICAMENTE** para Tier Premium (Kamon) y barra de progresión XP. Nunca como color de acción.
- Rojo y púrpura **NUNCA** en la misma jerarquía visual dentro del mismo componente.
- Todos los valores de color deben venir de tokens CSS (`var(--color-*)`) en artefactos web. Nunca hardcodear hex directamente en componentes.

---

## 3. Tipografía

### Familias tipográficas

| Variable | Familia | Uso |
|----------|---------|-----|
| `--font-display` | **Archivo** (wdth=125, weight=500) | Títulos, headings, nombres de niveles Bushidō |
| `--font-body` | **Archivo** (wdth=100, weight=400) | Cuerpo de texto, UI general |
| `--font-accent` | **Noto Serif JP** (weight=500) | "El Sendero del Bushidō", subtítulos con sabor cultural japonés |

### Configuración crítica de display

Los títulos usan Archivo en variante **semi-expanded** — sin esto, el diseño pierde su carácter distintivo:

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

### Escala tipográfica

| Elemento | Familia | wdth | Weight | Tamaño |
|----------|---------|------|--------|--------|
| Título de página | Archivo | 125 | 500 | 2rem–2.5rem |
| Heading de sección | Archivo | 125 | 500 | 1.5rem |
| Nombre del programa | Noto Serif JP | — | 500 | 1.25rem |
| Cuerpo | Archivo | 100 | 400 | 1rem |
| Etiqueta / caption | Archivo | 100 | 500 | 0.875rem |
| Badge de nivel | Archivo | 125 | 500 | 0.75rem |

---

## 4. Logo y activos de marca

### Activos disponibles (en `assets/`)

| Archivo | Contenido | Cuándo usar |
|---------|-----------|-------------|
| `assets/wordmark.svg` | Wordmark "IMAQUINARIA" en paths SVG puros | Cuando se necesita solo el nombre de la marca en web/pantalla |
| `assets/dragon-icon.png` | Isotipo dragón de origami solo, fondo transparente | Favicon, avatar, ícono de app, uso independiente del nombre |
| `assets/logo-full.png` | Composición completa: dragón arriba + wordmark abajo | Uso estándar en encabezados, materiales de marca |

### Composición estándar del logo

```
[DRAGÓN DE ORIGAMI]     ← isotipo centrado, aprox. 60% del ancho total
    [IMAQUINARIA]       ← wordmark centrado debajo, mismo ancho que el dragón
```

El wordmark es **paths SVG puros** (no texto con fuente). **Nunca intentar recrear el wordmark tipográficamente con la fuente original.** La fuente base es **Lemon Milk Bold** (custom/comercial, no disponible en Google Fonts).

Si se necesita el nombre de la marca en **texto editable** (emails, documentos, materiales donde no se puede incrustar el SVG), usar el sustituto más cercano disponible en Google Fonts:

```
League Spartan, ExtraBold 800, mayúsculas
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

Aclarar siempre en el código con un comentario que es un sustituto, no el wordmark oficial.

### Colores del logo

- **Color principal del dragón y wordmark:** `#E81036`
- **Sombras/facetas oscuras del dragón:** `#B90C2B` y más oscuro (hasta ~`#8B0010`)
- El dragón tiene efecto 3D de papel doblado con gradiente de luz → sombra en los planos

### Versiones del logo permitidas

| Versión | Fondo | Descripción |
|---------|-------|-------------|
| Color (estándar) | Blanco / claro | Logo rojo sobre fondo blanco/claro — uso principal |
| Invertido | Negro / oscuro `#211A23` | Logo blanco sobre fondo oscuro |
| Monocromo rojo | Transparente | Isotipo solo para uso en digital |

**Nunca:** distorsionar proporciones, cambiar colores del logo, añadir efectos (sombra, degradado) al wordmark, usar el isotipo por debajo de 24px.

### Zona de respeto

El logo debe tener un margen mínimo igual a la altura de la letra "I" del wordmark en todos sus lados.

---

## 5. Espaciado y bordes

```css
--radius-sm: 6px;    /* inputs, badges, chips */
--radius-md: 10px;   /* cards secundarias, botones */
--radius-lg: 16px;   /* cards principales, modales */
--radius-xl: 24px;   /* bottom sheets, paneles grandes */

--shadow-sm: 0 1px 3px rgba(33,26,35,0.08);
--shadow-md: 0 4px 12px rgba(33,26,35,0.10);
```

En modo oscuro las sombras se suprimen — la elevación se comunica solo por diferencia de color de superficie.

---

## 6. Componentes UI con reglas específicas

Ver `references/components.md` para especificaciones detalladas de:
- Botones (primario, secundario, ghost, premium)
- Inputs y formularios
- Badges de nivel (Rōnin, Samurai, Hatamoto, Daimyō)
- Badge Kamon (Tier Premium)
- Barra de progreso XP
- Stamp cards y grillas de sellos
- Tablas de datos
- Chips de estado

---

## 7. Programa de fidelización — El Sendero del Bushidō

### Niveles

| Nivel | Nombre | XP mínimo | Multiplicador | Emoji de referencia |
|-------|--------|-----------|---------------|---------------------|
| 1 | Rōnin | 0 XP | ×1.0 | 🗡️ |
| 2 | Samurai | 1.000 XP | ×1.2 | ⚔️ |
| 3 | Hatamoto | 5.000 XP | ×1.5 | 🏯 |
| 4 | Daimyō | 10.000 XP | ×2.0 | 👑 |

Cada nivel usa su propio grupo de tokens `--level-{n}-bg/border/text` — nunca `--color-premium` directamente en badges de nivel.

### Tier Premium (Kamon en Imaquinaria)

- **Nombre en Imaquinaria:** Kamon
- **Precio:** $2.990 CLP/mes
- **Tokens de badge:** `--color-premium-badge-bg/border/text`

---

## 8. Modo oscuro

- Activado por `data-theme="dark"` en `<html>`
- Preferencia persistida en `localStorage` bajo la key `"theme"`
- Si no hay preferencia, se respeta `prefers-color-scheme` del sistema
- Todo componente debe diseñarse para ambos modos simultáneamente, nunca solo para uno

---

## 9. Aplicación por tipo de artefacto

Para instrucciones detalladas según el tipo de entregable, lee el archivo correspondiente:

| Artefacto | Archivo de referencia |
|-----------|----------------------|
| Componentes web (HTML/CSS/React) | `references/web.md` |
| Email transaccional (HTML email) | `references/email.md` |
| Materiales de presentación (PPTX) | `references/print.md` |
| Material físico / impresión | `references/print.md` |
| Redes sociales / assets digitales | `references/social.md` |

