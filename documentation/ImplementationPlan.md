# Implementation Plan: Route Rush

This is the end-to-end build plan for Route Rush, ordered by phase. Each phase builds on the previous one. Do not skip phases. Each phase ends with a clear verification step so you know it's done before moving on.

The guiding principle across every phase: **keep it simple.** Use built-in Flutter and Flame solutions wherever possible. Avoid third-party packages unless they solve a problem that would otherwise take significant effort. Do not over-engineer.

---

## Phase 1: Project Foundation

**Goal:** A running Flutter app with Flame embedded, ready for game development.

**Tasks:**
1. Create a new Flutter project targeting Android only.
2. Add the Flame engine as a dependency.
3. Lock the app to portrait orientation.
4. Set up the basic app structure: a single screen that hosts a Flame GameWidget inside a Flutter layout with an overlay system. The Flutter layer will render all menus and HUD elements on top of the Flame game canvas.
5. Create a lightweight state management approach using Flutter's built-in tools (no third-party state management packages). The state to manage is minimal: current screen, lives, coins, current route number, and upgrade levels.
6. Organize the project folder structure with clear separation: screens (Flutter UI), game (Flame components), data (level definitions and upgrade data), and assets (images, fonts, sounds).

**Why this matters:** Proves the engine runs, the overlay system works, and the project structure is clean before any game logic is written.

**Verify:** The app compiles and runs on a physical Android device. You see the Flame canvas (a blank or colored screen) with a temporary Flutter button overlaid on top. Tapping the button hides it and shows the Flame canvas underneath. The app is locked to portrait.

---

## Phase 2: Core Gameplay -- The Drive

**Goal:** The fundamental gameplay experience works: a scrolling road, a moving player, and collision detection.

**Tasks:**
1. Create a vertically scrolling road background using Flame's parallax system. The road should have lane markings and scroll continuously downward to create the illusion of forward movement.
2. Create the player vehicle as a simple game component positioned in the bottom third of the screen. It moves left and right in response to horizontal drag input anywhere on the lower half of the screen.
3. Constrain the player vehicle to stay within the road boundaries (it cannot drive off the edges).
4. Create a basic obstacle spawner that generates simple rectangular hazards at random horizontal positions above the visible screen and moves them downward with the road scroll.
5. Implement collision detection between the player vehicle and obstacles using Flame's built-in hitbox and collision callback system.
6. For now, all obstacles are identical placeholder rectangles. Differentiation comes in Phase 4.

**Why this matters:** This is the heartbeat of the game. If the core feel of dodging obstacles on a scrolling road isn't satisfying, nothing else matters. Get this right first.

**Verify:** The road scrolls smoothly. Dragging your thumb moves the vehicle left and right. Rectangular obstacles fall from the top. When the vehicle touches an obstacle, a debug message prints to the console confirming the collision. The vehicle cannot leave the road area.

---

## Phase 3: Screens and Navigation Flow

**Goal:** The complete screen flow from the GDD is built in Flutter, wrapping the Flame gameplay in a full app experience.

**Tasks:**
1. Build the **Splash Screen** (GDD 6.1): The game logo on an asphalt background with a brief headlight animation, auto-transitioning to the Main Menu.
2. Build the **Main Menu** (GDD 6.2): Dashboard-themed screen with buttons for Turn Ignition, The Garage, Frequencies, Survival Guide, and Fine Print. Style all elements according to the Design Language System. The "Turn Ignition" button is the most prominent element.
3. Build the **Gameplay HUD overlay** (GDD Section 5): Chassis Integrity lights (bottom-left), Deadline Gauge (right edge), Distance odometer (top-center), and Pause button (top-right). These are Flutter widgets overlaid on the Flame game canvas.
4. Build the **Pause Menu** (GDD 6.4): Dark overlay with "Keep Driving" and "Abandon Route" options. Pausing freezes the Flame game loop.
5. Build the **Game Over screen** (GDD 6.5 / 6.6): The Tow Truck Invoice showing run stats and failure reason, with "Take Another Shift" and "Back to Depot" buttons.
6. Build the **Route Complete screen** (GDD 6.7): The Delivery Confirmation receipt showing payout breakdown (base pay, time bonus, clean ride bonus), with "Next Drop-off", "The Garage", and "Back to Depot" buttons.
7. Build the **Garage screen** (GDD 6.8): Upgrade screen showing three upgrades (Suspension, Tires, Engine), each with its current tier, next-tier cost, and a brief description. The player's Hazard Pay balance is shown prominently. Upgrades that can't be afforded are visually dimmed.
8. Build the **Survival Guide screen** (GDD 6.9): A simple illustrated tutorial showing how to steer, what each hazard does, and the win condition. Use simple drawings or icons, not text walls.
9. Build the **Settings screen** (GDD 6.10): Toggles for sound effects, music, and vibration/haptics.
10. Build the **Privacy Policy screen** (GDD 6.11): Scrollable text styled as typewriter text on aged paper.

