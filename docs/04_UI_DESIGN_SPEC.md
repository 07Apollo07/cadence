# UI design spec

## Direction: the same instrument-panel language, made dimensional

This continues the aesthetic direction from the pose-estimation project — a
dark, precise, instrument-panel feel rather than a generic fitness-app
template — but pushed further into physicality per explicit direction: the
controls should look and feel like real dashboard hardware (aircraft trim
wheels, embossed buttons, inset LCD-style readouts), not flat colored
rectangles. Depth here isn't decorative — it's the whole visual identity of
the app, since the wheel is a literal physical-object metaphor.

**Signature element**: the paired knurled scroll wheels running down the
left and right screen edges — cylindrical shading (a highlight band down the
center, darker falloff at the edges), a lit accent groove marking the current
detent, and real spring-physics motion when scrolled (see interaction spec
below). This one element appears on both the Metronome and GPS tabs, tying
the whole app together.

## Design tokens

### Color

Same base palette as the pose-estimation project — reuse these exact values,
don't redefine a second dark theme for a sibling app:

| Token | Hex | Use |
|---|---|---|
| `surfaceBase` | `#0B0F14` | app background |
| `surfacePanel` | `#131A21` | cards, tiles, tab switcher |
| `surfaceRaised` | `#1B242D` | pressed/active states, button faces |
| `surfaceInset` | `#0D1319` | new — the "glass panel" readout background, darker than base to read as recessed |
| `hairline` | `#26313B` | dividers, wheel ridge shadows |
| `textPrimary` | `#E8EDF1` | numerals, primary labels |
| `textMuted` | `#7C8A96` | secondary labels, units |
| `traceCalm` | `#2DD4BF` | wheel accent groove, GPS route start, "on target" states |
| `traceHot` | `#FF9F1C` | metronome button accent, GPS route end/high-effort, "above target" states |
| `statusDanger` | `#E5484D` | errors, permission denials, GPS signal lost |

### Typography

Same as before — monospace with tabular figures (`JetBrains Mono` / `IBM
Plex Mono`) for all numerals, system sans for labels and body text. The
carousel's big number stays the single largest element on each screen.

### Depth system (new — not present in the pose-estimation project's spec)

Three consistent depth treatments, used throughout instead of invented ad
hoc per screen:

1. **Recessed** (`surfaceInset` + inset shadow) — for readouts: the big
   cadence number, stat tiles. Reads as "a display you're looking into."
2. **Raised** (`surfaceRaised` + soft drop shadow + subtle top highlight) —
   for interactive surfaces: buttons, the active tab pill, cards. Reads as
   "something you can press."
3. **Cylindrical** (layered gradients simulating a lit, rounded surface) —
   reserved *only* for the wheels and the metronome toggle button, since
   those are the two literally physical-dial-shaped controls. Don't apply
   this treatment to flat UI elements (cards, tiles) — it should stay
   special to the two hardware-like controls, or it stops reading as
   meaningful and just becomes decoration.

## The three screens

### 1. Metronome tab

```
┌─────────────────────────────┐
│     [Metronome]  GPS         │  <- segmented tab switcher, raised pill
│                               │
│  ║          CADENCE          ║ <- knurled wheels, both edges
│  ║      ┌───────────┐        ║
│  ║      │    170    │        ║ <- recessed glass-panel readout
│  ║      └───────────┘        ║
│  ║           SPM             ║
│  ║          • ◦ ◦            ║ <- carousel position dots
│  ║      ╱╲  ╱╲╱╲   ╱╲        ║ <- mini live trace
│  ║                            ║
│  ║         ( ▶ )             ║ <- domed metronome toggle, cylindrical
│  ║                            ║
│  ├───────────────────────────┤
│  │  ⏮      ▶      ⏭         │  <- media row, muted, secondary
│  └───────────────────────────┘
└─────────────────────────────┘
```

Matches the agreed mockup. Carousel cards, in swipe order: Cadence → Speed →
Pace → Distance → Time. The wheels always adjust the underlying target
cadence regardless of which card is currently showing — swiping the carousel
changes what's *displayed*, not what the wheels *control*.

### 2. GPS tab

