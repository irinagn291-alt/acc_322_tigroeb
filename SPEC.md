# Graticule — Build Specification

> Portfolio app 192, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Pick exact match scores, freeze them before kickoff, and track your friend league points.

| Field | Value |
| --- | --- |
| Product name | Graticule |
| Bundle identifier | `com.graticule.lattice` |
| Domain | https://graticule-lattice.pro |
| Contact URL | https://graticule-lattice.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `grc_` |
| User-Agent | `Graticule/1.0 (iOS; +https://graticule-lattice.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Graticule -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A league tipster aims an exact score on the lattice and seals it before kickoff so posted results award bullseye or near points on the standings board.

### 2.1 User flow

1. On the week board, tap the fixture tile that shows a chosen cell but is still unsealed
2. Tap Seal to freeze that score cell before kickoff
3. After the match, enter the final home and away goals on the same tile
4. Watch bullseye or near marks update your tipster row
5. Open the Fixtures sheet to add next week's matches
6. Open Standings to compare tipsters for the round

### 2.2 Essential behaviour

- Local fixture list with kickoff stored as YYYYMMDD daykey
- 4×4 score lattice (0–3 each side) fused on each open fixture tile
- AimMark then SealMark gate: picks cannot change after seal
- Manual result post writes BullseyeMark (9), NearMark (3), or Flat (0)
- Derived standings from Posted fixtures only—no stored leaderboard table
- SpriteKit accent burst when a BullseyeMark lands
- Settings for tipster names and round reset; no accounts, money, or live odds

---

## 3. Uniqueness assignment for Graticule

| Axis | Assigned value |
| --- | --- |
| Architecture | **Grid ADT fold (Open | Aimed | Sealed | Posted | Void); the board is a fold over Fixtures; Aim writes a Cell on the 4×4 lattice and folds Open to Aimed; Seal writes a SealMark before kickoff and folds Aimed to Sealed; Post writes BullseyeMark, NearMark, or Flat from the entered score and folds Sealed to Posted; Aim on Sealed is refused; a second Aim without Peel writes SkewMark; kickoff passed while not Sealed writes VoidMark; empty board writes Blank** |
| UI approach | **UIKit Storyboards segues · spritekit-accent** |
| Naming convention | **Lattice / score-aim lexicon (Board, Fixture, Lattice, Cell, AimMark, SealMark, BullseyeMark, NearMark, VoidMark, SkewMark, Tipster, Standing)** |
| File organization | **By lattice role (Board, Fixture, Lattice, Cell, AimMark, SealMark, BullseyeMark, NearMark, Tipster, Standing)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **vibrant · board · mid** |
| Typography | **Copperplate** |
| Navigation pattern | **Lattice-locked chrome (the 4×4 lattice and fixture carousel never leave; Fixtures and Standings arrive as sheets; aim and seal fuse on the active tile; Settings as a sheet; no tab bar)** |
| AI art style | **Flat vector illustration · mixed-media** |
| Functional twist | **Aim-then-seal (Aim writes Cell; Seal freezes before kickoff; SkewMark on re-aim; VoidMark if kickoff passes unsealed; BullseyeMark 9 / NearMark 3 / Flat 0 on Post)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — prediction_league

**Core** — A league tipster aims an exact score on the lattice and seals it before kickoff so posted results award bullseye or near points on the standings board.

**Audience** — Friends who want exact-score bragging rights on one phone, with points only and no bookmaker or purse math.

**User flow**

1. On the week board, tap the fixture tile that shows a chosen cell but is still unsealed
2. Tap Seal to freeze that score cell before kickoff
3. After the match, enter the final home and away goals on the same tile
4. Watch bullseye or near marks update your tipster row
5. Open the Fixtures sheet to add next week's matches
6. Open Standings to compare tipsters for the round

**Essential features**

- Local fixture list with kickoff stored as YYYYMMDD daykey
- 4×4 score lattice (0–3 each side) fused on each open fixture tile
- AimMark then SealMark gate: picks cannot change after seal
- Manual result post writes BullseyeMark (9), NearMark (3), or Flat (0)
- Derived standings from Posted fixtures only—no stored leaderboard table
- SpriteKit accent burst when a BullseyeMark lands
- Settings for tipster names and round reset; no accounts, money, or live odds

**Twist** — Aim-then-seal. Home is the week board and active lattice. Aim writes a Cell on the 4×4 grid and folds Open to Aimed. Seal writes a SealMark before kickoff and folds Aimed to Sealed. Aim on Sealed is refused. A second Aim on the same fixture without Peel writes SkewMark and keeps the Cell. An unsealed fixture past kickoff writes VoidMark and folds to Void. Post compares the entered final score: exact Cell writes BullseyeMark and 9 points; correct winner with wrong cell writes NearMark and 3 points; wrong winner writes Flat at 0. Peel drops the last SealMark or AimMark on fixtures still before kickoff. Seed leaves one fixture Aimed but not Sealed so the opening tap is Seal. Home verb: aim-then-seal—not lock-the-card and not prove-the-chain. Analytics is standings; Fixtures sheet types matches. Local only.

**Why this is not a repeat** — Quoinlock already owns H/D/A cards with a confidence purse and Slate-tab chrome; Studlink owns an all-or-nothing swaged chain with squared scoring and chain-locked chrome. This product keeps prediction_league fixtures and standings but makes the persisted verb exact-score aim-then-seal on a lattice with independent per-match 9/3/0 scoring, lattice-locked chrome, and zero SPM—so it is not a reskin of either neighbor.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Event tiles. Lock before start. Points, never money.
- Invariant: Score = 100 × (1 + confidence/100) if correct, else 0. One pick/event. Must lock before resolve. Score real outcomes — not RNG.
- Never: Disclaimer: no money. Fake resolution fails review.
- Desk `watch_rate`: OLS s/day vs day; R²; DU/DD/CU/CL/CD spread; COSC |dev|≤4.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.
- Mini-ref `SportPulse`: steal Lock 1X2 before start, score real outcomes, stats, notes. Never Wallet, odds, stake, payout, PlaceBet, simulate, wrapper, OneSignal. New types and layout — do not reskin.

### 3.1 Architecture contract

BoardFold reduces a Board of Tipsters, and each Tipster is a fold over the shared Fixtures, with a phase of Open, Aimed, Sealed, Posted, or Void on each fixture. Aim on Open writes one Cell, with home and away each an integer from 0 through 3, and folds that fixture to Aimed, while a second Aim without Peel appends a SkewMark and leaves the Cell in place, and Aim on Sealed, Posted, or Void is refused. Seal appends a SealMark and folds Aimed to Sealed only when the current daykey, an Int in YYYYMMDD form taken from Calendar.current.startOfDay, is strictly less than the fixture kickoff daykey. When the current daykey is greater than or equal to that kickoff daykey and the fixture is still Open or Aimed, the fold appends a VoidMark and moves that tipster to Void. Post stores one typed final score on the fixture, including totals above 3, treats the winner as whichever side is greater or as a draw when the goals match, and folds every Sealed tipster on that fixture to Posted with a BullseyeMark worth 9 points on an exact Cell, a NearMark worth 3 points when the winner matches on a different score, or a Flat worth 0 points when the winner differs. Peel drops the last SealMark back to Aimed or the last AimMark back to Open only while the current daykey is still before kickoff, Peel on Posted or Void is refused, an empty fixture list yields Blank, and each Standing is the sum of Posted points for one Tipster.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

The lifecycle is UIKit. AppDelegate and SceneDelegate load Board.storyboard as the initial scene, and every destination change is an Interface Builder segue. BoardViewController keeps a horizontal fixture carousel and a fused 4 by 4 lattice on screen together. The active tile is the hero, larger than its neighbors, and those neighbors are framed and clipped so they cannot paint over it. Aim and Seal are UIButtons fused on that tile, each at least 44 points, with the whole button as the hit target and a VoiceOver label. Fixtures, Standings, and Settings are present-modally page sheet segues that dismiss back to the same board. The only SpriteKit surface is an SKView on the board that cross-fades a bullseye burst in 180ms ease-out when a BullseyeMark lands. Reduce Motion swaps the points in place and keeps a fade. Every other scene is a stock UITableView or UICollectionView. Colours, type, spacing, and radius each come from one accessor: card radius 14, chip radius 6, shadow elevation, and a filled capsule for Aim, Seal, and Post. The lattice shows all sixteen score cells as placed squares, with the score pair printed, so an unchosen cell is an honest empty square. The board fills the safe area and uses the iPad width. An empty board is a full-page view pinned to the safe area, with cutout art, one headline, one line, and a full-width button at the bottom. Phase and score words sit beside the colour. One haptic fires when Aim, Seal, or Post succeeds. Goal counts and points use NumberFormatter.

### 3.3 Naming contract

Convention: Lattice / score-aim lexicon (Board, Fixture, Lattice, Cell, AimMark, SealMark, BullseyeMark, NearMark, VoidMark, SkewMark, Tipster, Standing).

Examples to follow: `BoardFold.aim(fixture:cell:)` writes a Cell and folds Open to Aimed. `SealMark` freezes that Cell before the kickoff daykey. `BullseyeMark` records an exact cell at 9 points. `Standing` sums Posted points for one Tipster.

### 3.4 Dependency contract

Zero external dependencies: no Swift Package Manager entry, no CocoaPods, and no vendored source. System frameworks are UIKit, Core Graphics, AVFoundation, and URLSession, plus SpriteKit for the single bullseye accent. AVFoundation does not open a capture session. This app does not use the camera. URLSession does not call cgi/search.pl. Fixtures are typed on the device. Copperplate ships with iOS, so no font file is bundled. There is no analytics SDK and no web view.

### 3.5 Navigation contract

Lattice-locked chrome lives in Board.storyboard. The 4 by 4 lattice and the fixture carousel never leave BoardViewController. Aim and Seal fuse on the active tile. The Fixtures segue, the Standings segue, and the Settings segue are modal page sheets over that board. There is no tab bar. Onboarding is a full-screen segue with Continue full width at the bottom. After onboarding is done, ReviewHook reads ProcessInfo.processInfo.arguments once. The today key leaves the board in place, log performs the Fixtures segue, goals performs the Standings segue, and settings performs the Settings segue. Those four keys open four different scenes. If onboarding is still showing, the hook does not run.

### 3.6 Screen composition contract

Lattice-root fused board (Board holds the fixture carousel and fused 4×4 lattice; Fixtures and Standings arrive as sheets over lattice-locked chrome; Settings as sheet; no TabView). Physical screens are Board, Fixtures, Standings, Settings, and Onboarding. Board is home and the Events surface: the carousel, the fused lattice for the active tipster, and Aim, Seal, and Post on the active tile. The empty board headline is The board has no fixtures yet. The line under it is Add a match, aim a score, and seal it before kickoff. The bottom button title is Add a fixture. Fixtures is the sheet where a match is typed: home side, away side, and a kickoff daykey. A negative goal entry says Enter each side as a whole number from zero up. Standings is the sheet that lists each tipster and the points derived from Posted fixtures, and it is the Analytics surface. Its empty headline is No scores are posted yet. Its line is Seal a cell, then enter the final goals. Settings holds tipster names, a round reset, replay of onboarding, reset of all data, and the contact link https://graticule-lattice.pro/contact-us. Round reset confirms with Reset this round? Aimed cells, seals, and posted points on this device are deleted. Onboarding is three pages with Continue full width at the bottom, and Skip writes one tipster and an empty board. ReviewScreen today leaves Board up, log opens Fixtures, and goals opens Standings. The simulator seed grc.demo.v1 runs once, marks onboarding complete, and never runs on a device. It seats tipsters Ada Quinn, Ben Holt, and Cora Voss, and four fixtures: Milltown versus Harbor aimed at 2 to 1 with Seal enabled, Loom End versus Kiln Row still open, Wharf Lane versus North Stair sealed at 1 to 0, and Gatehouse versus Low Market posted at 1 to 1 so Ada holds 9, Ben holds 3, and Cora holds 0. The carousel opens on Milltown versus Harbor.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By lattice role (Board, Fixture, Lattice, Cell, AimMark, SealMark, BullseyeMark, NearMark, Tipster, Standing)**

```
Graticule/
  Board/BoardFold.swift
