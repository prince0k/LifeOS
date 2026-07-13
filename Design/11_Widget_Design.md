# 11 Widget Design

**Document ID:** 11_Widget_Design.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** UI/UX Designer  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the design tokens, visual boundaries, layouts, and interaction rules for the Android **Home Screen Widgets** of LifeOS (planned for Version 2.0).

---

## 2. Objectives
- Define sizes, layouts, and actions for the five core home screen widgets.
- Specify local database refresh triggers to minimize background battery draw.
- Address OS limits on widget rendering frames.

---

## 3. Scope
This document covers layout layouts and refresh guidelines for home screen widgets. It excludes native Android Glance code architecture, which is detailed in [22_Third_Party_Integrations.md](file:///d:/LifeOS/Technical/22_Third_Party_Integrations.md).

---

## 4. Widget Specifications

---

### 4.1 Dashboard Widget (WID-DASH)
- **Size:** $4\times 2$ grid slots.
- **Layout:** Horizontal split layout. Left side: active shift status and current task name. Right side: daily consistency score gauge.
- **Actions:** Tapping the widget launches the main application routing to the Dashboard tab.
- **Refresh Rules:** Refreshes on task status changes or when shift cycles transition.
- **Limitations:** Cannot display smooth animations; uses static state vector drawings.

---

### 4.2 Recovery Widget (WID-RECOV)
- **Size:** $2\times 2$ grid slots.
- **Layout:** Circular gauge showing computed Recovery Score and text label of the Recovery State (e.g. Fully Recovered).
- **Actions:** Tapping launches the app directly into the Daily Recovery Check-in overlay.
- **Refresh Rules:** Refreshes once daily upon check-in completion.
- **Limitations:** Falls back to a default grey state if no daily check-in has been completed.

---

### 4.3 Quick Log Widget (WID-LOG)
- **Size:** $2\times 1$ grid slots.
- **Layout:** Simple button row. Left button: $+1$ Cigarette icon. Right button: quick brain dump text box shortcut.
- **Actions:** Tapping $+1$ increments the count in the database in the background without launching the full app.
- **Refresh Rules:** Instant database updates.
- **Limitations:** OS limits button actions to a minimum threshold delay to prevent double-tap loops.

---

### 4.4 Deep Work Widget (WID-FOCUS)
- **Size:** $3\times 2$ grid slots.
- **Layout:** Focus timer display with Start/Stop action buttons.
- **Actions:** Start/Pause focus timer, select project.
- **Refresh Rules:** Updates every 1 minute during active focus sessions.
- **Limitations:** Running a active 1-second countdown on a home screen widget is prohibited due to high battery consumption; displays remaining minutes.

---

### 4.5 Today's Tasks Widget (WID-TASKS)
- **Size:** $4\times 3$ grid slots.
- **Layout:** Vertical checklist displaying the top 5 high-priority planner tasks for today.
- **Actions:** Checking off a task updates the database andConsistency scores in the background.
- **Refresh Rules:** Refreshes instantly on task updates.
- **Limitations:** Does not support rich task drag reordering.

---

## 5. Dependencies
- **MOD-Settings:** Source of widget visibility toggles.
- **22_Third_Party_Integrations.md:** Platform API adapters.

---

## 6. Acceptance Criteria
- Home screen widget layout matches design tokens in SCR-DASH.
- Background log increments work without launching the main Flutter activity.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial draft detailing home screen widget structures. |