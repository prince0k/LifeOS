# User Journeys

**Document ID:** User_Journeys.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** Product Owner  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the end-to-end **User Journeys** of LifeOS. These step-by-step walk-throughs detail how the application responds dynamically to the user's rotating shifts, stress factors, and fatigue, ensuring a seamless user experience.

---

## 2. Master User Journeys

---

### Journey 1: Morning Shift Day
- **Trigger:** Active calendar date is configured with a "Morning Shift" template.
- **Starting State:** User wakes up, state is initialized to "Productive" (based on previous day).
- **User Actions:**
  1. Complete Recovery check-in upon waking up.
  2. Log 2 cigarettes at work using the Quick Log dashboard button.
  3. Start a 2-hour Deep Work focus session in the evening (after shift).
- **System Responses:**
  1. Displays the Morning Shift timetable layout (10:30 AM – 6:30 PM).
  2. Discharges the wake-up alarm at 09:30 AM and shift start alert at 10:15 AM.
  3. Increments smoking log metrics and maps timestamps.
- **Rules Applied:** `RULE-SHIFT-001` (Morning template loader), `RULE-DEC-001` (Focus placement).
- **Recovery Adjustments:** None (normal capacity).
- **Completion Criteria:** User saves end-of-day review journal, target sleep lock triggers at 11:00 PM.

---

### Journey 2: Night Shift Day
- **Trigger:** Active day configured with "Night Shift" template.
- **Starting State:** User wakes up, state = "Moderate Recovery".
- **User Actions:**
  1. Complete check-in at 11:30 AM.
  2. Launch a 3-hour Deep Work focus session in the afternoon (before shift).
  3. Execute shift duties.
- **System Responses:**
  1. Displays the Night Shift timetable layout (7:30 PM – 3:30 AM).
  2. Positions Deep Work blocks between 1:00 PM and 4:00 PM.
  3. Silences notifications during shift work.
- **Rules Applied:** `RULE-SHIFT-001`, `RULE-PLANNER-002` (Night shift block placement).
- **Recovery Adjustments:** Reduces non-essential evening notifications to allow shift concentration.
- **Completion Criteria:** User logs sleep wind-down at 3:45 AM.

---

### Journey 3: 12-Hour Shift Day
- **Trigger:** Active day configured with "12-Hour Shift" template.
- **Starting State:** User wakes up, state = "Low Recovery" due to previous long shifts.
- **User Actions:**
  1. Opens dashboard at 10:30 AM.
  2. Logs a quick walk during lunch breaks.
- **System Responses:**
  1. Displays the 12-Hour Shift timetable layout (12:00 PM – 12:00 AM).
  2. **Automatically hides all project task lists (Mailing & CityHost)**.
  3. Disables all focus session buttons.
- **Rules Applied:** `RULE-PLANNER-001` (Capacity set to 0% for projects).
- **Recovery Adjustments:** Shifts schedule focus entirely to basic health (sleep target: 12:30 AM).
- **Completion Criteria:** User checks off "Water completed" and closes the app.

---

### Journey 4: Off Day
- **Trigger:** Active day configured with "Off Day" template.
- **Starting State:** State = "Fully Recovered" (Sleep duration $\ge 8.5$ hours).
- **User Actions:**
  1. Open app at 8:00 AM.
  2. Complete 4 hours of Deep Work (Mailing primary, CityHost secondary).
  3. Execute Sunday Weekly Review & Planning at 5:00 PM.
- **System Responses:**
  1. Loads 100% capacity planner.
  2. Emphasizes extended focus slots in the morning.
- **Rules Applied:** `RULE-SHIFT-001`, `RULE-GAME-003` (Weekly win review).
- **Completion Criteria:** Weekly target hours saved.

---

### Journey 5: Recovery Day
- **Trigger:** Check-in inputs yield a Recovery Score between 60 and 69.
- **Starting State:** State = "Moderate Recovery".
- **User Actions:**
  1. Completes check-in.
  2. Executes only 3 high-priority Mailing tasks.
- **System Responses:**
  1. Scales planner task capacity down to $80\%$.
  2. Hides low-priority/optional task cards.
- **Rules Applied:** `RULE-PLANNER-001` (80% scaling).
- **Completion Criteria:** Daily win updated with scaled targets.

---

### Journey 6: Burnout Recovery
- **Trigger:** Recovery Score falls below 40, or falls below 50 for 3 consecutive days.
- **Starting State:** State = "Burnout Risk".
- **User Actions:**
  1. App open.
  2. Checks off "Brain Dump completed" and "Water completed".
- **System Responses:**
  1. Lock system to "Mandatory Rest Day".
  2. Hide all work lists and deep work timers.
  3. Displays a prominent Recovery Recommendation Card (Hydration, walks).
- **Rules Applied:** `RULE-RECOVERY-003` (Burnout escalation), `RULE-PLANNER-001` (0% project capacity).
- **Completion Criteria:** User maintains rest for 24 hours.

---

### Journey 7: Missed Day Recovery
- **Trigger:** Calendar day passes with zero user log entries.
- **Starting State:** Next day launch, State = initialized to default "Recovery" state.
- **User Actions:**
  1. Tap "Backfill Previous Day" on the dashboard warning card.
  2. Input yesterday's sleep and basic habits count (cigarettes, screen time).
- **System Responses:**
  1. Opens backfill overlay.
  2. Recalculates yesterday's Consistency and Recovery scores.
  3. Adjusts today's schedule based on the backfilled recovery history.
- **Rules Applied:** `RULE-GOAL-001` (Consistency recalculation).
- **Completion Criteria:** Historical database update confirms.

---

### Journey 8: Travel Day
- **Trigger:** Device timezone shift detected by the OS.
- **Starting State:** State = "Moderate Recovery" (due to travel fatigue).
- **User Actions:**
  1. Confirm local time adjustments.
  2. Log habits on the adjusted daily timeline.
- **System Responses:**
  1. Locks yesterday's completed score.
  2. Rebuilds today's timeline based on the new local time offsets.
- **Rules Applied:** Local system time sync rules.
- **Completion Criteria:** Logs persist using absolute UTC timestamps.

---

## 3. Dependencies
- **MOD-Recovery & MOD-Planner:** Dynamic execution blocks.
- **MOD-Settings:** Source of timezone controls.

---

## 4. Acceptance Criteria
- Simulating timezone shifts does not corrupt daily logging registers.
- All journeys compile successfully without requiring undocumented workarounds.

---

## 5. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial draft defining user journeys. |
