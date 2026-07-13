# 08 UI/UX Specification

**Document ID:** 08_UI_UX_Specification.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** UI/UX Designer  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to define the screen-level specifications, visual layouts, components, user actions, navigation pathways, and fallback states (empty, loading, error) for the nine core interfaces of LifeOS.

---

## 2. Navigation Architecture
LifeOS utilizes a **Bottom Navigation Bar** for primary navigation, with a top-level slide-out drawer or action sheets for secondary tools.
- **Primary Tabs:** Dashboard, Planner, Projects (Mailing/CityHost), Habits, Analytics.
- **Secondary Screens (Drawer/Overlay):** Recovery Check-in, Journal, Brain Dump, Settings.

---

## 3. Screen Specifications

---

### 3.1 Dashboard Screen (SCR-DASH)
- **Purpose:** Primary hub showing status overview, current schedule task, and quick logs.
- **Layout:** Single-page scrollable feed with sticky header.
- **Components:** Active Shift Card, Recovery Score Gauge, Next Task Block, Quick Log Button (+1 Cigarette), Recovery Recommendation Card.
- **Navigation:** Tapping Next Task opens Planner tab; tapping Recovery Gauge opens Recovery Check-in Sheet.
- **User Actions:** Increment habit, trigger shift override, open recovery check-in.
- **Empty States:** If no tasks are scheduled today, show a relaxing illustration with a button to "Add Tasks".
- **Error States:** Display generic warning banner if local sensors or permissions fail to query app usage.
- **Loading States:** Shimmer placeholder effects for charts and timetable components during cold start.
- **Edge Cases:** If user is in Burnout Risk, the dashboard must block focus timers and display rest suggestions.
- **Acceptance Criteria:** Loading the dashboard takes less than 2.0s. Increment logs write in <50ms.

---

### 3.2 Planner Screen (SCR-PLAN)
- **Purpose:** Timetable management and shift configurations.
- **Layout:** Vertical 24-hour hour grid with overlapping timeblock cards.
- **Components:** Day selector header, 96-grid (15-min intervals), task blocks, edit sheet overlay.
- **Navigation:** Tap task block to edit details; swipe left/right to change active day.
- **User Actions:** Drag blocks to reschedule, tap to edit, tap FAB to add new block.
- **Empty States:** On an Off Day with no tasks, show "Free day scheduled. Add blocks to plan."
- **Error/Loading States:** Spinner loading overlay when redrawing templates.
- **Edge Cases:** Resolving timezone changes safely without corrupting previous days.
- **Acceptance Criteria:** Drag-and-drop rescheduling redraws the list in under 50ms.

---

### 3.3 Recovery Screen (SCR-RECOV)
- **Purpose:** Conduct check-ins and review wellness trends.
- **Layout:** Step-by-step adaptive check-in form.
- **Components:** Sleep times sliders, quality checkboxes, mood selector chips, energy/stress ratings (1-10 sliders).
- **Navigation:** Redirects back to dashboard upon form submission.
- **User Actions:** Select sliders, check boxes, submit entry.
- **Empty States:** Not applicable (form inputs default to historic averages).
- **Edge Cases:** Hiding fields already known (e.g. sleep duration imported via Health Connect is auto-filled and hidden).
- **Acceptance Criteria:** Submitting form updates dashboard Recovery score in under 50ms.

---

### 3.4 Projects Screen (SCR-PROJ)
- **Purpose:** Main Kanban and hours tracker for Mailing and CityHost.
- **Layout:** Two-tab panel (Mailing Board, CityHost Board) with Kanban boards and progress meters.
- **Components:** Hours target bar, Task backlog columns (Todo, In Progress, Done).
- **User Actions:** Move task across columns, log hours, edit weekly target.
- **Empty States:** "No tasks active. Create a task to start your project."
- **Acceptance Criteria:** Dragging tasks updates status instantly.

---

### 3.5 Analytics Screen (SCR-ANAL)
- **Purpose:** Review local correlation charts and statistics.
- **Layout:** Tabbed charts interface (Consistency, Habits, Wellness correlations).
- **Components:** Weekly/Monthly toggle filters, Pearson Correlation scatter plots, App usage bars.
- **Empty States:** If logs count < 7 days, show: "Insufficient data. Complete 7 logs to unlock analytics."
- **Acceptance Criteria:** Aggregated charts load dynamically in under 100ms.

---

### 3.6 Habits Screen (SCR-HABIT)
- **Purpose:** Daily habit cards check-off and smoking logs.
- **Layout:** Grid of card widgets with quick toggle buttons.
- **Components:** App-specific screen time trackers, smoking increment tracker with trigger tags list.
- **User Actions:** Log habit, view habit detailed history, edit screen time logs.
- **Acceptance Criteria:** Tapping a habit updates consistency scores instantly.

---

### 3.7 Journal Screen (SCR-JOURN)
- **Purpose:** Record daily reviews and reflections.
- **Layout:** Multi-line text input field with calendar date header.
- **Components:** Daily prompt card, text area, formatting bar, save FAB.
- **Empty States:** Display writing prompts if text is blank (e.g. "What went well today?").
- **Acceptance Criteria:** Autosaves draft text to Hive box every 5 seconds.

---

### 3.8 Brain Dump Screen (SCR-DUMP)
- **Purpose:** Record and process multi-line ideas rapidly.
- **Layout:** Split interface (Input area on top, line-by-line list on bottom).
- **Components:** Raw text area, action chips (Task, Project, Journal, Trash) on each line.
- **User Actions:** Type notes, tap action chip on a line to process.
- **Acceptance Criteria:** Processing a line deletes it from notes list and creates target item instantly.

---

### 3.9 Settings Screen (SCR-SET)
- **Purpose:** Configure templates, themes, backups, and preferences.
- **Layout:** Vertical grouped list items.
- **Components:** Shift template sliders, recovery weights sliders, database backup/reset buttons.
- **User Actions:** Toggle preferences, export/import backups, customize sliders.
- **Acceptance Criteria:** Invalid settings configuration throws standard validation errors in-place.

---

## 4. Dependencies
- **MOD-Settings:** Source of preference profiles.
- **09_Design_System.md:** Visual constants and colors.

---

## 5. Acceptance Criteria
- All screens handle loading, empty, and validation-error states correctly.
- Layouts are responsive and scale across various aspect ratios on Android.

---

## 6. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial draft detailing screen specs and fallback states. |