Board/BoardChart.swift
Board/BoardStore.swift
Board/DayKey.swift
Board/VoidMark.swift
Board/SkewMark.swift
Board/Flat.swift
Board/Board.storyboard
Board/BoardViewController.swift
Board/FixtureCarouselView.swift
Board/BullseyeBurstScene.swift
Board/DemoSeed.swift
Board/ReviewHook.swift
Fixture/Fixture.swift
Fixture/Fixtures.storyboard
Fixture/FixturesViewController.swift
Lattice/Lattice.swift
Lattice/LatticeView.swift
Cell/Cell.swift
AimMark/AimMark.swift
SealMark/SealMark.swift
BullseyeMark/BullseyeMark.swift
NearMark/NearMark.swift
Tipster/Tipster.swift
Tipster/Settings.storyboard
Tipster/SettingsViewController.swift
Standing/Standing.swift
Standing/Standings.storyboard
Standing/StandingsViewController.swift
Onboarding/Onboarding.storyboard
Onboarding/OnboardingViewController.swift
Design/TypeScale.swift
AppDelegate.swift
SceneDelegate.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Events
A first-class screen for **Events**. Must render empty, populated and error states.

### 5.3 Analytics
A first-class screen for **Analytics**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Event** — named per this app's convention.
- **Prediction** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **vibrant · board · mid**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#DFE4D3` | Screen background |
| `surface` | `#EEF0EA` | Cards, rows, sheets |
| `ink` | `#1E240F` | Primary text and icons |
| `accent` | `#6B8924` | Primary action, key figure, progress fill |
| `muted` | `#5C6549` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Graticule/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Copperplate**

