export const hairstyleFilters = [
  "All",
  "Short",
  "Long",
  "Medium",
  "Volume",
  "Updo",
  "Edgy",
];

export type HairStyle = {
  name: string;
  description: string;
  category: string;
  tone: string;
  texture: string;
};

export const hairStyles: HairStyle[] = [
  {
    name: "Classic Bob",
    description: "Blunt-cut precision with invisible lace part",
    category: "Short",
    tone: "Warm brunette",
    texture: "Sleek"
  },
  {
    name: "Long Wavy",
    description: "Soft waves with pre-plucked hairline",
    category: "Long",
    tone: "Chestnut",
    texture: "Wave"
  },
  {
    name: "Pixie Cut",
    description: "Feathery layers with temple blend tabs",
    category: "Short",
    tone: "Copper",
    texture: "Choppy"
  },
  {
    name: "Curly Full",
    description: "Defined coils + breathable mesh cap",
    category: "Volume",
    tone: "Espresso",
    texture: "Coily"
  },
  {
    name: "Straight Long",
    description: "Ultra sleek strands with HD lace",
    category: "Long",
    tone: "Jet black",
    texture: "Sleek"
  },
  {
    name: "Natural Afro",
    description: "Rounded silhouette with soft hold",
    category: "Volume",
    tone: "Mocha",
    texture: "Afro"
  },
  {
    name: "Layered Medium",
    description: "Face-framing angles for effortless balance",
    category: "Medium",
    tone: "Honey",
    texture: "Layered"
  },
  {
    name: "Bob with Bangs",
    description: "Curtain bang moment with airy density",
    category: "Short",
    tone: "Caramel",
    texture: "Sleek"
  },
  {
    name: "Beach Waves",
    description: "Tousled mid-length with flexible lace",
    category: "Medium",
    tone: "Sandy blonde",
    texture: "Wave"
  },
  {
    name: "Sleek Ponytail",
    description: "Snatched pony with wrap detail",
    category: "Updo",
    tone: "Espresso",
    texture: "Sleek"
  },
  {
    name: "Long Locs",
    description: "Hand-wrapped locs with tapered tips",
    category: "Long",
    tone: "Walnut",
    texture: "Locs"
  },
  {
    name: "Elegant Side Part",
    description: "Deep part glam with contouring layers",
    category: "Long",
    tone: "Dark chocolate",
    texture: "Layered"
  },
  {
    name: "Shaggy Layers",
    description: "Razor layers add instant movement",
    category: "Edgy",
    tone: "Melted toffee",
    texture: "Shag"
  },
  {
    name: "Finger Waves",
    description: "Vintage sculpt with glossy finish",
    category: "Edgy",
    tone: "Blackberry",
    texture: "Wave"
  },
  {
    name: "Curtain Bangs",
    description: "Soft parted fringe with airy density",
    category: "Medium",
    tone: "Butter blonde",
    texture: "Layered"
  },
  {
    name: "Faux Hawk",
    description: "Textured crown with tapered nape",
    category: "Edgy",
    tone: "Platinum",
    texture: "Textured"
  }
];

export const hairColors = [
  { label: "Natural Black", swatch: "#0f0d10" },
  { label: "Espresso", swatch: "#2f1b12" },
  { label: "Chestnut", swatch: "#4a2a18" },
  { label: "Copper", swatch: "#c56a2c" },
  { label: "Caramel", swatch: "#b68c5a" },
  { label: "Honey", swatch: "#d8ac63" },
  { label: "Butter Blonde", swatch: "#f4dfa8" },
  { label: "Rose", swatch: "#f7c1c0" },
  { label: "Icy", swatch: "#f5f5f5" }
];

export const faceFilters = [
  {
    name: "Glasses",
    options: ["Aviator", "Round", "Cat Eye"],
  },
  {
    name: "Earrings",
    options: ["Hoops", "Studs", "Statement"],
  },
  {
    name: "Makeup",
    options: ["Soft Glam", "Matte", "Gloss"],
  },
];

export const quickTips = [
  "Align hairline 1-2 finger widths above brows",
  "Check ear-to-ear line stays flat",
  "Center part should follow your natural part",
  "Temple tabs should blend at sideburn area"
];
