# Design Language System: Route Rush

---

## 1. Philosophy

Every visual element in Route Rush should feel like it belongs inside a beat-up delivery vehicle. Nothing should look like a standard mobile app. Interfaces are physical objects: torn paper, metal plates, rubber stamps, gauge dials, greasy clipboards. The overall tone is harsh, tactile, and slightly anxious.

Three guiding principles:

- **Diegetic:** UI elements exist within the world of the game. Buttons look like things you'd find in a truck cab. Screens look like documents, receipts, or dashboard instruments.
- **Heavy and Abrupt:** Elements have weight. They slam, snap, and drop. Nothing floats or fades gently.
- **Worn and Imperfect:** Edges are rough. Surfaces are stained. Alignment can be slightly off to feel organic. Perfect symmetry should be avoided where possible.

---

## 2. Color Palette

### Backgrounds and Surfaces
| Name | Hex Code | Usage |
|:---|:---|:---|
| Sun-Baked Asphalt | #2A2B2E | Main menu backdrop, road surface, dark panels |
| Scuffed Black | #121212 | Deep shadows, dashboard plastic, overlays |
| Grimy Paper | #E8E3D8 | Receipts, invoices, sticky notes, tutorial pages |

### Actions and Highlights
| Name | Hex Code | Usage |
|:---|:---|:---|
| Hazard Mustard | #F4C430 | Primary action elements, highlighted text, key UI accents |
| Traffic Cone Orange | #FF5A00 | Secondary actions, warning states, urgent indicators |

### Status Indicators
| Name | Hex Code | Usage |
|:---|:---|:---|
| Brake Light Crimson | #D10000 | Negative states, failure, danger zone on deadline gauge |
| Dashboard Green | #39FF14 | Positive states, intact integrity lights, success |
| Faded Road-Line White | #D9D9D9 | Body text on dark backgrounds, subtle separators |

**Usage Rule:** Hazard Mustard is the dominant accent color. It draws the eye to the most important interactive element on any given screen. Traffic Cone Orange is used sparingly as a secondary call-to-action or warning. Crimson appears only in failure or danger states. Green appears only for positive/healthy status.

---

## 3. Typography

**Font Family:** Teko (Google Font)

Teko is a dense, square-proportioned, condensed sans-serif. It resembles stamped metal lettering on license plates and mechanical odometer digits. It feels industrial, urgent, and highly readable at all sizes.

### Hierarchy
| Role | Weight | Size Range | Style |
|:---|:---|:---|:---|
| Display (Route Complete, Wrecked, big headings) | Bold | 56-64pt | All caps, may be slightly rotated for a stamped feel |
| Header (Menu labels, section titles) | SemiBold | 32-40pt | All caps |
| Body (HUD values, coin counts, descriptions) | Regular | 20-24pt | Normal case or all caps depending on context |
| Fine Print (Receipt details, privacy policy) | Light | 14-16pt | Normal case |

**Line Height:** Keep tight at 1.1 to 1.2. The compressed feel matches the font's industrial character and the game's claustrophobic tension.

---

## 4. Spacing and Touch Targets

**Grid System:** All padding and margins should follow an 8-point grid (multiples of 8: 8, 16, 24, 32, 48, 64). This keeps spacing consistent and rhythmic across all screens.

**Minimum Touch Area:** Every interactive element must have a tap area of at least 48x48 logical pixels. This is critical during gameplay where the player is under stress and precision tapping would be frustrating.

**Safe Zones:** All full-screen UI must respect device safe areas (notches, rounded corners, navigation bars) so that critical elements like the Deadline Gauge and Integrity Lights are never obscured.

**Layout Approach:** Use relative/proportional sizing rather than fixed pixel dimensions so the game adapts to different screen sizes and aspect ratios.

---

## 5. Layout Principles

**Asymmetrical Placement:** Avoid centering everything. Menu elements should sit where physical objects would naturally rest -- a clipboard in the bottom-right, a sticky note stuck at an angle, a gauge running along the right edge. Perfect centering is reserved for impact moments like the Game Over stamp.

**Depth and Layering:** Create a sense of physical depth using hard, solid-color offset shadows (not soft blurred glows). A button should look like it's sitting on top of the surface, casting a sharp 4-pixel shadow in Scuffed Black.

**HUD Ergonomics:**
- Left side: Non-interactive status information (Chassis Integrity lights). This is the passive glance zone.
- Right side: Interactive elements (Pause button) and high-priority tracking (Deadline Gauge). This is the active thumb zone.
- Top center: Distance odometer. Quick reference at the periphery of attention.

---

## 6. UI Element Styling

### Buttons
- Rectangular with sharp edges (no rounded corners, or minimal 2px rounding at most).
- Default state: Hazard Mustard background, Scuffed Black text, hard 4px drop shadow in Scuffed Black.
- Pressed state: Shadow disappears, button visually shifts down and to the right by 4px, background darkens slightly. This creates a physical "pressed into the surface" feeling.
- Borders: 2px solid border in a shade slightly darker than the background color.

### Paper Elements (Receipts, Invoices, Sticky Notes)
- Background color: Grimy Paper.
- Edges should appear torn or rough where appropriate (top or bottom edge of receipts).
- When paper elements appear over the game, the background behind them should dim significantly with a dark semi-transparent overlay.

### Gauges and Meters
- The Deadline Gauge is a vertical curved meter, not a flat progress bar.
- Color progression along the gauge: starts at Faded Road-Line White, transitions to Hazard Mustard at around 70% full, and flashes Brake Light Crimson at 90%+.
- The needle or fill indicator should feel analog, not digital.

### Integrity Lights
- Three small circular lights.
- Active/healthy: Dashboard Green with a subtle glow.
- Destroyed: Dark, cracked appearance. The transition from green to broken should be instant and jarring, not a smooth fade.

---

## 7. Motion and Animation

All motion in Route Rush should create a subtle sense of urgency and physicality. Avoid default smooth ease-in-out curves.

**Screen Transitions:** Elements drop in from above with a heavy bounce, or snap into position instantly. They should feel like they have mass.

**Button Feedback:** Instant snap down on press, quick spring back on release. No lag, no slow animations.

**Idle Ambiance:** The Main Menu dashboard should have a constant, very subtle position jitter (1-2 pixels randomly on X and Y axes) to simulate engine vibration. This keeps the screen feeling alive.

**Error Feedback:** When the player tries an invalid action (like buying an upgrade they can't afford), the element should shake rapidly side-to-side for a brief moment. Not a color change alone -- physical movement.

**Gameplay Effects:**
- Hitting a pothole: Brief camera jolt (the whole viewport shifts and snaps back).
- Hitting nails/glass: No camera effect, but the vehicle visually wobbles as it drifts.
- Hitting a barricade: Strong screen shake, one integrity light instantly shatters.
- Deadline gauge entering danger zone: The gauge needle begins to tremble.

---

## 8. Iconography and Visual Motifs

Route Rush does not use standard mobile UI icons (hamburger menus, gear icons, arrows). Instead:

- **Start Game:** Represented by an ignition key or a key-turn motion.
- **Settings:** Represented by radio dials.
- **Tutorial:** Represented by a sticky note or a dog-eared manual.
- **Upgrades:** Represented by a clipboard or wrench.
- **Pause:** Represented by hazard/warning lights.
- **Currency (Hazard Pay):** Represented by a coin with a pothole or road-hazard emblem.

Every icon should feel like it belongs in a vehicle. If it looks like it came from a generic icon pack, it doesn't belong here.
