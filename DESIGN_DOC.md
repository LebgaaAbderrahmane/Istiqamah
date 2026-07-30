# Design Doc
## Istiqamah — A Muslim-Focused Habit Tracker

**Version:** 1.0
**Companion to:** PRD.md
**Audience:** Yourself (or anyone reviewing your engineering approach)

---

## 1. Goals of this doc
Translate the PRD into concrete technical decisions: architecture, data model, streak algorithm, calendar heatmap rendering, and API integration — enough detail that you (or a reviewer) could start writing code directly from this.

---

## 2. Tech stack recommendation

Pick **one** based on what you want your portfolio to emphasize:

| Stack | Pick if... |
|---|---|
| **SwiftUI (iOS native)** | You want to show native iOS craft; best for App Store screenshots and smooth animations |
| **Flutter** | You want one codebase demoing both iOS + Android; good if applying broadly |
| **React Native (Expo)** | You're more JS/TS-fluent and want fast iteration + easy web preview via Expo Go |

This doc assumes a **local-first, no-backend** architecture regardless of stack — habit data lives entirely on-device.

**Suggested libraries (adjust per stack):**
- Local persistence: SQLite (via `expo-sqlite`, `sqflite`, or Core Data/SwiftData) — relational fits this data model well
- Calendar heatmap: build custom (simple enough — see §5) rather than pulling a heavy dependency
- Hijri date conversion: `HijriDate` (Swift), `hijri` package (Dart/Flutter), or `moment-hijri` (JS) — or compute via the Aladhan API's `gToH` endpoint to avoid a local conversion dependency entirely
- Charts/stats (should-have stat screen): native charting is simple enough here not to need a library — a few bar views suffice

---

## 3. Data model

### 3.1 Entities

```
Habit
  id: UUID
  name: String
  icon: String (icon identifier)
  type: enum { boolean, count, duration }
  targetValue: Int (e.g. 1 for boolean, 33 for dhikr, 20 for minutes)
  unit: String? (e.g. "pages", "minutes", nil for boolean)
  isCustom: Bool
  isArchived: Bool
  sortOrder: Int
  createdAt: Date

HabitLog
  id: UUID
  habitId: UUID (FK -> Habit.id)
  date: Date (stored as calendar day, no time component — e.g. "2026-07-30")
  value: Int (0/1 for boolean; actual count for count/duration types)
  loggedAt: Date (actual timestamp, for auditing/edit-cap logic)

AppSettings
  calendarPreference: enum { gregorian, hijri, both }
  theme: enum { light, dark, system }
  locationLat: Double?
  locationLng: Double?
  cityName: String?
  notificationsEnabled: Bool
  ramadanModeOverride: Bool? (null = auto-detect, else manual toggle)
```

### 3.2 Why this shape
- **Streaks are never stored** — always computed from `HabitLog` at read time (see §4). This is the single most important architectural decision in the app: storing a mutable `currentStreak` field invites bugs where the stored value drifts from the true log history (e.g. after a retroactive edit). Computing on read means it's always correct by construction.
- **`date` stored separately from `loggedAt`** lets you distinguish "the day this counts toward" from "when the user actually tapped it" — needed for the retroactive-edit cap (PRD §4.2) and for debugging.
- One `HabitLog` row per habit per day (upsert on repeat taps), not an append-only log — simpler queries, and daily granularity is all the product needs.

### 3.3 Indexing
- Index `HabitLog` on `(habitId, date)` — this is the hot path for both streak calculation and heatmap rendering.

---

## 4. Streak algorithm

### 4.1 Current streak (per habit)
```
function currentStreak(habitId, today):
    date = today
    streak = 0

    # If today isn't logged yet or is incomplete, don't break the streak —
    # just start counting from yesterday instead (see PRD §5.4, "hold until end of day")
    todayLog = getLog(habitId, today)
    if todayLog is None or not meetsTarget(todayLog):
        date = today - 1 day

    while true:
        log = getLog(habitId, date)
        if log exists and meetsTarget(log):
            streak += 1
            date = date - 1 day
        else:
            break

    return streak
```

