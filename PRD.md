# Product Requirements Document
## Istiqamah — A Muslim-Focused Habit Tracker

**Version:** 1.0
**Status:** Draft for portfolio build
**Owner:** [Your name]
**Last updated:** July 30, 2026

---

## 1. Overview

### 1.1 Problem statement
Existing habit trackers are generic — they treat "pray" the same as "drink water." Muslims building consistency in worship (prayer, Quran, dhikr, fasting, charity) don't have a lightweight, non-intrusive tool that understands the *shape* of their habits: five daily prayers instead of one checkbox, Hijri dates, Ramadan-specific routines, and a tone that motivates without guilt-tripping.

### 1.2 Product vision
A calm, focused habit tracker that helps Muslims build and sustain religious and personal habits through visual streaks, a GitHub-style calendar heatmap, and gentle, non-gamified encouragement — rooted in the concept of *istiqamah* (steadfast consistency), not perfection.

### 1.3 Goals
- Ship a fully working, polished mobile app suitable as a portfolio centerpiece
- Demonstrate: local data modeling, streak/date logic, calendar heatmap UI, API integration (prayer times), theming, and thoughtful UX copywriting
- Keep scope small enough to finish in 1–3 weeks solo

### 1.4 Non-goals (explicitly out of scope for v1)
- Social features (following friends, leaderboards, sharing streaks publicly)
- Backend/account system — v1 is fully local, no login
- Push notification infrastructure beyond local device notifications
- Multi-language/RTL support (Arabic UI) — noted as a fast-follow, not v1
- Android + iOS simultaneously if using a native stack — pick one first unless using Flutter/RN

### 1.5 Target user
A practicing Muslim, roughly 18–40, who already has some routine but wants a visual way to stay consistent and notice patterns — not someone being introduced to the concept of prayer from scratch. Assume basic familiarity with Islamic terms (no need to explain what Fajr is).

---

## 2. Success metrics (portfolio context)
Since this isn't shipping to real users initially, "success" = quality bar for a hiring manager or client reviewing it:
- App has zero placeholder/lorem-ipsum screens — every screen is fully functional
- Streak logic is provably correct (unit tested)
- Visually distinct — doesn't look like a Bootstrap/Material default template
- At least one non-trivial integration (prayer times API + Hijri calendar) works live
- Demo-able in under 60 seconds (record a screen capture walkthrough for the portfolio)

---

## 3. User stories

### Must-have (v1)
1. As a user, I can see today's habits as a checklist and mark them complete with one tap.
2. As a user, each of the 5 daily prayers is tracked individually, not as one lump "prayer" checkbox.
3. As a user, I can see my current streak and longest streak for each habit.
4. As a user, I can view a calendar heatmap where color intensity reflects how many habits I completed that day.
5. As a user, I can tap any day in the heatmap to see exactly what I completed that day.
6. As a user, I can add a custom habit beyond the defaults (name + icon + type).
7. As a user, I can see both Hijri and Gregorian dates.
8. As a user, when I miss a day, the app's messaging is encouraging, not punishing.
9. As a user, my data persists locally between app launches without needing an account.

### Should-have (v1 if time allows)
10. As a user, I can see live prayer times for my location and get reminded near each prayer window.
11. As a user, during Ramadan the app automatically surfaces fasting + taraweeh + suhoor/iftar tracking.
12. As a user, I can toggle dark/light theme.
13. As a user, I can see a simple weekly stats summary (completion %, best/worst habit).

### Could-have (fast-follow, not v1)
14. As a user, I can write a short optional reflection note per day or per week.
15. As a user, I can back up/export my data (JSON export) in case I switch devices.
16. As a user, I can view the app in Arabic with RTL layout.

### Won't-have (v1)
17. Social sharing, friend streaks, or public leaderboards.
18. Cloud sync / multi-device accounts.

---

## 4. Functional requirements

### 4.1 Habits
- Default habit set, seeded on first launch:
  | Habit | Type | Default target |
  |---|---|---|
  | Fajr | Boolean | 1x/day |
  | Dhuhr | Boolean | 1x/day |
  | Asr | Boolean | 1x/day |
  | Maghrib | Boolean | 1x/day |
  | Isha | Boolean | 1x/day |
  | Quran reading | Count (pages or minutes) | user-set, default 1 page |
  | Dhikr/Tasbih | Count | user-set, default 33 |
  | Sadaqah | Boolean | 1x/day |
  | Qiyam al-layl | Boolean | opt-in, off by default |
- User can archive (not delete — preserve history) any default habit.
- User can create custom habits with: name, icon (from a curated set), type (boolean / count / duration), and target.
- Habits can be reordered.

