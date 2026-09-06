# Project Roadmap & To-Do List

## 1. Pending Verification
- [ ] **SharedPreferences Testing**: Verify cold-start persistence on device/emulator for all settings (target cadence, mode, strides, colors, user height, audio tracks).

---

## 2. Movement Sub-Modes & Quick Cadence Presets
### Concept & UX Overview
Allow quick jumping to specific cadence intensities (SPM) with a single tap, while keeping the knurled wheel available for fine-tuning.

### Sub-Mode Hierarchy & Default Cadences
- **Walking** (single baseline stride length for all walk presets)
  - `Casual` (~100 SPM)
  - `Brisk` (~118 SPM)
  - `Power` (~132 SPM)
- **Jogging** (single baseline stride length for all jog presets)
  - `Easy` (~148 SPM)
  - `Steady` (~160 SPM)
- **Running** (single baseline stride length for all run presets)
  - `Aerobic` (~170 SPM)
  - `Efficient` (~180 SPM)
  - `Tempo` (~188 SPM)
  - `Sprint` (~200 SPM)

### Rules & Architecture
- **Single Stride Length Per Mode**: Each primary mode (Walk, Jog, Run) retains its single configured stride length; sub-modes only adjust the target cadence (SPM).
- **Expanded SPM Range**: Full cadence range expanded to support 60 – 240 SPM.
- **Main Screen UI**:
  - Selecting a primary mode displays its preset chips/boxes directly below the mode selector.
  - Tapping a preset instantly snaps the metronome cadence and updates speed/pace calculations.
  - Dragging the knurled wheel allows continuous single-step fine-tuning.
- **Settings Screen**:
  - Add configurable default SPM values for each preset sub-mode.
  - Persist all customized preset values via SharedPreferences.

---

## 3. Knurled Wheel Refinements & UI Enhancements
- [ ] Visual styling improvements and texture enhancements on the knurled drag bar.
- [ ] Enhanced haptics / tactile feedback during dragging and preset snapping.
- [ ] Smooth inertia / friction calibration and visual indicators for delta adjustments.

---

## 4. GPS & Live Tracking
- [ ] Make GPS tracking fully functional (convert current mockup UI to real live position updates).
- [ ] Integrate background geolocation stream with live speed/pace vs metronome target comparisons.
- [ ] Route mapping and session recording integration.