Copperplate is the assigned face, reached through one accessor that wraps UIFont in UIFontMetrics so sizes track Dynamic Type. Copperplate-Bold, all caps with wide tracking, is the lattice numeral and the short board title, one or two lines and never more than four, and never above 34pt. Copperplate is the step for Aim, Seal, and fixture captions. At most six steps sit behind that accessor: display, title, headline, body, caption, and micro, and none go below 12pt. Long sentences and sizes above accessibility-1 fall back to New York so Copperplate does not clip, which keeps a humanist body for editorial lines. Points, goal counts, and day labels go through NumberFormatter with monospaced digits. Day edges use Calendar.current.startOfDay and then fold to an Int in YYYYMMDD form.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **14pt** for cards, sheets and primary surfaces; **6pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **UIKit Storyboards segues · spritekit-accent**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **UIKit Storyboards segues · spritekit-accent** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **warm** (Warm soft: friendly radii, comfortable pad, one playful moment.)

Reference system: **vibrant** — steal rhythm and restraint, not their colours or logos.

Mood: **Lively, colorful design with bold playful typography, warm accents, and dynamic visual energy.**.

Home rhythm (`board`, dense): A board of placed pieces. Empty cells are honest, not holes.

Warm soft: friendly radii, comfortable pad, one playful moment. Layout `board`, density dense. Kit 14/6, shadow, filled capsule. Palette recipe `mid`. Almost no travel. Cross-fade 180ms ease-out. Numbers tick, they do not fly. Reduce Motion: instant swap. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Mono numerals, humanist body, no poster type. Reference type feel: warm.