**Styling note for all screens:** Follow the Design Language System strictly. Use the Teko font, the defined color palette, the 8-point spacing grid, sharp-edged buttons with hard shadows, and asymmetrical layout. Refer to the DLS document for exact styling rules on buttons, paper elements, gauges, and motion.

**Why this matters:** This transforms the prototype into a complete application. The player can navigate every screen and the game feels like a finished product, even before the mechanics are fully implemented.

**Verify:** You can launch the app, see the splash screen, arrive at the Main Menu, tap "Turn Ignition" to enter gameplay, pause the game, resume, abandon the route back to the menu, trigger a test game-over event and see the invoice screen, and trigger a test win event and see the receipt screen. All screens use the correct fonts, colors, and styling from the DLS.

---

## Phase 4: Game Mechanics -- Hazards, Penalties, and Win/Lose

**Goal:** The three hazard types from the GDD are fully implemented with their distinct penalties, and the win/lose conditions function correctly.

**Tasks:**
1. Replace the generic placeholder obstacles with three distinct types: Potholes, Nails/Glass, and Barricades. Each should be visually distinguishable (different shapes and colors at minimum, sprites later in Phase 6).
2. Implement the **Pothole penalty:** On collision, the road scroll speed and obstacle speed instantly drop by 40%, then gradually tween back to normal speed over a few seconds. Trigger a brief camera jolt (the viewport shifts and snaps back).
3. Implement the **Nails/Glass penalty:** On collision, apply a constant horizontal drift force to the player vehicle for 4 seconds. The drift direction is random (left or right). The player must counteract it with their steering input.
4. Implement the **Barricade penalty:** On collision, reduce Chassis Integrity by 1 and update the HUD. Trigger a screen shake. If Integrity reaches 0, end the run and show the "Vehicle Totaled" Game Over screen.
5. Implement the **Deadline Gauge:** A timer that fills gradually during gameplay. The fill rate is defined per route (faster on harder routes). If the gauge fills completely before the player reaches the target distance, end the run and show the "Fired" Game Over screen.
6. Implement the **Distance Tracker:** Track how far the player has traveled (based on elapsed time and current scroll speed). When the target distance for the current route is reached, end the run successfully and show the Route Complete screen.
7. Implement the **Payout Calculation** on Route Complete: Base Route Pay + Time Bonus (based on remaining deadline gauge) + Clean Ride Bonus (multiplier if zero hazards hit). Add the total to the player's Hazard Pay balance.
8. Implement the **spawning safety rule:** When spawning hazards, ensure that at least one lane is always clear. Never create an impassable wall of obstacles.

**Why this matters:** This phase turns a scrolling-road tech demo into an actual game with real stakes, real tension, and the full risk/reward loop described in the GDD.

**Verify:** Each hazard type produces its correct penalty on collision. Hitting 3 barricades ends the game with the Wrecked screen. Running out of time ends the game with the Fired screen. Completing the distance shows the receipt with a calculated payout. The payout is added to the player's coin balance. No hazard pattern is impossible to dodge.

---

## Phase 5: Progression, Economy, and Persistence

