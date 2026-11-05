---
name: logo-grid
description: Build editable logo construction grids from an SVG using measured primitives; use when asked to explain a logo's geometry with construction lines and review images.
---

# Logo construction grids

Produce construction sheets that explain the supplied logo's actual geometry. Default to three directions, but propose fewer if the mark does not support three distinct systems. Directions may differ in emphasis; identify variations rather than claiming they are independent systems. Use the complete requested mark, and clarify the intended selection when an input contains multiple marks or a symbol and wordmark and the intended scope is ambiguous.

## Measure

The input must be an SVG with visible artwork converted to filled paths or primitive shapes: expand strokes and outline text first. Preserve the original. The helper reads shapes in SVG traversal order, applies transforms, and emits each shape's bounding box, segment endpoints and controls, and least-squares circle fits sampled at 60 points per segment. A fit is circular only when maximum radial error is below 1% of radius; this is evidence, not proof of a design intent. Inspect the artwork and the measurements together; exclude hidden, duplicate, or unrelated shapes by index. The helper does not resolve clipping, masks, filters, stroke expansion, or text and must not silently approximate them.

```sh
uv run /path/to/logo-grid/scripts/grid.py measure input.svg > measurements.json
```

Measure the selected overall bounds and center, symmetry and its error, repeated radii and proportions, straight edges and angles, tangencies, and significant anchors. Keep optical corrections and quantify approximate fits; never modify the mark to force a geometric theory.

## Design and render

Design each direction from measured relationships. Combine curves or circles, straight lines or extended edges, and meaningful anchors when supported by the mark; explain the whole selected mark. Prefer the strongest relationships, avoiding decorative, redundant, or near-coincident lines. Aim for roughly 25–35 elements, fewer when appropriate. Typical systems include circles and axes, Bézier anchors and handles, and proportional boxes and diagonals; do not impose these templates on an unrelated logo.

Write a JSON plan for each direction in the SVG's measured coordinate system. `shapes` is a nonempty array of indexes from `measure`. The optional `auxiliary`, `guides`, and `construction` arrays contain SVG primitives `line`, `circle`, `rect`, `polyline`, `polygon`, or `path`, with their usual SVG attributes and a `type` field. `anchors` contains objects with numeric `x` and `y`; add `square: true` for bounding-box corners. For example:

```json
{"shapes":[0],"construction":[{"type":"circle","cx":50,"cy":50,"r":40}],"guides":[{"type":"line","x1":0,"y1":50,"x2":100,"y2":50}],"anchors":[{"x":50,"y":50}]}
```

```sh
uv run /path/to/logo-grid/scripts/grid.py render input.svg direction.json output/direction-01
```

The output basename yields an editable SVG and a PNG for review; its directory must already exist. The SVG has named `auxiliary`, `guides`, `construction`, `logo`, and `anchors` groups in drawing order. It uses the supplied reference exports' visual attributes: 2560×1440, #f7f7f5 background, #999 auxiliary 1 px, #0080dc dashed guides 0.5 px (5/5), #4d4d4d construction 1 px, and a black 10% fill with #1f1f1f 2 px outline for the logo. Anchors are hollow 12 px, blue 1.5 px. The logo is centered on the canvas; its height is up to 612 px (42.5% of canvas height) and its width up to 1500 px. There is no text, dimensioning, legend, or color in the logo copy. Reference exports take precedence over the older runbook's different line weights and neutral-only palette.

## Review

Open every PNG. Check that the entire selected mark is faithfully reproduced, holes remain open, guides align with the measured features, lines are not nearly coincident, the logo remains dominant, and nothing is clipped or off-canvas. Check the groups and editable SVG as well. Simplify or correct the plan and render again if needed. Report measured bounds, symmetry and circle-fit errors, what each direction explains, approximations and discarded relationships, and any limitations that remain. If reference images were supplied, compare each result side by side with them and report visible differences.