`meetsTarget(log)` = `log.value >= habit.targetValue`.

### 4.2 Longest streak (per habit)
```
function longestStreak(habitId):
    logs = getAllLogs(habitId, orderBy: date ascending)
    longest = 0
    running = 0
    previousDate = None

    for log in logs:
        if not meetsTarget(log):
            running = 0
            previousDate = log.date
            continue

        if previousDate is not None and log.date == previousDate + 1 day:
            running += 1
        else:
            running = 1

        longest = max(longest, running)
        previousDate = log.date

    return longest
```

Runs in O(n) over that habit's logs — trivial at the scale of a personal habit tracker (thousands of rows at most).

### 4.3 Habit-created-mid-history guard
When computing streaks, never walk earlier than `habit.createdAt`. A habit's "eligible streak window" starts at creation, not at app install — otherwise a newly added habit looks broken from day one.

### 4.4 Testing this
This is the one part of the app that deserves real unit tests (and is genuinely impressive to show in a portfolio repo):
- Streak of 0 (no logs)
- Streak broken by exactly one missed day
- Streak held because today isn't logged yet
- Streak correctly ignores days before `habit.createdAt`
- Longest streak correctly identifies a past streak even after it's since broken
- Retroactive edit within the 7-day cap correctly recalculates both current and longest streak

Write these as a small test suite (`StreakCalculatorTests`) — screenshot or link this in your portfolio writeup as evidence of correctness-mindedness, not just UI polish.

---

## 5. Calendar heatmap rendering

### 5.1 Data needed per day
```
DayCompletion {
  date: Date
  completedCount: Int      // habits meeting target that day
  totalActiveHabits: Int   // habits active (not archived, created by that date) that day
  ratio: Float = completedCount / totalActiveHabits
}
```

Precompute this for the visible month range in one query (group `HabitLog` by date, join against active habit count for that date) rather than N+1 querying per day per habit.

### 5.2 Color bucketing
```
ratio == 0        -> bucket 0 (empty/base color)
0 < ratio <= 0.25  -> bucket 1
0.25 < ratio <= 0.5 -> bucket 2
0.5 < ratio <= 0.75 -> bucket 3
ratio > 0.75       -> bucket 4 (full intensity)
```
Map buckets to a single-hue color ramp (e.g. 5 shades of a chosen accent color) rather than a multi-hue scale — this reads as calmer and more "Islamic app" than a red-to-green GitHub-style ramp, and ties into the theming in §6.

### 5.3 Rendering approach
- Simple `Grid`/`LazyVGrid` (SwiftUI), `GridView` (Flutter), or CSS grid (RN via Flexbox) — one cell per day, 7 columns.
- Each cell: rounded rect, background = bucket color, tap gesture opens day-detail sheet.
- For Hijri month view: same rendering, just swap which calendar system generates the day boundaries for the grid (see §7).

### 5.4 Day-detail sheet
On tap: query all `HabitLog` rows for that date, list each active habit with a check/x or count value. Cheap query, no need to precompute this — only needed on demand.

---

## 6. Visual design direction

### 6.1 Principles (ties to PRD §4.7 tone requirements)
- **Calm, not gamified.** No confetti, no bright multi-color badge systems, no "streak fire 🔥" emoji spam. A single, restrained accent color per theme.
- **Geometric, not literal.** If using Islamic-inspired visual motifs, use subtle geometric patterns (8-point stars, tessellation) as background texture at low opacity — never literal imagery (mosque photos, etc.) which reads as stock-photo generic.
- **Typography:** a clean, slightly warm sans-serif (e.g. system font is fine) for UI; consider a distinct typeface only for the app name/wordmark if you want a signature touch.

