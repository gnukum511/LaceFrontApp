import { useMemo, useState } from "react";
import {
  faceFilters,
  hairColors,
  hairStyles,
  hairstyleFilters,
  quickTips,
  type HairStyle,
} from "./data";

const accentPalette = [
  "linear-gradient(135deg, #ff6cab 0%, #7366ff 100%)",
  "linear-gradient(135deg, #fed365 0%, #f97316 100%)",
  "linear-gradient(135deg, #2dd4bf 0%, #0ea5e9 100%)",
  "linear-gradient(135deg, #c084fc 0%, #6366f1 100%)",
  "linear-gradient(135deg, #f43f5e 0%, #fb7185 100%)",
];

const getAccent = (index: number) => accentPalette[index % accentPalette.length];

const randomFrom = <T,>(items: T[]): T => items[Math.floor(Math.random() * items.length)];

function App() {
  const [selectedFilter, setSelectedFilter] = useState<string>("All");
  const [selectedColor, setSelectedColor] = useState(hairColors[0]);
  const [activeAccessories, setActiveAccessories] = useState<Record<string, string | null>>({
    Glasses: null,
    Earrings: null,
    Makeup: null,
  });
  const [tilt, setTilt] = useState(0);
  const [offset, setOffset] = useState(0);
  const [verticalOffset, setVerticalOffset] = useState(50);
  const [horizontalOffset, setHorizontalOffset] = useState(50);
  const [highlightedStyle, setHighlightedStyle] = useState<HairStyle>(() => hairStyles[0]);

  const visibleStyles = useMemo(() => {
    if (selectedFilter === "All") return hairStyles;
    return hairStyles.filter((style) => style.category === selectedFilter);
  }, [selectedFilter]);

  const statusMessage = useMemo(() => {
    if (Math.abs(tilt) > 5) {
      return `Rotate ${tilt > 0 ? "clockwise" : "counter-clockwise"} by ${Math.abs(tilt).toFixed(1)}°`;
    }
    if (Math.abs(offset) > 4) {
      return `Shift lace ${offset > 0 ? "down" : "up"} by ${Math.abs(offset).toFixed(0)} px`;
    }
    return "Great balance! Save this look.";
  }, [tilt, offset]);

  const handleAccessoryToggle = (group: string, option: string) => {
    setActiveAccessories((prev) => ({
      ...prev,
      [group]: prev[group] === option ? null : option,
    }));
  };

  const randomizeStyle = () => {
    const suggestions = visibleStyles.length ? visibleStyles : hairStyles;
    const pick = randomFrom(suggestions);
    setHighlightedStyle(pick);
  };

  return (
    <div className="app-shell">
      <header className="hero">
        <div className="hero-content">
          <p className="badge">Virtual Fitter</p>
          <h1>LaceFrontWigs Live Studio</h1>
          <p className="lede">
            Position your face inside the guide, then explore lace placements, accessories, and colors tailored to
            your unique proportions.
          </p>
          <div className="hero-actions">
            <button className="primary">Position face in frame</button>
            <button className="ghost" onClick={randomizeStyle}>
              Random suggestion
            </button>
          </div>
          <div className="status-group">
            <div className="status-chip live">
              <span className="dot" /> LIVE
            </div>
            <div className="status-chip ghost">Model: Vision Pro 26 · Ultra HD Lace</div>
            <div className="status-chip ghost">AI Models: FaceMesh + Landmark V3</div>
          </div>
        </div>
        <div className="hero-panel">
          <div className="panel-head">
            <span>Currently highlighting</span>
            <strong>{highlightedStyle.name}</strong>
          </div>
          <p>{highlightedStyle.description}</p>
          <ul>
            <li>Category · {highlightedStyle.category}</li>
            <li>Tone · {highlightedStyle.tone}</li>
            <li>Texture · {highlightedStyle.texture}</li>
          </ul>
          <div className="color-chip" style={{ background: selectedColor.swatch }}>
            {selectedColor.label}
          </div>
        </div>
      </header>

      <main className="grid">
        <section className="live-panel">
          <div className="preview">
            <div className="preview-frame">
              <div className="grid-lines" />
              <div
                className="face-target"
                style={{
                  transform: `translate(${horizontalOffset - 50}%, ${verticalOffset - 50}%)`,
                }}
              >
                <span />
              </div>
              <div className="preview-overlay">
                <p>Searching for face…</p>
                <small>{statusMessage}</small>
              </div>
            </div>
            <div className="preview-controls">
              <label>
                Tilt {tilt.toFixed(1)}°
                <input type="range" min={-15} max={15} value={tilt} onChange={(e) => setTilt(Number(e.target.value))} />
              </label>
              <label>
                Offset {offset.toFixed(0)}px
                <input type="range" min={-10} max={10} value={offset} onChange={(e) => setOffset(Number(e.target.value))} />
              </label>
              <label>
                Vertical {verticalOffset}%
                <input
                  type="range"
                  min={0}
                  max={100}
                  value={verticalOffset}
                  onChange={(e) => setVerticalOffset(Number(e.target.value))}
                />
              </label>
              <label>
                Horizontal {horizontalOffset}%
                <input
                  type="range"
                  min={0}
                  max={100}
                  value={horizontalOffset}
                  onChange={(e) => setHorizontalOffset(Number(e.target.value))}
                />
              </label>
            </div>
          </div>
          <div className="readout">
            <div>
              <p>TILT</p>
              <h2>{tilt.toFixed(1)}°</h2>
            </div>
            <div>
              <p>OFFSET</p>
              <h2>{offset.toFixed(0)} px</h2>
            </div>
            <div>
              <p>COLOR</p>
              <h2>{selectedColor.label}</h2>
            </div>
            <div>
              <p>ACCESSORIES</p>
              <h2>
                {Object.entries(activeAccessories)
                  .map(([group, selection]) => (selection ? `${group}: ${selection}` : `${group}: none`))
                  .join(" · ")}
              </h2>
            </div>
          </div>
        </section>

        <section className="styles-panel">
          <header className="panel-header">
            <div>
              <p className="eyebrow">HAIR STYLES</p>
              <h2>Explore fits that match your capture</h2>
            </div>
            <div className="filter-chips">
              {hairstyleFilters.map((filter) => (
                <button
                  key={filter}
                  className={filter === selectedFilter ? "chip active" : "chip"}
                  onClick={() => setSelectedFilter(filter)}
                >
                  {filter}
                </button>
              ))}
            </div>
          </header>

          <div className="style-grid">
            {visibleStyles.map((style, index) => (
              <article key={style.name} className="style-card" style={{ background: getAccent(index) }}>
                <div>
                  <p className="eyebrow">{style.category}</p>
                  <h3>{style.name}</h3>
                  <p>{style.description}</p>
                </div>
                <footer>
                  <span>{style.tone}</span>
                  <span>{style.texture}</span>
                </footer>
              </article>
            ))}
          </div>
        </section>

        <section className="color-panel">
          <header>
            <p className="eyebrow">HAIR COLOR</p>
            <h2>Instant tone swapping</h2>
          </header>
          <div className="color-grid">
            {hairColors.map((color) => (
              <button
                key={color.label}
                className={color.label === selectedColor.label ? "color-swatch active" : "color-swatch"}
                style={{ background: color.swatch }}
                onClick={() => setSelectedColor(color)}
              >
                <span>{color.label}</span>
              </button>
            ))}
          </div>
        </section>

        <section className="filters-panel">
          <header>
            <p className="eyebrow">FACE FILTERS</p>
            <h2>Layer on accessories</h2>
          </header>
          <div className="filters-grid">
            {faceFilters.map((group) => (
              <div key={group.name} className="filter-card">
                <h3>{group.name}</h3>
                <div className="filter-options">
                  {group.options.map((option) => (
                    <button
                      key={option}
                      className={activeAccessories[group.name] === option ? "chip active" : "chip"}
                      onClick={() => handleAccessoryToggle(group.name, option)}
                    >
                      {option}
                    </button>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </section>

        <section className="tips-panel">
          <header>
            <p className="eyebrow">Quick Tips</p>
            <h2>Stylist-approved alignment cues</h2>
          </header>
          <div className="tips-grid">
            {quickTips.map((tip, index) => (
              <article key={tip} className="tip-card">
                <span className="tip-index">{index + 1}</span>
                <p>{tip}</p>
              </article>
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}

export default App;
