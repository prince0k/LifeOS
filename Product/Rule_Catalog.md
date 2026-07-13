# Rule Catalog

**Document ID:** Rule_Catalog.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** Product Owner  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to maintain every business logic rule, calculation weighting, and system trigger of **LifeOS** in a single consolidated catalogue to ensure algorithmic alignment.

---

## 2. Master Rule Catalog

| Rule ID | Rule Description | Affected Modules |
|---|---|---|
| **RULE-SHIFT-001** | Load shift templates: Morning Shift (10:30-18:30), Night Shift (19:30-03:30), 12-Hour Shift (12:00-00:00), Off Day. | MOD-Planner |
| **RULE-RECOVERY-001** | Recovery score weightings: Sleep (40%), Energy (25%), Stress (25%), Habits (10%). | MOD-Recovery |
| **RULE-RECOVERY-002** | Recovery score formula: $RS = S \times 0.4 + E \times 0.25 + St \times 0.25 + H \times 0.1 + SP$. | MOD-Recovery |
| **RULE-RECOVERY-003** | Burnout Risk Escalation: Force state to Burnout Risk if $RS < 50$ for three consecutive days. | MOD-Recovery |
| **RULE-PLANNER-001** | Adaptive Capacity Scaling: Productive (100% tasks), Recovery (80%), Overloaded (50%), Burnout (0%). | MOD-Planner |
| **RULE-PLANNER-002** | Shift Priority Coordination: Night shifts place deep work in afternoon; Morning shifts in evening. | MOD-Planner |
| **RULE-PROJECT-001** | Project Prioritization: Mailing has absolute priority. CityHost is secondary. Suppress CityHost tasks first on low capacity. | MOD-Mailing, MOD-CityHost |
| **RULE-NOTIFICATION-001**| Shift-Based Alarm Offset Timings: Schedule alarms relative to loaded template (e.g. wake-up, shift start/end). | MOD-Notifications |
| **RULE-NOTIFICATION-002**| Focus Mode Suppression: Mute all non-essential habit/system reminders when Deep Work timer runs. | MOD-Notifications |
| **RULE-NOTIFICATION-003**| Recovery-Based Suppression: Suppress project and focus alerts if user state is Burnout Risk. | MOD-Notifications |
| **RULE-NOTIFICATION-004**| Silent Window: Suppress all alerts between sleep target and wake-up alarm window. | MOD-Notifications |
| **RULE-ANALYTICS-001** | Local-Only Aggregation: Chart calculations must run on-device; external tracking is prohibited. | MOD-Analytics |
| **RULE-BRAINDUMP-001** | One-Tap Processing: Convert notes lines instantly into tasks, projects, daily reviews, or delete. | MOD-BrainDump |
| **RULE-SETTINGS-001** | Local Backups: Data backup must prompt native share dialog to prevent storage permissions. | MOD-Settings |
| **RULE-GOAL-001** | Daily Consistency Score Formula: $CS = W_{tasks} \times TaskRate + W_{habits} \times HabitRate$. | MOD-Analytics |
| **RULE-GOAL-002** | Weekly Review Target: Sunday at 11:59 PM saves weekly summary and consistency scores to history logs. | MOD-Analytics |
| **RULE-GAME-001** | Habit Streaks: Streak multipliers ($1.2\times$ at 7 days, $1.5\times$ at 30 days) boost XP rewards. | MOD-Scoring |

---

## 3. Dependencies
- Upstream rules engine and scoring engine PRD sections.

---

## 4. Acceptance Criteria
- Business rules logic is consistently implemented in Dart codebase.

---

## 5. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Compiled and cataloged all business rules. |
