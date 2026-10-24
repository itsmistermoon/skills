# Printed Material and Presentations — Imaquinaria

Applies to: physical stamp cards, store posters, flyers, PPTX presentations, Word documents, menus, product labels, workshop materials.

---

## Palette for print (approximate CMYK)

| Color | Hex | Approximate CMYK | Pantone ref |
|-------|-----|------------------|-------------|
| Primary red | `#E81036` | C:0 M:95 Y:77 K:0 | ~Pantone 185 C |
| Dark red | `#B90C2B` | C:0 M:95 Y:80 K:30 | ~Pantone 200 C |
| Brand black | `#211A23` | C:70 M:70 Y:60 K:80 | ~Pantone Black 6 C |
| Premium purple | `#4D2559` | C:65 M:85 Y:25 K:30 | ~Pantone 2617 C |
| White | `#FFFFFF` | C:0 M:0 Y:0 K:0 | — |
| Light background | `#F5F4F2` | C:2 M:2 Y:3 K:0 | — |

**Note:** always verify CMYK values with the print shop. Pantone is a reference, not an absolute value.

---

## Typography for print

| Use | Font | Weight | Minimum size |
|-----|------|--------|--------------|
| Titles / brand | Lemon Milk Bold | Bold | 18pt |
| Title substitute if Lemon Milk is unavailable | League Spartan | ExtraBold 800 | 18pt |
| Body text | Archivo | Regular 400 | 9pt |
| Subtitles | Archivo | Medium 500, wdth=125 | 12pt |
| Cultural accent | Noto Serif JP | 500 | 11pt |

Minimum legible printed text size: **8pt**.

---

## Logo in print

- Always use the original vector file (Illustrator / SVG)
- **Minimum size of the full logo:** 25mm wide
- **Minimum size of the mark alone:** 10mm
- In color print: red logo on white background (standard) or white logo on black `#211A23`
- In monochrome print: pure black logo (100% K) or white
- **Never** print the logo smaller than these minimums — it will pixelate or lose dragon detail

---

## Physical stamp cards

For printed cards designed as a complement or backup to the digital system:

### Card structure
```
┌─────────────────────────────────┐
│  [IMAQUINARIA LOGO]             │
│  Manga Shonen collection        │ ← Archivo semi-expanded, 14pt
│  Buy 8 manga, get one free      │ ← Archivo regular, 10pt
├─────────────────────────────────┤
│  ○ ○ ○ ○  ○ ○ ○ ○               │ ← Stamp circles, 18-20mm each
│     [customer name]             │ ← Archivo regular, 9pt
│     [issue date]                │
└─────────────────────────────────┘
```

(The sample copy inside the card is Spanish, as it appears on printed cards: "Colección Manga Shonen" and "Compra 8 mangas y lleva uno gratis".)

- Recommended size: 90×55mm (credit card) or 148×52mm (bookmark)
- Background: white or `#F5F4F2`
- Stamp circles: `#E81036` border, 1.5pt; fill when stamped: `#E81036`
- Minimum paper: 300g/m² for durability

---

## Store posters

### Standard visual hierarchy
1. **Visual element** (photo, illustration, or large dragon mark) — 50-60% of the area
2. **Headline** — Lemon Milk / League Spartan, uppercase, `#E81036` or black
3. **Subtitle** — Archivo semi-expanded
4. **Body** — Archivo regular
5. **Logo** — bottom-right or bottom-centered corner

### Common sizes
| Format | Size | Resolution |
|--------|------|------------|
| A4 portrait (shop window) | 210×297mm | 300 DPI |
| A3 (indoor poster) | 297×420mm | 300 DPI |
| 50×70cm (poster) | 500×700mm | 150 DPI minimum |
| Roll-up (event) | 850×2000mm | 100 DPI |

---

## PPTX presentations

For generating `.pptx` presentations with the Imaquinaria brand, also consult the `pptx` skill for the mechanics of creating the file.

### Slide palette

| Element | Color |
|---------|-------|
| Cover background | `#211A23` (brand black) |
| Content slide background | `#FFFFFF` |
| Alternative background (dark) | `#F5F4F2` |
| Titles on dark background | `#FFFFFF` |
| Titles on light background | `#211A23` |
| Accent / highlights | `#E81036` |
| Secondary text | `#5A5258` |

### Cover layout
```
Background: #211A23
- Full logo centered (or large mark)
- Title in white, League Spartan ExtraBold 800, uppercase, centered
- Subtitle in Archivo regular, #9E9399
- Decorative line: 3px, #E81036, 80px wide, centered under the title
```

### Content slide layout
```
- Top bar: 8px high, color #E81036 (full width)
- Small mark: top-right corner, 32px
- Title: League Spartan ExtraBold / Lemon Milk, 28pt, #211A23
- Body: Archivo Regular, 16pt, #5A5258
- Footer: "Imaquinaria" in Archivo 10pt #5A5258, centered
```

### Recurring decorative element
The origami dragon may appear as a watermark in the bottom-right corner of content slides: opacity 5-8%, color `#E81036`.

---

## Flyers / static social media (print or digital)

See also `references/social.md` for the specific proportions of each platform.

### Basic flyer structure

```
┌─────────────────────────────┐
│                             │
│   [Large visual element]    │  ← 50-65% of the area
│                             │
├─────────────────────────────┤  ← #E81036 line, 3px
│ HEADLINE IN UPPERCASE       │  ← Lemon Milk / League Spartan, large
│ Descriptive subtitle        │  ← Archivo semi-expanded
│ Details: date, place, etc.  │  ← Archivo regular
│                      [LOGO] │
└─────────────────────────────┘
```

Preferred background: white `#FFFFFF` or black `#211A23`. Avoid red backgrounds — red is for actions, not backgrounds.
