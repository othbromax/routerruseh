# Game Design Document: Route Rush

---

## 1. Overview

**Title:** Route Rush

**Platform:** Android (Google Play)

**Engine:** Flutter + Flame

**Orientation:** Portrait only

**Genre:** Arcade / Endless-style lane dodger with level-based progression

**Concept:** You are a courier driving a battered delivery vehicle through dangerous roads. You must reach the drop-off point before the deadline expires, dodging hazards that slow you down, damage your vehicle, or wreck you entirely. Between deliveries, you spend your earnings upgrading your vehicle to survive tougher routes.

---

## 2. Visual Identity

Route Rush has a gritty, industrial, road-worn aesthetic. It is not clean or polished. It feels like you are behind the wheel of a beat-up delivery truck on crumbling roads under pressure.

**Color Palette:**
- Primary tones: Dark charcoal asphalt, hazard mustard yellow, traffic cone orange.
- Secondary tones: Faded road-line white, oil-slick black, brake-light crimson, dashboard green.

**Textures:** Scuffed metal, cracked pavement, peeling paint, grimy paper, oil stains.

**Shapes:** Predominantly angular and sharp. Rounded shapes are reserved for dials, gauges, tires, and potholes. UI elements should feel like physical objects -- torn paper, metal plates, rubber stamps -- not clean digital interfaces.

**Motion:** Movements should feel abrupt and weighted. Elements drop, slam, or snap into place. Avoid smooth, floaty transitions. Menus should have a subtle idle vibration to simulate engine rumble.

---

## 3. Core Gameplay Loop

1. **Race:** The road scrolls vertically. The player's vehicle moves forward automatically. Speed increases as the player progresses.
2. **React:** The player steers left and right by dragging their thumb horizontally across the screen to dodge hazards.
3. **Recover:** Hitting a hazard applies a penalty (speed loss, steering drift, or structural damage). The player must adapt and continue.
4. **Reward:** Completing a route earns Hazard Pay (coins). Coins are spent in the Garage to upgrade the vehicle.

**Controls:** Horizontal drag input only. The player drags left or right anywhere on the lower portion of the screen to steer. The vehicle does not accelerate or brake manually; forward movement is automatic.

---

## 4. Hazards

There are three hazard types. Each has a distinct visual appearance and a unique penalty.

### Potholes
- **Appearance:** Dark, jagged craters in the road surface.
- **Penalty:** Speed instantly drops by 40% on impact. The vehicle slowly accelerates back to normal speed. The camera jolts briefly.
- **Threat level:** Low damage, high time cost. Forces the player to lose precious seconds against the deadline.

### Nails and Glass
- **Appearance:** Scattered debris fields that glint on the road.
- **Penalty:** Flat Tire effect. For 4 seconds after impact, the vehicle constantly drifts to one side, requiring the player to fight the steering to stay on the road.
- **Threat level:** Medium. Doesn't directly damage the vehicle or kill speed, but makes the player vulnerable to hitting other hazards while struggling with controls.

### Barricades
- **Appearance:** Heavy concrete and striped barriers blocking a lane.
- **Penalty:** Removes one point of Chassis Integrity (the vehicle has 3 total). Losing all 3 ends the run immediately.
- **Threat level:** High. The only hazard that can directly end a run. Forces sharp lateral movement to avoid.

---

## 5. HUD (Gameplay Screen)

The gameplay screen is the vertically scrolling road occupying the majority of the screen. The HUD elements sit around the edges, styled to look like dashboard instruments.

- **Chassis Integrity (bottom-left):** Three small indicator lights. Green when intact, dark/broken when lost. Represents remaining hit points against barricades.
- **Deadline Gauge (right edge):** A vertical gauge styled as a temperature/pressure meter. A needle climbs upward over time. If it reaches the red zone before the player hits the target distance, the run fails.
- **Distance Tracker (top-center):** A rolling odometer showing how far the player has traveled toward the route's target distance.
- **Pause Button (top-right):** A hazard light button. Tapping it pauses the game.

