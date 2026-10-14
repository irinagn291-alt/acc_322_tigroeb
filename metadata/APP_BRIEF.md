<!-- gf-brief source=befc1ada18fee5ad16fbbee69c9d65f44443f07b5748def9dd7cee96e93a60af written=2026-10-14T16:55:11+03:00 -->
# Tigroeb

## What it is
Tigroeb is a points league for friends who share one phone. Each tipster aims an exact match score on a 4 by 4 lattice, seals that cell before kickoff, then posts the final goals so the standings can award a bullseye, a near, or a flat. There is no account and no purse; only points on this device.

## Launch and onboarding
A cold launch shows the system launch screen (no words). The week board is the home screen.

If onboarding has not been finished, a full-screen onboarding covers the board at once. It cannot be swiped away. Three pages share a page indicator, a full-width **Continue**, and **Skip**. **Continue** stays **Continue** on every page. **Continue** on page 1 or 2 moves to the next page. **Continue** on page 3, or **Skip** on any page, dismisses onboarding and shows the board. If no tipster exists yet, finishing writes one tipster named **You**. Onboarding does not add fixtures.

1. Headline: “Aim an exact score.” Line: “Friends on this phone share one lattice. Points stay on the standings.”
2. Headline: “Seal the cell before kickoff.” Line: “A second aim without peel records a skew and keeps the cell.”
3. Headline: “Post the final goals.” Line: “An exact cell is a bullseye at 9. The right winner on another cell is near at 3. A wrong winner is flat at 0.”

On a physical device the first board after onboarding is empty (see Screens). On Simulator, the first launch can skip onboarding and open a filled sample board (see Starter content). Later launches return to the board as it was left. Bringing the app forward folds any still-open or aimed fixture whose kickoff day has arrived into void.

## Screens

There is no tab bar. Home is the week board. **Fixtures**, **Standings**, and **Settings** open as sheets over that board. **Done** or a downward swipe closes a sheet.

### Week board
Wordmark: **TIGROEB**. The short title and caption change with the active tipster and fixture.

When there are no fixtures, a full-page empty state covers the board, including the sheet chips:

- Headline: “The board has no fixtures yet.”
- Line: “Add a match, aim a score, and seal it before kickoff.”
- If the saved board could not be read, that notice also appears here: “The saved board could not be read.”
- **Add a fixture** opens the Fixtures sheet.

Once at least one fixture exists, the empty state hides and the board shows:

- A row of tipster name chips. The active name is the filled chip. Tapping another name shows that tipster’s cells and phases on the same fixtures. There is no control here to add or remove a tipster.
- A horizontal fixture carousel. Each tile title is the match in capitals, in the form **HOME VERSUS AWAY** (for example **MILLTOWN VERSUS HARBOR**). A colour swatch sits beside the phase word **OPEN**, **AIMED**, **SEALED**, **POSTED**, or **VOID**. Under that: the aimed score as “2 to 1” when a cell exists; **Kickoff** plus the daykey number (for example “Kickoff 20261017”); and, if a second aim was taken without peel, “A skew was recorded.” Swiping or tapping a neighbour makes that fixture active and larger. Only the active tile shows the verbs.
- On the active tile: **Aim**, **Seal**, and **Post**. The live verb is the large filled control; the others sit under it and can be dimmed. **Home goals** and **Away goals** (number pad, toolbar **Done**) appear when it is time to post, or after a score is already posted.
- A 4 by 4 lattice of squares. Each square prints two numbers with a space, home then away, from **0 0** through **3 3**. Rows are home goals 0 to 3; columns are away goals 0 to 3. Tap a square to select it (stronger border). The aimed square fills in. VoiceOver names a square “Score 0 to 0” (and so on) and values it **Aimed** or **Empty**.
- **Peel** under the lattice. It is enabled only while the line is aimed or sealed and today is still before kickoff. It drops the last seal back to aimed, or the last aim back to open.
- A **POSTED POINTS** card. If no tipster exists: “No scores are posted yet.” Once tipsters exist, each name and point total is listed, highest points first, then name. A tipster with nothing posted yet shows **0**.
- Bottom chips: **Fixtures**, **Standings**, **Settings**.

Titles and captions on the board (the short titles display in capitals):