**Goal:** The game has a 10-route progression with escalating difficulty, a functioning upgrade economy, and data that persists between sessions.

**Tasks:**
1. Define all 10 routes as a data structure. Each route specifies: target distance, deadline gauge fill rate, obstacle spawn rate, which hazard types can appear, and base pay reward. Difficulty increases with each route according to the three zones defined in the GDD (Suburbs, Industrial Zone, Gridlock).
2. Implement route unlocking: completing a route unlocks the next one. The player always starts at the highest unlocked route when pressing Turn Ignition (with the option to replay earlier routes if desired -- this is optional and low priority).
3. Implement the three Garage upgrades (Suspension, Tires, Engine). Each has 3 to 5 upgrade tiers with increasing cost. Define the effect values for each tier (how much the pothole penalty is reduced, how many seconds the flat-tire drift is shortened by, how much top speed increases). These values go into the same data structure as the route definitions for easy tuning.
4. Wire up the Garage screen so purchasing an upgrade deducts coins and immediately applies the upgrade effect to future gameplay sessions.
5. Implement local data persistence using a simple key-value storage approach. Save the following between sessions: current Hazard Pay (coins), highest unlocked route, and upgrade tier for each of the three upgrades. Data should save after every route completion and after every purchase.
6. On app launch, load the saved data and restore the player's progress.

**Why this matters:** Progression and upgrades give the player a reason to keep playing. A complete game loop (play, earn, upgrade, play harder routes) is what separates a Google Play-worthy game from a tech demo.

**Verify:** You can complete Route 1, earn Hazard Pay, go to the Garage, purchase a Tires upgrade, close the app completely, reopen it, and confirm that your coins, upgrade, and route progress are all preserved. Attempting to buy an upgrade you can't afford shows the error shake feedback. Route 4+ introduces nails/glass. Route 7+ has high-density overlapping hazards.

---

## Phase 6: Visual Polish and Audio

**Goal:** Replace all placeholder art with final assets and add sound effects. The game should look and sound like the finished product.