### 6.2 Color palette (suggested starting point)
- **Light theme:** off-white/cream background (`#FAF7F2`), deep teal or emerald accent (`#0F6B5C` or similar), muted gold for highlights sparingly (`#C9A24B`) — evokes traditional manuscript/tilework palettes without being literal.
- **Dark theme:** near-black background (`#121212` or a deep navy `#0D1B1E`), same accent teal brightened slightly for contrast, gold used even more sparingly.
- Heatmap ramp: 5 shades of the accent teal, from near-background to full-saturation.

### 6.3 Iconography
- Use a consistent icon set (e.g. Lucide, Phosphor, or SF Symbols on iOS) for habit icons — don't mix icon styles.
- Default habit icons: simple, abstract (a crescent for prayer-related, a book for Quran, a droplet or hand for sadaqah, beads for dhikr) — avoid literal or culturally narrow imagery.

### 6.4 Key screens to actually design first (in order of portfolio impact)
1. Today screen — this is your hero screenshot
2. Calendar heatmap month view — your second hero screenshot
3. Habit detail with mini heatmap + streak numbers
4. Day-detail bottom sheet
5. Settings (lowest priority, keep simple)

---

## 7. Prayer times & Hijri date integration

### 7.1 Aladhan API
- Endpoint: `GET https://api.aladhan.com/v1/timingsByAddress` or `/timings` (by lat/lng) for daily prayer times.
- Endpoint: `GET https://api.aladhan.com/v1/gToH` for Gregorian→Hijri date conversion (avoids bundling a Hijri calendar library if you don't want to).
- No API key required — good for a fast portfolio build (no secrets management needed).
- Cache the day's response locally; only refetch on new day or location change, to avoid hammering the API and to keep the app usable offline for anything already-cached.

### 7.2 Fallback behavior
- If location permission denied and no manual city set: hide prayer-time display entirely, keep boolean prayer tracking fully functional. Never block core functionality on this integration — it's an enhancement, not a dependency.

### 7.3 Ramadan detection
- On app open, fetch Hijri date (via cached gToH call or local library).
- If Hijri month == 9 (Ramadan): flip `ramadanModeOverride` logic to show fasting/taraweeh habits automatically, unless the user has manually overridden this in settings.

---

## 8. Notifications (should-have)
- Local notifications only (no push infra needed) — scheduled using each day's fetched prayer times, ~10 minutes before each prayer.
- Reschedule daily (e.g. on app foreground, or via a background task if the platform supports it cheaply) since prayer times shift daily.
- Keep copy calm: "Asr in 10 minutes" — no exclamation marks, no urgency framing.

---

## 9. Testing & quality checklist before calling this "done" for a portfolio
- [ ] Streak calculator unit tests pass (see §4.4)
- [ ] Heatmap renders correctly for a month with zero data, partial data, and full data
- [ ] Adding a custom habit mid-month doesn't retroactively show false gaps
- [ ] Timezone/date-boundary behavior verified by changing device date manually
- [ ] Dark mode checked on every screen, not just Today
- [ ] Empty states designed for: first launch, habit with no logs yet, month with no data
- [ ] Offline behavior verified (airplane mode) — app should degrade gracefully, not crash, when prayer-time API is unreachable
- [ ] Record a 30–60 second screen capture walkthrough for the portfolio listing

---

## 10. Suggested repo structure (illustrative — adjust per stack)
```
/istiqamah
  /models          -> Habit, HabitLog, AppSettings
  /data            -> local DB layer, queries
  /logic
    streak.ts/.swift/.dart   -> pure functions, unit tested
    heatmap.ts/.swift/.dart  -> DayCompletion aggregation
  /api
    aladhan.ts       -> prayer times + Hijri conversion client
  /screens
    Today/
    Calendar/
    HabitDetail/
    Settings/
  /components        -> shared UI (HabitRow, HeatmapCell, StreakBadge)
  /theme             -> color tokens, typography
  /tests
    streak.test.ts
```
Keeping `/logic` free of any UI or database imports (pure functions in, plain data out) is what makes the streak logic testable and is worth calling out explicitly in your portfolio README as a deliberate architecture choice.
