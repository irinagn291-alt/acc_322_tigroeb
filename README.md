# Graticule

Friends share one phone and aim an exact score before kickoff. Posted results award points on the standings. There is no purse and no account.

## Architecture

The board is a fold over fixtures. Each tipster line is Open, Aimed, Sealed, Posted, or Void. Aim writes one cell on the 4×4 lattice and folds Open to Aimed. Seal writes a SealMark only while today is before the kickoff daykey. Post writes a BullseyeMark (9), a NearMark (3), or a Flat (0) from the typed final score. A second aim without peel writes a SkewMark and keeps the cell. An unsealed line whose kickoff day has arrived becomes Void. Standings are the sum of posted points, not a stored table. One chart record is the whole save, so a mark and its phase cannot drift apart.

## Aim then seal

Home is the week board. The fixture carousel and the lattice stay on screen. Aim and Seal sit on the active tile. The opening simulator match is already aimed, so the first tap is Seal. A SpriteKit burst plays on the board only when a bullseye lands.

## Art

Flat vector illustration mixed with cut paper and a stamped edge. Solid shapes, hard edges, a dense board of placed squares, one playful seal figure, and generous negative space. Lively and playful in mood. No gradients, no clay, no glass, no photoreal rendering, no 3D, no letters, and no numerals.

Image sets use that prompt with the subject named in SPEC section 13: `grc_AppIcon`, `grc_Splash`, `grc_Onboarding1`, `grc_Onboarding2`, `grc_Onboarding3`, `grc_EmptyHome`, `grc_EmptyList`, `grc_CardBackdrop`, `grc_ControlFace`, `grc_TwistHero`, `grc_SuccessMark`, `grc_HeaderDecor`, `grc_FixturePair`, `grc_LatticeTile`.

## How this differs

Quoinlock keeps home, draw, and away cards with a confidence purse. Studlink keeps an all-or-nothing chain. Graticule keeps fixtures and standings, and the persisted verb is exact-score aim-then-seal on a lattice with 9, 3, and 0 scoring.

## Build

```
xcodegen generate
xcodebuild build-for-testing -scheme Graticule -destination 'generic/platform=iOS Simulator'
```