**Tasks:**
1. Import the **Teko** Google Font and apply it across all text in the app according to the DLS typography hierarchy.
2. Apply the **full DLS color palette** to every screen. Replace any remaining default Flutter colors.
3. Replace the player vehicle placeholder with a sprite (a top-down view of a battered delivery truck).
4. Replace hazard placeholders with sprites: pothole craters, glinting nail/glass debris fields, and concrete/striped barricades.
5. Create or source the road background art: cracked asphalt with painted lane lines, matching the visual identity.
6. Apply **screen shake** on barricade hits and **camera jolts** on pothole hits as described in the DLS motion section.
7. Add the **engine idle vibration** (subtle position jitter) to the Main Menu screen.
8. Style all buttons, paper elements, gauges, and overlays exactly per the DLS element blueprints (hard shadows, torn edges on receipts, dimmed overlays behind modals).
9. Add **all sound effects** listed in GDD Section 10: engine sounds, hazard impacts, UI interactions, deadline warning, receipt printing, game over crash, and ignition turn.
10. Add **haptic feedback** on hazard impacts and button presses (respecting the player's vibration toggle in settings).
11. If time permits, add a simple ambient music loop for gameplay. This is optional -- the game works fine with sound effects only.

**Why this matters:** This is what the player sees and hears. A mechanically solid game with placeholder art will get rejected from Google Play. Polish is what makes the game feel complete and professional.

**Verify:** The game looks gritty and cohesive per the visual identity. The Teko font is rendering correctly at all sizes. Every hazard impact produces the correct sound, visual feedback, and haptic pulse. The Main Menu has the idle vibration. Buttons have the physical press-and-release feel described in the DLS. The overall experience feels like a finished, themed product, not a prototype.

---

## Phase 7: Playtesting and Balance

**Goal:** The game is fair, fun, and performs well on real hardware.

**Tasks:**
1. Play through all 10 routes on a physical device. Note any route that feels unfairly difficult or trivially easy and adjust the spawn rates, deadline speeds, and base pay values in the route data.
2. Verify that the upgrade economy feels right: the player should need to replay a route once or twice to afford upgrades, but never feel stuck grinding endlessly. Adjust costs and rewards as needed.
3. Confirm that the spawning safety rule (always one clear lane) holds in all situations, especially in the dense Zone 3 routes.
4. Test on at least one lower-end Android device to check for frame drops or stuttering during heavy hazard sections. Optimize if necessary (reduce particle effects, simplify animations).
5. Verify that the deadline gauge timing is tight but fair: a skilled player should be able to beat each route without upgrades, but upgrades should provide a comfortable margin.
6. Check all screen transitions and navigation flows for bugs: pausing mid-game, abandoning routes, retrying after game over, going to the Garage from the Route Complete screen, etc.

**Why this matters:** An unfair or buggy game gets bad reviews and uninstalls. Balance and stability are the difference between a game players enjoy and one they delete after two minutes.

**Verify:** You can beat all 10 routes. No route has an impossible hazard pattern. The upgrade progression feels rewarding. The game maintains a smooth frame rate on a mid-range device. No navigation flow leads to a broken or stuck state.

---

## Phase 8: Release Preparation

**Goal:** The app is fully ready for Google Play submission.

**Tasks:**
1. Set the app icon using the existing logo asset (`assets/images/logo.png`). Configure it as an Android adaptive icon with appropriate foreground and background layers.
2. Remove all debug output (print statements, debug banners, test triggers).
3. Write the **Privacy Policy** text. It should state that the app collects no personal data, has no ads, no analytics, and no third-party services. Host this policy on a publicly accessible URL (a simple GitHub Pages site or equivalent). Also include this same text in the in-app Fine Print screen.
4. Prepare **Play Store listing assets:**
   - App title: Route Rush
   - Short description (80 characters max): A one-line hook.
   - Full description (4000 characters max): Describe the game, its features, and what makes it engaging.
   - Feature graphic (1024x500 pixels): A wide banner showcasing the game's visual identity.
   - Screenshots: At least 4 screenshots from different screens (Main Menu, Gameplay, Route Complete, Garage).
   - Category: Games > Arcade.
5. Complete the **content rating questionnaire** on Google Play Console. The game contains no violence beyond cartoonish vehicle damage, no user-generated content, no social features, no real-money spending, and no ads. It should qualify for an "Everyone" or equivalent rating.
6. Set the minimum SDK version appropriately (target modern Android versions).
7. Build the signed release app bundle.
8. Upload to Google Play Console and submit to the Internal Testing track first. Run the pre-launch report and fix any issues it surfaces.
9. After internal testing is clean, promote to Production and submit for review.

**Why this matters:** Google Play has specific requirements for listing quality, policy compliance, and technical standards. Missing any of these causes rejection and delays.

**Verify:** The signed app bundle uploads to Google Play Console without errors. The pre-launch report shows no crashes or critical issues. The listing page looks professional with all required assets. The privacy policy URL is accessible and accurate.

---

## Summary of Key Technical Decisions

These decisions are made to keep the project simple and fast to build:

| Decision | Choice | Rationale |
|:---|:---|:---|
| State management | Flutter's built-in tools (ValueNotifier or similar) | The game state is tiny (coins, lives, screen, upgrades). No need for BLoC, Riverpod, or any third-party package. |
| UI overlay approach | Flutter's Stack widget with visibility toggling | Menus and HUD are Flutter widgets layered over the Flame GameWidget. Simple, no routing packages needed. |
| Collision detection | Flame's built-in hitbox system | We only need "did Box A touch Box B." No physics engine, no Forge2D. |
| Data persistence | Simple key-value local storage | Saving a handful of integers (coins, route number, 3 upgrade tiers). No database needed. |
| Level data | Hardcoded data structure (list or map) | 10 routes with a few numbers each. No need for JSON files, asset loading, or a level editor. |
| Audio | Flame's built-in audio utilities | Simple fire-and-forget sound effects. No need for a complex audio manager. |
| Monetization | None | No ads, no in-app purchases. Keeps the build simple and avoids policy complexity. |