---

## 6. Screen Flow

### 6.1 Splash Screen
A brief branded intro. The game logo appears on a dark asphalt background. Headlight beams illuminate the logo. After a short moment, it transitions to the Main Menu.

### 6.2 Main Menu
Themed as the interior of the delivery vehicle's dashboard. The background shows a blurry street scene through a dirty windshield.

Available actions:
- **Turn Ignition** (Start Game): The primary and most prominent element. Begins the next available route.
- **The Garage** (Upgrades): Opens the vehicle upgrade screen.
- **Frequencies** (Settings): Opens sound and vibration toggles.
- **Survival Guide** (How to Play): Opens a brief illustrated tutorial.
- **Fine Print** (Privacy Policy): Opens the privacy policy.

### 6.3 Gameplay Screen
Described in Sections 4 and 5 above.

### 6.4 Pause Menu
Triggered by tapping the hazard light button during gameplay. The game freezes with a dark overlay.

Available actions:
- **Keep Driving** (Resume)
- **Abandon Route** (Quit to Main Menu)

### 6.5 Game Over -- Wrecked
Triggered when Chassis Integrity reaches 0. The screen gets a cracked-windshield overlay and desaturates. A "Tow Truck Invoice" drops in showing the run summary: distance covered, hazards hit, and reason for failure (Wrecked).

Available actions:
- **Take Another Shift** (Retry the same route)
- **Back to Depot** (Return to Main Menu)

### 6.6 Game Over -- Out of Time
Triggered when the Deadline Gauge fills before reaching the target distance. Same invoice layout as the Wrecked screen, but the reason for failure reads "Late".

Available actions: Same as 6.5.

### 6.7 Route Complete
Triggered when the player reaches the target distance before the deadline. A "Delivery Confirmation" receipt rolls up from the bottom showing the payout breakdown.

**Payout Calculation:**
- Base Route Pay: A fixed coin amount for completing the route.
- Time Bonus: Extra coins based on how much deadline gauge remained.
- Clean Ride Bonus: A coin multiplier if the player hit zero hazards.

Available actions:
- **Next Drop-off** (Proceed to the next route)
- **The Garage** (Go to upgrades)
- **Back to Depot** (Return to Main Menu)

### 6.8 The Garage (Upgrades)
A simple upgrade screen themed as a mechanic's workshop. The player's coin balance is displayed prominently.

Three upgrades, each with multiple tiers that increase in cost:
- **Suspension:** Reduces the speed penalty from potholes.
- **Tires:** Reduces the duration of the flat-tire drift from nails/glass.
- **Engine:** Increases the vehicle's top speed, giving more breathing room against the deadline.

Each upgrade shows its current tier, the cost to upgrade to the next tier, and a brief description of the improvement. If the player cannot afford an upgrade, it is visually dimmed.

