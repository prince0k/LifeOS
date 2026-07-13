# Accessibility

**Document ID:** Accessibility.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** UI/UX Designer  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the **Accessibility (a11y) Standards** for LifeOS. These rules ensure the application remains perfectly usable for individuals with visual, motor, or cognitive impairments.

---

## 2. Objectives
- Ensure high readability in varying light conditions (e.g. during night shifts).
- Establish touch target size requirements to prevent motor friction.
- Integrate screen reader labels and haptic response targets.

---

## 3. Scope
This document covers font scaling, contrast targets, touch layouts, screen readers, and haptic feedback. It applies to all mobile interfaces and home screen widgets.

---

## 4. Technical Standards & Guidelines

### 4.1 Contrast Ratios (WCAG 2.1 AA Compliance)
- **Normal Text:** Must maintain a minimum contrast ratio of $4.5:1$ against the background.
- **Large Text (Headers):** Must maintain a minimum contrast ratio of $3.0:1$.
- **Dark Mode Surface:** Avoid pure black background headers with thin grey text. Card backgrounds must utilize clear contrast separation (`#181D26` surface on `#0E1117` background).

### 4.2 Font Scaling (Dynamic Type)
- The app layout must scale dynamically when the user changes system font sizes in Android/iOS settings.
- Text blocks must wrap and expand containers instead of clipping or displaying overflow warnings.

### 4.3 Touch Target Sizes
- **Minimum Target:** Interactive components (buttons, habit increments, task checkboxes) must have a minimum touch target size of $48\times 48$ density-independent pixels (dp).
- **Spacing:** Minimum spacing between adjacent buttons is 8dp to prevent accidental taps.

### 4.4 Screen Reader Support (Semantics)
- All image elements must include descriptive local alternative text.
- Form inputs (e.g. Sleep start sliders) must define semantic labels for screen readers (e.g. TalkBack on Android).
- Buttons must declare actionable labels (e.g. "Increment cigarette log" instead of "+1").

### 4.5 Haptic Feedback (Vibration triggers)
- **Log Increments:** Trigger a light, discrete haptic tap (`HapticFeedback.lightImpact`) on successful logs.
- **Errors/Reset Actions:** Trigger a double heavy vibration (`HapticFeedback.vibrate`) on validation failures or warning popups.

---

## 5. Dependencies
- **package:flutter/services.dart:** Accessing system haptic feedback drivers.

---

## 6. Acceptance Criteria
- Verified contrast levels pass validation testing.
- Activating Android TalkBack reads out the primary dashboard states and button actions correctly.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial draft defining accessibility standards. |