```
┌─────────────────────────────┐
│    Metronome  [GPS]          │  <- same switcher, GPS active
│  ║                            ║
│  ║  ┌─────────────────────┐  ║
│  ║  │      route map       │  ║  <- flutter_map, route polyline,
│  ║  │    ╱‾‾╲___╱‾╲        │  ║     calm-to-hot gradient by effort
│  ║  └─────────────────────┘  ║
│  ║                            ║
│  ║  ┌─────────┐ ┌──────────┐ ║
│  ║  │ TARGET  │ │ ACTUAL   │ ║  <- side-by-side comparison
│  ║  │  170    │ │  164 GPS │ ║
│  ║  └─────────┘ └──────────┘ ║
│  ║      ▼ 6 spm below        ║  <- delta indicator
│  ║                            ║
│  ║   6:41    3.2km   21:34   ║  <- pace / distance / elapsed row
│  ├───────────────────────────┤
│  │  ⏮      ▶      ⏭         │
│  └───────────────────────────┘
└─────────────────────────────┘
```

The wheels stay present and functional here — same shared target cadence as
the metronome tab, so a runner can nudge their goal mid-run without switching
tabs. The "ACTUAL · GPS" stat card gets a subtle `traceCalm`-tinted border to
visually distinguish measured-from-reality data from the user-set target.

**Map attribution**: a small "© OpenStreetMap contributors" credit in the
corner of the map, per OSM's usage requirements — don't omit this.

**Signal-lost state**: if GPS accuracy degrades below the filter threshold
for an extended period, the ACTUAL card should visibly indicate this (e.g.
dimmed number + "searching…" label) rather than silently freezing on a stale
number that looks current.

### 3. History

```
┌─────────────────────────────┐
│  History                     │
│                               │
│  ┌───┐  Tue 6:12 AM          │
│  │map│  32:10 · 168 spm      │  <- GPS session: route thumbnail
│  └───┘  4.8 km            >  │
│                               │
│  ┌───┐  Mon 7:04 PM          │
│  │~~~│  18:42 · 172 spm      │  <- metronome session: sparkline
│  └───┘  indoor            >  │
│                               │
└─────────────────────────────┘
```

Route thumbnail vs cadence sparkline is the visual signal for which mode a
past session was — no separate mode label/badge needed beyond that
distinction, keeps the row compact. Empty state: reuse
`shared/widgets/empty_state.dart`, direct copy in the app's own voice ("Run a
session to see it here"), same as the pose-estimation project's pattern.

## Wheel interaction spec (the part with real engineering weight)

This directly implements the "some weight, like good animation, not flat, I
want 3D" requirement — it's a real interaction spec, not just a visual one:

- **Drag** — vertical drag gesture on either wheel adjusts target cadence.
  Map drag distance to spm change using a fixed pixels-per-step ratio (tune
  during implementation, start around 8px per 1 spm change) — don't map 1:1
  to raw pixels, which would feel twitchy.
- **Momentum** — on release, if the drag had velocity, continue adjusting
  cadence with a friction-based deceleration (`FrictionSimulation` from
  `package:flutter/physics.dart`), so a fast flick keeps "spinning" briefly
  and settles, rather than stopping dead the instant your thumb lifts.
- **Detent snap** — cadence is always an integer spm; as the wheel settles,
  snap to the nearest whole value with a light spring (`SpringSimulation`),
  giving the "click into place" feel of a real mechanical dial rather than
  landing on an arbitrary fractional position.
- **Haptic feedback** — fire `HapticFeedback.selectionClick()) once per spm
  step crossed during a drag, not once per frame — this is what makes the
  wheel feel like it has real detents under your thumb instead of being a
  smooth featureless slider.
- **Visual sync** — the ridge pattern should visually scroll in the drag
  direction as the value changes (the illusion of the cylinder rotating),
  not stay static while only the number changes — this is what sells the "3D
  object being turned" feeling rather than "an invisible slider next to a
  decorative image."
- **Bounds** — clamp to a sane cadence range (e.g. 100-220 spm, matching
  what the existing commercial cadence apps researched earlier in this
  project use) with a soft resistance feel at the limits (the spring
  overshoots slightly then springs back) rather than a hard, jarring stop.

## Accessibility floor

Same non-negotiable baseline as the pose-estimation project: visible
focus/pressed states, color never the sole signal (the target/actual delta
uses both color and an explicit ▲/▼ + number, not color alone), 48x48dp
minimum touch targets, WCAG AA text contrast verified against both
`surfaceBase` and `surfacePanel`. Additionally here: the wheel must also be
operable via a non-gesture path (e.g. a small +/- stepper or double-tap
increment) for anyone who can't perform a sustained drag gesture — don't ship
the wheel as the *only* way to change cadence.