### 6.9 Survival Guide (How to Play)
A brief, visual tutorial screen themed as a stained driver's manual. Uses simple illustrations (not text walls) to explain:
- Drag to steer.
- Avoid potholes (they slow you down).
- Avoid nails/glass (they mess up your steering).
- Avoid barricades (they damage your vehicle -- 3 hits and you're wrecked).
- Beat the deadline to deliver the package.

### 6.10 Settings (Frequencies)
A simple settings panel themed as a car radio dial interface.

Available toggles:
- Sound effects on/off.
- Music on/off (if background music is added).
- Vibration/haptic feedback on/off.

### 6.11 Privacy Policy (Fine Print)
Displays the privacy policy text within the app, styled as faded typewriter text on yellowed paper. The policy confirms no personal data is collected or shared. This same text is also hosted at an external URL for the Google Play listing.

---

## 7. Level Structure and Progression

The game has **10 routes** divided into three difficulty zones. Progression is linear -- the player must complete each route to unlock the next.

### Zone 1: The Suburbs (Routes 1-3)
- Wide road with 3 clear lanes.
- Only potholes appear.
- Generous deadline timer.
- Purpose: Teaches the player to steer and understand the deadline mechanic.

### Zone 2: The Industrial Zone (Routes 4-6)
- Road visually narrows slightly.
- Nails/glass debris is introduced.
- Barricades begin appearing, sometimes blocking an entire lane.
- Deadline gets tighter.
- Purpose: Introduces all three hazard types and forces lateral movement.

### Zone 3: The Gridlock (Routes 7-10)
- High hazard density.
- Hazards overlap (a barricade forces you into a lane that has nails).
- Deadline requires near-perfect driving to beat.
- Purpose: Tests mastery. Upgrades become essential.

**Spawning Rule:** Hazards must never form an impassable wall across all lanes. There must always be at least one safe path through any hazard grouping.

---

## 8. Win and Lose Conditions

- **Win:** The distance odometer reaches the route's target distance before the Deadline Gauge fills.
- **Lose (Wrecked):** Chassis Integrity drops to 0 from barricade hits.
- **Lose (Late/Fired):** The Deadline Gauge reaches the red zone before the target distance is reached.

---

## 9. Economy

- **Currency:** Hazard Pay (coins). Earned by completing routes.
- **Spending:** Coins are spent exclusively in the Garage on three vehicle upgrades (Suspension, Tires, Engine).
- **Balance Philosophy:** The economy should feel tight in the early game (encouraging replaying routes for extra coins) but not punishing. By Zone 3, the player should feel the difference their upgrades make.
- **No real-money purchases.** The game is entirely free with no microtransactions or ads.

---

## 10. Sound Design

Sound effects reinforce the gritty, physical feel of the game. All sounds should feel heavy and mechanical.

**Required Sound Effects:**
- Engine idle / revving (main menu ambiance and gameplay)
- Tire screech (steering sharply, pause trigger)
- Pothole crunch (dull, heavy thud)
- Nail/glass pop (sharp crack with a hiss)
- Barricade crash (heavy metallic crunch)
- Integrity light shatter (glass breaking)
- Deadline gauge warning (rising alarm tone when gauge passes 80%)
- Receipt printing (mechanical ticker sound on route complete)
- UI tap / button press (chunky mechanical click)
- Game over impact (heavy crash followed by silence)
- Ignition turn (engine cranking and roaring to life on game start)

**Music:** Optional. If included, a single low-energy, tension-building ambient loop during gameplay. The main menu can have a muffled radio static or distant engine hum.

---

## 11. Themed UI Terminology

| Standard Term | Route Rush Term | Where It Appears |
|:---|:---|:---|
| Play / Start | Turn Ignition | Main Menu |
| Upgrades | The Garage | Main Menu, Route Complete |
| Settings | Frequencies | Main Menu |
| Tutorial | Survival Guide | Main Menu |
| Health / Lives | Chassis Integrity | Gameplay HUD |
| Timer | Deadline Pressure | Gameplay HUD |
| Pause | Hit the Brakes | Gameplay |
| Resume | Keep Driving | Pause Menu |
| Quit to Menu | Abandon Route | Pause Menu |
| Game Over (damage) | Vehicle Totaled | Game Over Screen |
| Game Over (time) | Fired | Game Over Screen |
| Retry | Take Another Shift | Game Over Screen |
| Level Complete | Package Delivered | Route Complete Screen |
| Coins | Hazard Pay | Garage, Route Complete |
| Next Level | Next Drop-off | Route Complete Screen |
| Main Menu | The Depot | Various |

---

## 12. App Icon

The app icon has already been created. It depicts a fiery, glowing pothole in cracked asphalt with a construction barricade -- consistent with the game's hazard-themed identity. This icon is located at `assets/images/logo.png` and will be used for both the Android adaptive icon and the Play Store listing.
