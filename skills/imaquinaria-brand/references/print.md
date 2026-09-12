# Material Impreso y Presentaciones — Imaquinaria

Aplica a: cartillas físicas de sello, carteles de tienda, flyers, presentaciones
PPTX, documentos Word, menús, etiquetas de productos, materiales de taller.

---

## Paleta para impresión (CMYK equivalentes)

| Color | Hex | CMYK aproximado | Pantone ref |
|-------|-----|-----------------|-------------|
| Rojo principal | `#E81036` | C:0 M:95 Y:77 K:0 | ~Pantone 185 C |
| Rojo oscuro | `#B90C2B` | C:0 M:95 Y:80 K:30 | ~Pantone 200 C |
| Negro de marca | `#211A23` | C:70 M:70 Y:60 K:80 | ~Pantone Black 6 C |
| Púrpura premium | `#4D2559` | C:65 M:85 Y:25 K:30 | ~Pantone 2617 C |
| Blanco | `#FFFFFF` | C:0 M:0 Y:0 K:0 | — |
| Fondo claro | `#F5F4F2` | C:2 M:2 Y:3 K:0 | — |

**Nota:** verificar siempre los valores CMYK con la imprenta. Pantone es referencia,
no valor absoluto.

---

## Tipografía para impresión

| Uso | Fuente | Peso | Tamaño mínimo |
|-----|--------|------|----------------|
| Títulos / marca | Lemon Milk Bold | Bold | 18pt |
| Sustituto de títulos si no hay Lemon Milk | League Spartan | ExtraBold 800 | 18pt |
| Cuerpo de texto | Archivo | Regular 400 | 9pt |
| Subtítulos | Archivo | Medium 500, wdth=125 | 12pt |
| Acento cultural | Noto Serif JP | 500 | 11pt |

Tamaño mínimo de texto legible impreso: **8pt**.

---

## Logo en impresión

- Usar siempre el archivo vectorial original (Illustrator / SVG)
- **Tamaño mínimo del logo completo:** 25mm de ancho
- **Tamaño mínimo del isotipo solo:** 10mm
- En impresión a color: logo rojo sobre fondo blanco (estándar) o logo blanco sobre negro `#211A23`
- En impresión monocromática: logo negro puro (100% K) o blanco
- **Nunca** imprimir el logo en tamaño menor a los mínimos — pixelará o perderá detalles del dragón

---

## Cartillas de sello físicas

Para cuando se diseñen cartillas impresas como complemento o respaldo del sistema digital:

### Estructura de la cartilla
```
┌─────────────────────────────────┐
│  [LOGO IMAQUINARIA]             │
│  Colección Manga Shonen         │ ← Archivo semi-expanded, 14pt
│  Compra 8 mangas y lleva uno gratis │ ← Archivo regular, 10pt
├─────────────────────────────────┤
│  ○ ○ ○ ○  ○ ○ ○ ○               │ ← Círculos de sello, 18-20mm c/u
│     [nombre del cliente]        │ ← Archivo regular, 9pt
│     [fecha de emisión]          │
└─────────────────────────────────┘
```

- Tamaño recomendado: 90×55mm (tarjeta de crédito) o 148×52mm (bookmark)
- Fondo: blanco o `#F5F4F2`
- Círculos de sello: borde `#E81036`, 1.5pt; relleno al sellar: `#E81036`
- Papel mínimo: 300g/m² para durabilidad

---

## Carteles de tienda

### Jerarquía visual estándar
1. **Elemento visual** (foto, ilustración, o isotipo dragón grande) — 50-60% del área
2. **Titular** — Lemon Milk / League Spartan, mayúsculas, `#E81036` o negro
3. **Subtítulo** — Archivo semi-expanded
4. **Cuerpo** — Archivo regular
5. **Logo** — esquina inferior derecha o inferior centrado

### Tamaños frecuentes
| Formato | Tamaño | Resolución |
|---------|--------|------------|
| A4 vertical (vitrina) | 210×297mm | 300 DPI |
| A3 (cartel interior) | 297×420mm | 300 DPI |
| 50×70cm (póster) | 500×700mm | 150 DPI mínimo |
| Roll-up (evento) | 850×2000mm | 100 DPI |

---

## Presentaciones PPTX

Para generar presentaciones `.pptx` con la marca Imaquinaria, consultar también
el skill `pptx` para la mecánica de creación del archivo.

### Paleta de diapositivas

| Elemento | Color |
|----------|-------|
| Fondo de portada | `#211A23` (negro de marca) |
| Fondo de slides de contenido | `#FFFFFF` |
| Fondo alternativo (oscuro) | `#F5F4F2` |
| Títulos en fondo oscuro | `#FFFFFF` |
| Títulos en fondo claro | `#211A23` |
| Acento / highlights | `#E81036` |
| Texto secundario | `#5A5258` |

### Layout de portada
```
Fondo: #211A23
- Logo completo centrado (o isotipo grande)
- Título en blanco, League Spartan ExtraBold 800, mayúsculas, centrado
- Subtítulo en Archivo regular, #9E9399
- Línea decorativa: 3px, #E81036, ancho 80px, centrada bajo el título
```

### Layout de slide de contenido
```
- Barra superior: 8px de altura, color #E81036 (full-width)
- Isotipo pequeño: esquina superior derecha, 32px
- Título: League Spartan ExtraBold / Lemon Milk, 28pt, #211A23
- Cuerpo: Archivo Regular, 16pt, #5A5258
- Pie: "Imaquinaria" en Archivo 10pt #5A5258, centrado
```

### Elemento decorativo recurrente
El dragón de origami puede aparecer como marca de agua en esquina inferior
derecha de slides de contenido: opacidad 5-8%, color `#E81036`.

---

## Flyers / social media estático (para impresión o digital)

Ver también `references/social.md` para las proporciones específicas de cada plataforma.

### Estructura básica de flyer

```
┌─────────────────────────────┐
│                             │
│   [Elemento visual grande]  │  ← 50-65% del área
│                             │
├─────────────────────────────┤  ← línea #E81036, 3px
│ TITULAR EN MAYÚSCULAS       │  ← Lemon Milk / League Spartan, grande
│ Subtítulo descriptivo       │  ← Archivo semi-expanded
│ Detalle: fecha, lugar, etc  │  ← Archivo regular
│                      [LOGO] │
└─────────────────────────────┘
```

Fondo preferido: blanco `#FFFFFF` o negro `#211A23`. Evitar fondos de color rojo —
el rojo es de acción, no de fondo.