Motion (`quiet`): Almost no travel. Cross-fade 180ms ease-out. Numbers tick, they do not fly. Reduce Motion: instant swap.

Voice (`editorial`): Complete sentences, no slang, no hype. Captions are real lines.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

UserDefaults holds one Codable Chart root, BoardChart, under the single key grc.chart.v1. BoardChart stores schemaVersion, the Tipsters, the Fixtures with kickoff daykey Ints in YYYYMMDD form, each tipster phase on each fixture, the aimed Cell, the typed final score, and the append-only marks AimMark, SealMark, SkewMark, VoidMark, BullseyeMark, NearMark, and Flat. BoardStore keeps that record in memory, applies BoardFold, and schedules one debounced JSON save about 400ms after the last mark, with an immediate flush when the scene leaves active so a force-quit keeps the write. Day edges pass through Calendar.current.startOfDay before they become daykeys. Screens talk only to BoardStore. resetAllData deletes the key and is reachable from Settings. A decode failure replaces the root with a Blank board and tells the user the saved board could not be read. The simulator seed runs once behind grc.demo.v1, under targetEnvironment(simulator), writes the happy path, and marks onboarding complete. A device never seeds.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Graticule/1.0 (iOS; +https://graticule-lattice.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.sports`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.sports
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Aim-then-seal (Aim writes Cell; Seal freezes before kickoff; SkewMark on re-aim; VoidMark if kickoff passes unsealed; BullseyeMark 9 / NearMark 3 / Flat 0 on Post)

Home is the week board, where the fixture carousel and the fused 4 by 4 lattice stay on screen, and Aim writes the active tipster Cell on that lattice. Seal freezes that Cell with a SealMark before the kickoff daykey, and the opening simulator fixture is already Aimed so the first tap is Seal. A second Aim without Peel records a SkewMark and keeps the Cell, and an Open or Aimed fixture whose kickoff daykey has arrived folds to Void with a VoidMark. After the match, Post on the same tile writes a BullseyeMark for 9 points, a NearMark for 3 points, or a Flat for 0 points from the typed final score, and a SpriteKit burst plays on the board only when a BullseyeMark lands. Standings are that fold read back for each tipster, with no separate leaderboard record. BoardFoldTests covers one sealed cell per tipster per fixture, the seal before the typed result, the skew, the void, and the 9, 3, and 0 outcomes on real typed scores, with points only.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Flat vector illustration · mixed-media**


Base prompt, reused and extended for every asset:

```
Flat vector illustration mixed with cut paper and a stamped edge. Solid shapes, hard edges, a dense board of placed squares, one playful seal figure, and generous negative space. Lively and playful in mood. No gradients, no clay, no glass, no photoreal rendering, no 3D, no letters, and no numerals.
```

All 14 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `grc_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `grc_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `grc_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `grc_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `grc_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `grc_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `grc_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `grc_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `grc_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `grc_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `grc_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Aim-then-seal (Aim writes Cell; Seal freezes before kickoff; SkewMark on re-aim; VoidMark if kickoff passes unsealed; BullseyeMark 9 / NearMark 3 / Flat 0 on Post)' feature screen. |
| 11 | `grc_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `grc_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |
| 13 | `grc_FixturePair` | 1024x1024 | **required cutout** | Cutout of two facing solid crests on a short rail, flat vector mixed media, transparent corners, no letters. |
| 14 | `grc_LatticeTile` | 1024x1024 | **required cutout** | Cutout of one thick square tile, solid, flat vector, transparent corners, no numerals, no letters. |

### Prompt per asset

**`grc_AppIcon`** — 1024x1024

```
Flat vector mixed-media emblem of a square lattice fused with a paper seal, solid shapes, hard edges, subject filling the canvas edge to edge, no letters, no numerals, no transparency.
```

**`grc_Splash`** — 1290x2796

```
Vertical flat vector board of solid squares and cut paper, mixed media, calm uncluttered centre band, filling the canvas, no letters.
```

**`grc_Onboarding1`** — 1024x1536

```
Cutout of one fixture tile carrying a small lattice of solid squares, flat vector mixed with torn paper, solid subject centered, transparent corners, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grc_Onboarding2`** — 1024x1536

```
Cutout of a stamp pressing a solid seal onto one square, flat vector mixed media, solid subject centered, transparent corners, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grc_Onboarding3`** — 1024x1536

```
Cutout of three uneven standing rows of solid marks on a short board, flat vector mixed with paper, solid subject centered, transparent corners, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grc_EmptyHome`** — 1024x1024

```
Cutout of a closed wooden board case with a paper face, solid and fully opaque subject, flat vector, transparent corners, calm, no glass, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grc_EmptyList`** — 1024x1024

```
Cutout of a short stack of blank fixture cards face down, solid paper, flat vector, transparent corners, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grc_CardBackdrop`** — 1200x800

```
Abstract flat vector backdrop of paper bands and a faint square grid, low contrast, filling the canvas, no letters.
```

**`grc_ControlFace`** — 512x512

```
Cutout of one round seal knob, solid, flat vector with a paper edge, transparent corners, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grc_TwistHero`** — 1024x1024

```
Cutout emblem of a square lattice with one cell covered by a solid seal, flat vector mixed media, transparent corners, no letters, no numerals.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grc_SuccessMark`** — 512x512

```
Solid filled seal medallion of metal and paper, thick and closed, centered, flat vector, transparent corners, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grc_HeaderDecor`** — 1200x600

```
Wide cutout band of paper strips and a row of solid squares, flat vector mixed media, transparent corners, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grc_FixturePair`** — 1024x1024

```
Cutout of two facing solid crests on a short rail, flat vector mixed media, transparent corners, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grc_LatticeTile`** — 1024x1024

```
Cutout of one thick square tile, solid, flat vector, transparent corners, no numerals, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`grc.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `GraticuleTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Graticule/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Graticule -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Grid ADT fold (Open | Aimed | Sealed | Posted | Void); the board is a fold over Fixtures; Aim writes a Cell on the 4×4 lattice and folds Open to Aimed; Seal writes a SealMark before kickoff and folds Aimed to Sealed; Post writes BullseyeMark, NearMark, or Flat from the entered score and folds Sealed to Posted; Aim on Sealed is refused; a second Aim without Peel writes SkewMark; kickoff passed while not Sealed writes VoidMark; empty board writes Blank** with no leakage across layers.
- [ ] UI approach matches **UIKit Storyboards segues · spritekit-accent**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Lattice-locked chrome (the 4×4 lattice and fixture carousel never leave; Fixtures and Standings arrive as sheets; aim and seal fuse on the active tile; Settings as a sheet; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Copperplate** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Graticule
xcodegen generate
xcodebuild build-for-testing -scheme Graticule -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.graticule.lattice/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Graticule -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.graticule.lattice/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Graticule -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.graticule.lattice/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
