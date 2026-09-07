# Project Roadmap & To-Do List

## 1. Pending Verification
- [x] **SharedPreferences Testing**: Verify cold-start persistence on device/emulator for all settings (target cadence, mode, strides, colors, user height, audio tracks).

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
- [x] Visual styling improvements and texture enhancements on the knurled drag bar.
- [x] Enhanced haptics / tactile feedback during dragging and preset snapping.
- [x] Smooth inertia / friction calibration and visual indicators for delta adjustments.

---

## 4. GPS & Live Tracking
- [x] Make GPS tracking fully functional (convert current mockup UI to real live position updates).
- [x] Integrate background geolocation stream with live speed/pace vs metronome target comparisons.
- [x] Route mapping and session recording integration.

---

## 5. Advanced Background Execution, Notifications & Granular Controls
- [ ] **Granular GPS Session Controls**: Separate Start, Pause, and Stop buttons (replacing the combined pause-as-stop behavior).
- [ ] **Background Foreground Services**: Implement native foreground services for both GPS tracking and Metronome to prevent OS suspension when app is minimized or locked.
- [ ] **Interactive Notification Bar Controls**:
  - Media/run playback controls (Play/Pause/Stop) directly in the notification tray for both Metronome and GPS.
  - **Smart Dismissal**: Notifications persist (sticky) while either session is active, and become dismissible (swipable) only once both sessions have ended.

1. GPS Controls: Start, Pause, & Stop
Currently, we have a toggle between Start and Pause (which acts as stop/pause). Separating them into three distinct controls gives you full workout management:

Start: Begins a fresh GPS tracking session.
Pause: Temporarily pauses recording (ignoring stationary jitter or movement while taking a break at a stoplight).
Stop: Finalizes and saves the run session to history, clearing the active route.
2. Background Execution (Foreground Services)
By default, mobile operating systems (iOS and Android) put apps to sleep or suspend location/audio streams when minimized or locked.

The Solution: We need a Foreground Service with a persistent notification (e.g., using packages like flutter_foreground_task or platform native services).
How it keeps running: A foreground service runs with an ongoing notification icon in the status bar, telling the OS: "This app is actively running an exercise session / metronome beat in the background, do not kill it."
3. Notification Bar Controls (Interactive Media/Run Notification)
Metronome Control: Play/Pause buttons right in the notification tray to control your tempo without unlocking your phone.
GPS Run Control: Pause/Resume/Stop buttons in the notification tray.
Smart Dismissal:
While either the Metronome or GPS is active, the notification persists and cannot be accidentally swiped away.
Once both sessions are fully stopped/ended, the notification releases its sticky flag so you (or the OS) can slide it away.