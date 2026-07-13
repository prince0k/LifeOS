# 06 Glossary

**Document ID:** 06_Glossary.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** Product Owner  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to define the standard vocabulary, metrics, and core terminology utilized across the LifeOS application, design systems, and developer manuals.

---

## 2. Definitions & Vocabulary

### Recovery
The physiological and cognitive restoration process. In LifeOS, recovery is tracked manual-first via sleep metrics, energy levels, stress levels, and wellness checklists, and is valued as productive progress.

### Deep Work
A high-concentration, distraction-free focus block (typically in 25-minute Pomodoro-style intervals) dedicated to high-priority projects (Mailing, CityHost).

### Burnout Risk
A calculated user state triggered by consecutive low recovery scores ($\le 3$ days of score $< 50$). Under Burnout Risk, the system locks work blocks and hides project lists to enforce rest.

### Daily Planner
The interactive calendar grid interface that schedules tasks and time blocks for the active day, dynamically resizing and shifting based on shift templates.

### Brain Dump
A raw, unstructured text capture field where the user writes down thoughts, which are later processed into structured tasks, calendar blocks, or daily reviews.

### Focus Session
A scheduled focus block in the daily planner during which all notifications are silenced, and a countdown timer runs.

### Shift Template
A preconfigured set of timeblock profiles representing Morning, Night, 12-Hour, or Off shifts, defining work, rest, and deep work target slots.

### Consistency Score
A daily rating (0–100) computed based on the percentage of completed planner tasks and checked habits.

### Recovery Score
An automatic daily wellness index (0–100) calculated from sleep duration/quality, subjective energy, stress, and activity checks.

### Daily Win
An achievement badge awarded on days where the Consistency Score reaches $\ge 80\%$, yielding $+100$ XP.

---

## 3. Dependencies
- Upstream PRD documentation files.

---

## 4. Acceptance Criteria
- Definitions align consistently with the algorithms in the rules and scoring engines.

---

## 5. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Compiled baseline vocabulary definitions. |