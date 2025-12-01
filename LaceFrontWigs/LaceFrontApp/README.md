# LaceFrontApp – LaceFrontWigs Virtual Fitter

This is a Vite + React Single Page App that recreates the LaceFrontWigs "Virtual Fitter" experience from the Lovable mockup. It focuses on:

- A hero that calls out the live fitting flow and highlights the currently selected wig style
- A live preview panel with simulated tilt/offset telemetry and adjustable sliders
- Interactive grids for hair styles, tones, and accessory filters
- Quick stylist tips so users can double-check their lace placement

The app intentionally keeps all data client-side (no backend needed) so it can be hosted as a static site.

## Project structure

```
LaceFrontApp/
├── index.html            # Vite entrypoint
├── package.json          # npm scripts + deps
├── src/
│   ├── App.tsx           # main UI composition
│   ├── data.ts           # mock data + enums
│   ├── main.tsx          # React bootstrap
│   └── styles.css        # custom styling
└── vite.config.ts        # Vite + React SWC config
```

## Local development

You’ll need a Node 18+ runtime with npm 9+ installed. Once available:

```bash
npm install
npm run dev
```

The dev server defaults to <http://localhost:5173>. Use `npm run build` to create a production bundle and `npm run preview` to serve it locally.

> **Heads up:** The hosted environment that generated these files didn’t include Node.js, so the install/test commands above could not be executed here. Run them locally once you have Node available to verify everything end-to-end.
