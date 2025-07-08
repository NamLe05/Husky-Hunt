# Audit Changes

**Audit Done By:** Group 11

## Leaderboard Button Semantics

We got feedback about improving the accessibility of the toggle that switches between monthly and all-time high scores on the leaderboard. Based on that suggestion, we updated the semantics so it works better with screen readers like TalkBack and VoiceOver.

Now, when the toggle is selected, it will clearly announce whether the leaderboard is showing **Monthly** or **All-Time** high scores. When we press on the toggle, it will also announce:  “Toggle here to view monthly vs high scores.”

This should make it easier for users with visual impairments to understand what they’re viewing and how to switch between modes.

## Changes We Didn’t Make

There was a suggestion about improving accessibility when the device is rotated. Specifically, the outline around certain elements wasn’t accessible in landscape mode.

We decided **not** to make this change, and here’s why:  
Husky Hunt is designed to be used in **portrait mode**, as it’s meant for students who are walking around and using the app to find locations, sort of like how Pokémon GO works. Because of that, the Map view and most UI elements are built to look and work best in portrait, and we think that’s the mode most players will stick with.

So for now, we’re keeping the layout portrait-first.
