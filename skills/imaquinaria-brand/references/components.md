# Componentes UI — Imaquinaria Brand

## Botones

### Primario (acción principal)
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

### Secundario (acción alternativa)
```css
background: transparent;
color: var(--color-accent);
border: 0.5px solid var(--color-accent);
border-radius: var(--radius-md);
```
Hover: `background: rgba(232,16,54,0.08)`

### Ghost (acción terciaria)
```css
background: transparent;
color: var(--color-text-muted);
border: 0.5px solid var(--color-border);
border-radius: var(--radius-md);
```
Hover: `color: var(--color-text)`

### Premium (Kamon)
```css
background: var(--color-premium);     /* #4D2559 claro / #7A5789 oscuro */
color: #fff;
border-radius: var(--radius-md);
```
Hover: `opacity: 0.85` (token `--color-premium-dark` eliminado)

### Tamaños
- Normal: `padding: 8px 18px; font-size: 13px`
- Small: `padding: 5px 12px; font-size: 12px`
- Icon: `padding: 8px` (cuadrado)

---

## Inputs y formularios

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

Campos requeridos: marcar con `*` en `var(--color-accent)`.

---

## Badges de nivel

Los badges de nivel NO usan el color de acento — son neutros.

Cada nivel usa su propio grupo de tokens. Ejemplo para nivel N (1–4):
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

Niveles concretos en Imaquinaria: Rōnin (1), Samurai (2), Hatamoto (3), Daimyō (4). Todos usan el mismo patrón de tokens — no hay excepción de color para Daimyō.

---

## Badge Kamon (Tier Premium)

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

## Barra de progreso XP

```css
.progress-track {
  height: 5px;
  background: var(--color-border);
  border-radius: 99px;
  overflow: hidden;
}
.progress-fill {
  height: 100%;
  background: var(--color-premium);   /* SIEMPRE púrpura, nunca rojo */
  border-radius: 99px;
  transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}
```

---

## Cards

### Card principal
```css
background: var(--color-surface);
border: 0.5px solid var(--color-border);
border-radius: var(--radius-lg);          /* 16px */
box-shadow: var(--shadow-sm);
```

### Card secundaria / compacta
```css
border-radius: var(--radius-md);          /* 10px */
```

En modo oscuro: sin `box-shadow` — la elevación se da por diferencia de color.

---

## Stamp cards (grilla de sellos)

### Contenedor
```css
.stamp-grid {
  display: grid;
  gap: 6px;
  /* columns: definir según total_stamps, máximo 4 por fila en móvil */
}
```

### Sello individual
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

Animación al rellenar un sello nuevo:
```css
@keyframes stamp-in {
  0%   { transform: scale(0) rotate(-15deg); opacity: 0; }
  70%  { transform: scale(1.15) rotate(3deg); }
  100% { transform: scale(1) rotate(0deg); opacity: 1; }
}
/* duration: 500ms, easing: cubic-bezier(0.34, 1.56, 0.64, 1) */
```

---

## Chips de estado

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
/* Completado / éxito */
.chip-success { background: rgba(34,197,94,.1); color: #15803d; border-color: transparent; }
/* Pendiente / advertencia */
.chip-warn    { background: rgba(234,179,8,.1); color: #a16207; border-color: transparent; }
/* Error / cancelado */
.chip-danger  { background: rgba(239,68,68,.1); color: #dc2626; border-color: transparent; }
```

---

## Tablas de datos

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

## Navegación

### Desktop (sidenav)
- Ancho fijo: 220px
- Fondo: `var(--color-surface)`, borde derecho: `0.5px solid var(--color-border)`
- Item activo: `color: var(--color-accent)`, `border-left: 2px solid var(--color-accent)`

### Móvil (bottom tab bar)
- Fondo: `var(--color-surface)`
- Item activo: `color: var(--color-accent)`
- Touch targets mínimos: 44×44px

---

## Microinteracciones — timing estándar

| Interacción | Duración | Easing |
|-------------|----------|--------|
| Compra registrada | 600ms | ease-out |
| Stamp acumulado | 500ms | cubic-bezier(.34,1.56,.64,1) |
| Subida de nivel | 800ms | ease + glow pulse |
| Navegación entre vistas | 250ms | ease |
| Hover de botones | 200ms | ease |

`prefers-reduced-motion`: suprimir bounce y glow, mantener solo cambios de color.