| Title | Caption |
| --- | --- |
| **AIM A SCORE** | “Choose a square, then aim that exact score.” |
| **SEAL THIS SCORE** | “Seal Milltown 2 to 1 before kickoff.” (home side name, then the aimed pair). If a skew exists: “A skew was recorded. Seal Milltown 2 to 1 before kickoff.” |
| **CELL SEALED** | “This cell is sealed. Post waits until the kickoff day.” |
| **POST THE GOALS** | “This cell is sealed. Enter the final goals, then post.” |
| **SCORE POSTED** | “Posted 1 to 1.” (the typed final pair) |
| **KICKOFF VOID** | “Kickoff passed before a seal, so this fixture is void.” |
| **WEEK BOARD** | Shown with “The saved board could not be read.” when that notice is the only state. |

**Aim** writes the selected square as that tipster’s cell and moves **OPEN** to **AIMED**. If no square is selected: “Choose a square on the lattice, then aim.” A second **Aim** without **Peel** does not change the cell; it records a skew. **Aim** after the line is sealed, posted, or void is refused: “This fixture is sealed, so the cell stays.”

**Seal** freezes the aimed cell only while today is before the kickoff day. Too late: “Kickoff has arrived, so this cell cannot be sealed.” No aim yet: “Aim a cell before you seal it.”

**Post** stores one final score for the fixture (any whole numbers from zero up, including totals above 3) and scores every sealed tipster on that match. It is enabled only on or after kickoff, and only before a final is stored. Empty or non-numeric fields: “Enter each side as a whole number from zero up.” Too early: “Post waits until the kickoff day.”

An exact cell is a bullseye at **9**. The right winner (or a draw when both sides match) on another cell is near at **3**. A wrong winner is flat at **0**. A short burst plays over the lattice on a bullseye. With Reduce Motion, the **POSTED POINTS** card fades instead.

A successful **Aim**, **Seal**, **Post**, or **Peel** also plays a light haptic.

### Fixtures
Sheet. **Done** closes it and returns to the board.

- Section **Matches**. Each row: “Milltown versus Harbor. Kickoff 20261017.” (title plus the daykey). If the list is empty: “No matches are typed yet.” Tapping a row does nothing; there is no edit or delete.
- Section **Add a fixture**. Fields: **Home side**, **Away side**, **Kickoff daykey** (number pad, toolbar **Done**). The daykey field is prefilled with today plus seven days as one number (for example 20261021). **Add a fixture** appends the match as **OPEN** for every tipster and grows the Matches list. Home and away fields then clear; the daykey stays. Both side names are required: “Enter both side names before adding the fixture.” The daykey must be a real calendar day written as year, month, and day in one number: “Enter the kickoff as a daykey, such as a year month and day.”
- Section **Board** appears only with the notice “The saved board could not be read.”

### Standings
Sheet. **Done** closes it.

When at least one tipster exists, section **Standings** lists one row each: “Ada Quinn holds 9 points.” (name and that tipster’s posted total). Order follows the tipster list, not rank.

When no tipster exists, a full-page empty state covers the sheet:

- Headline: “No scores are posted yet.”
- Line: “Seal a cell, then enter the final goals.”
- **Back to the board** dismisses the sheet.

Section **Board** appears only with “The saved board could not be read.”

### Settings
Sheet. **Done** saves names and closes it.

- Section **Tipsters**. One text field per existing name, VoiceOver “Tipster name”. Editing ends, or **Done**, keeps a non-empty name. A blank name is not saved; the previous name stays. There is no Add tipster and no delete tipster. If the list is empty: “No tipsters are named yet.”
- Section **Round**. **Reset this round** asks “Reset this round?” with “Aimed cells, seals, and posted points on this device are deleted.” Buttons: **Cancel** and **Reset this round**. Confirming clears aims, seals, skews, voids, posted scores, and points. Fixture names and tipster names stay. Every line returns to **OPEN**.
- Section **Onboarding**. **Replay onboarding** closes Settings and shows the three onboarding pages again. Board data is not cleared.
- Section **Data**. **Contact** opens the support page. **Reset all data** asks “Reset all data?” with “Tipsters, fixtures, and marks on this device are deleted.” Buttons: **Cancel** and **Reset all data**. Confirming wipes the board. Returning to home runs onboarding again.
- Section **Board** appears only with “The saved board could not be read.”

