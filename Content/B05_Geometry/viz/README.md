# 2D Rational Affine Space Visualization

This directory contains a Lean-powered geometry visualizer with a D3.js front end. Lean computes exact rational coordinates for points, vectors, and segments, then emits JSON that the browser renders as an interactive SVG.

## Viewing the Visualization

1. Start a local HTTP server from this directory:

   ```sh
   cd Content/B05_Geometry/viz
   python3 -m http.server 8080
   ```

2. Open <http://localhost:8080> in a browser.

Hover over points to see their exact rational coordinates.

## Editing the Scene

The scene is defined in `Main.lean`. It constructs geometric objects using types and functions from the library (`CS6501_Rational2D.lean`):

- `RPoint2` — a point with rational x, y coordinates
- `RVec2` — a displacement vector
- `midpoint2d p q` — midpoint of two points
- `affineInterp2d p q t` — affine interpolation at parameter t
- `lineThrough2d p q t` — parametric line through two points

JSON helpers convert these to renderable objects:

- `pointToJson "label" point` — a labeled point
- `vectorToJson "label" base vec` — an arrow from base along vec
- `segmentToJson "label" p q` — a line segment between two points

Edit the `scene` definition in `Main.lean` to change the geometry, then regenerate:

```sh
# From the project root
lake build geomviz
.lake/build/bin/geomviz > Content/B05_Geometry/viz/scene.json
```

Refresh the browser to see the updated visualization.

## File Overview

| File | Purpose |
|------|---------|
| `Main.lean` | Executable that builds a scene and prints JSON to stdout |
| `index.html` | D3.js visualization (single self-contained HTML file) |
| `scene.json` | Generated JSON consumed by D3.js (do not edit by hand) |
| `../chapters/CS6501_Rational2D.lean` | Library: 2D rational types, algebra, geometry functions, JSON serialization |