### 4.2 Logging
- Tapping a boolean habit toggles complete/incomplete for *today only*.
- Count/duration habits open a small stepper/input (e.g. +1 page, or a number pad for dhikr count).
- Past days are editable (user forgot to log yesterday) but capped — e.g. can only edit up to 7 days back, to discourage retroactive streak gaming. This cap is a product decision worth stating explicitly, since it affects streak integrity.
- All edits are local, instant, no loading spinners needed.

### 4.3 Streaks
- **Current streak** = number of consecutive days (ending today or yesterday) where the habit's target was met.
  - If today isn't logged yet, the streak "holds" using yesterday's value until end of day (don't zero it out just because it's 9am and they haven't prayed Fajr's checkbox yet — see edge cases in Design Doc).
- **Longest streak** = maximum consecutive run in the habit's entire history.
- Streaks are always computed from `HabitLog` data, never stored as a mutable field (avoids sync bugs — see Design Doc §3).

### 4.4 Calendar heatmap
- Month-grid view, one cell per day.
- Color intensity bucketed by `completedHabits / activeHabits` for that day (5 buckets: 0%, 1-25%, 26-50%, 51-75%, 76-100%).
- Tapping a day opens a day-detail sheet showing each habit's status that day.
- Supports both Gregorian and Hijri month navigation (toggle in settings; Hijri month grid pulls boundaries from the Aladhan API or a local Hijri conversion library).

### 4.5 Prayer times integration (should-have)
- On first launch (or manual entry), request location permission → call Aladhan API for the day's 5 prayer times.
- Display prayer times on the Today screen alongside each prayer habit.
- Optional local notification ~10 minutes before each prayer time ("Asr is approaching").
- Graceful fallback if location is denied: user can manually enter a city, or skip and use boolean-only tracking with no times shown.

### 4.6 Ramadan mode (should-have)
- Detect Ramadan via Hijri date (either from API or offline Hijri calendar calculation).
- When active: auto-surface fasting tracking (Suhoor eaten / Fast completed / Iftar), and Taraweeh as an optional habit for the month only. Reverts automatically after Eid.

### 4.7 Tone & copywriting requirements
This is a first-class requirement, not a nice-to-have — it's what differentiates this app.
- No punitive language anywhere. Examples:
  - Missed day: "You missed yesterday — bismillah, let's continue today." NOT "Streak broken! 💔"
  - Empty state: "Your journey starts today." NOT "No data yet."
- No comparison to other users, no leaderboard language, ever.
- Icons/illustrations should avoid cartoonish gamification (no confetti explosions, no "you leveled up!"). Subtle, calm micro-animations only (a soft checkmark fade-in is fine).

---

## 5. Edge cases & business logic decisions
These need explicit decisions before/during build, since they affect streak correctness (a core technical showcase piece):

1. **Timezone changes** (user travels) — streaks use device local date, recalculated on each app open. Document this rather than trying to solve travel-timezone edge cases perfectly in v1.
2. **Habit added mid-history** — streak calculation starts from the habit's `createdAt` date, not from app install date, so a new habit doesn't inherit false "0 streak" penalty for days it didn't exist.
3. **Habit archived and reactivated** — decide whether streak resumes or resets. Recommendation: resets (simpler, and archiving implies an intentional pause).
4. **"Streak holds until end of day" logic** — a boolean habit not yet logged today should not show as "streak broken" until the day actually ends (midnight local time). This avoids the app looking broken every morning before Fajr is even logged.
5. **Retroactive edit cap** — see §4.2. Prevents a user (or demo reviewer) from "faking" a huge streak by backfilling months of data, which would undercut trust in the streak number.

---

## 6. Release plan (portfolio-scoped)

| Milestone | Scope | Est. time |
|---|---|---|
| M1 — Core MVP | Today checklist, streak calc, basic heatmap, local persistence, default habits | 3–5 days |
| M2 — Calendar + custom habits | Full heatmap with day-detail, add/edit/archive custom habits, Hijri date display | 2–3 days |
| M3 — Prayer times + Ramadan mode | Aladhan API integration, notifications, Ramadan auto-detect | 2–3 days |
| M4 — Polish | Theming (dark/light), empty states, animations, copywriting pass, app icon, screenshots for portfolio | 2–3 days |

**Total: ~9–14 days** for a fully polished v1.

---

## 7. Open questions
- Native (SwiftUI/Kotlin) vs. cross-platform (Flutter/React Native)? Affects which platform's design language to lean into.
- Should Quran reading track pages, minutes, or juz' progress? (Pages is simplest and most demo-friendly.)
- Is Arabic/RTL support worth doing for v1, or purely a "mentioned as future work" line in the portfolio writeup? (Recommendation: mention only, skip building — it roughly doubles UI QA effort.)