## Features
- Week board with a fixture carousel that never leaves home
- 4 by 4 lattice of exact scores from 0 to 3 on each side
- **Aim** a cell, **Seal** it before kickoff, **Peel** it before kickoff, **Post** the final goals after kickoff
- Skew: a second **Aim** without **Peel** keeps the first cell and shows “A skew was recorded.”
- Void: kickoff day arrives while the line is still **OPEN** or **AIMED**
- Points: bullseye 9, near 3, flat 0, shown on **POSTED POINTS** and **Standings**
- One posted final per fixture, scored for every tipster who sealed
- Add typed matches (home side, away side, kickoff daykey)
- Switch among existing tipsters; rename them
- Reset this round; reset all data
- Replay onboarding
- **Contact**
- Burst on a bullseye

## Behaviours that can look like bugs
- Empty board hides **Fixtures**, **Standings**, and **Settings**. Add a match with **Add a fixture**, or the chips never appear.
- **Aim** does nothing useful until a lattice square is selected. Caption: “Choose a square on the lattice, then aim.”
- **Seal** stays dim until the line is **AIMED** and today is before kickoff. **Post** stays dim until the line is **SEALED**, kickoff day has arrived, and no final is stored. **Peel** stays dim unless the line is **AIMED** or **SEALED** and kickoff has not arrived. Dimmed verbs do not continue.
- A kickoff daykey of today or earlier voids an unsealed line as soon as the board refreshes. Title **KICKOFF VOID**, caption “Kickoff passed before a seal, so this fixture is void.” Use a future daykey (the field defaults to today plus seven days) to aim and seal.
- **Post** will not take a blank or partial pair. Caption: “Enter each side as a whole number from zero up.” Type both sides, then **Post**.
- A second **Aim** does not move the cell. The tile keeps the first score and adds “A skew was recorded.” **Peel** first if the cell must change.
- After **Peel**, “A skew was recorded.” can remain on that tile until **Reset this round**.
- **Aim** on a sealed, posted, or void line can show “This fixture is sealed, so the cell stays.” even when the phase word is **VOID**.
- There is no control to add a second tipster. On a device the only name after onboarding is **You** (renameable). Several named chips appear only in the Simulator sample.
- There is no control to delete one fixture or one tipster. **Reset this round** clears marks only. **Reset all data** clears everything.
- **Standings** and **POSTED POINTS** show **0** as soon as a tipster exists, before any post. The “No scores are posted yet.” empty copy appears only when no tipster exists.
- **Replay onboarding** is meant to loop back to the three pages. **Skip** or finish **Continue** returns to the same board.
- The Matches list only grows; it does not shrink except after **Reset all data**.
- A blank tipster name silently reverts when Settings closes.
- Day edges use the device calendar and time zone. Opening the app after local midnight can void lines that were still open the day before.

## Starter content and resume
On a physical device: none. After onboarding the only tipster is **You** and the board stays empty until a fixture is added.

On Simulator, the first launch can already hold three tipsters and four fixtures, with onboarding marked done:

- Tipsters: **Ada Quinn** (selected), **Ben Holt**, **Cora Voss**
- **Milltown versus Harbor**, kickoff in three days, Ada aimed **2 to 1**, **Seal** ready
- **Loom End versus Kiln Row**, kickoff in three days, still **OPEN**
- **Wharf Lane versus North Stair**, kickoff in three days, sealed at **1 to 0**
- **Gatehouse versus Low Market**, kickoff yesterday, posted **1 to 1**. Ada holds **9**, Ben holds **3**, Cora holds **0**
- Carousel opens on **Milltown versus Harbor**

Aimed cells, seals, skews, voids, posted finals, fixtures, tipster names, and the last selected tipster and fixture come back after a quit. A square that was only highlighted, never aimed, does not. **Reset this round** and **Reset all data** are the only clears.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content (nothing is published off this phone), account deletion flow, and the App Tracking Transparency prompt are all absent.

## Data and support
Data stays on this device. Settings says so on both reset confirms. **Contact** in Settings, section **Data**, opens the support page.

## Scanning and health
None.

## Platform
English copy only. Light appearance. Portrait only, full screen, on iPhone and iPad. Kickoff is a calendar day in the device time zone, not a clock time; the daykey is the year, month, and day as one whole number. Minimum iOS version is 17.0.

## Category
Sports.
