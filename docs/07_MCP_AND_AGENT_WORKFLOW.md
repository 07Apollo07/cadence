# MCP and agent workflow

## Which MCP server to use

Same as the pose-estimation project: the **official Dart and Flutter MCP
server** (`dart mcp-server`, Dart SDK 3.9+). Confirm it's configured before
starting Milestone 0. It gives structured `pub get`, `analyze`, `format`,
`test`, hot reload, and runtime error/widget-tree introspection against a
running app — see the pose-estimation project's `07_MCP_AND_AGENT_WORKFLOW.md`
for the full description if needed; it isn't repeated in full here.

## The build loop, per task

Identical loop to the pose-estimation project:

1. Write the code for the task.
2. Format + analyze via MCP, fix everything before moving on.
3. Run relevant unit tests via MCP for any `domain/` change.
4. For any widget/UI change, hot-reload and pull runtime errors via MCP's
   introspection — a widget task isn't done just because it compiles.
5. Only proceed once 2-4 are clean.

## What's different about this project's self-testing gaps

Two things in this app cannot be fully verified by an agent working alone,
and should be flagged clearly rather than silently assumed to work:

- **Real audio timing.** The beat scheduler's *logic* is fully testable
  against a virtual clock (Milestone 1's gate). Whether the actual audio
  output on real hardware is perceptibly steady — accounting for real
  `just_audio` playback latency, not just the scheduling math — can only be
  confirmed by a human listening on a real device. Don't claim this
  milestone is "done" in the audible sense; claim the *scheduling logic* is
  verified, and say so precisely in the handoff.
- **Real media-key control of another app.** The `AudioManager.dispatch
  MediaKeyEvent` bridge can be exercised in isolation (does the method
  channel call succeed, does the platform code compile and run without
  throwing), but confirming it actually pauses/resumes a real backgrounded
  Spotify/YouTube Music/podcast app requires a human running that specific
  scenario on a real device with a real app playing. Flag this explicitly
  as unverified-by-agent in the Milestone 4 handoff note, not silently
  assumed to work because the method channel call didn't error.

For both of these, use the fake-service pattern (fake landmark stream in the
pose-estimation project, fake `LocationService` and virtual-clock scheduler
here) to verify everything *except* the specific real-world sensory outcome
— that's the honest boundary of what agent-only testing can cover, and it's
worth being precise about that boundary rather than overclaiming.

## GPS-specific note

Milestone 5's `gps_session_flow_test.dart` uses the fake `LocationService`
exactly like the pose-estimation project used a fake pose stream — this lets
the agent verify the full filter → aggregate → derive-cadence → save pipeline
without needing to physically go outside and run. Real-GPS verification
(actual accuracy, actual foreground-service behavior when the screen locks)
is explicitly a Milestone 7 human task, not something to fake further or
skip.

## What to hand back to the human

At the end of Milestone 7, summarize:

- Task completion status against `06_TASK_BREAKDOWN.md`.
- Test results (`flutter test` / `flutter analyze` output).
- Any constant changed from its spec starting value (wheel sensitivity, GPS
  filter thresholds, beat scheduler lookahead window) and why.
- The two explicitly-unverified-by-agent items above (real audio feel, real
  media-key control against a real third-party app) — call these out by
  name so the human knows exactly what still needs a real-device check
  before considering the app finished, not just handed off.
- Anything from the edge-case lists (Milestone 7, and the "edge cases" style
  notes in `02_AUDIO_AND_GPS_SPEC.md`) deliberately deferred, and why.
