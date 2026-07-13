# 10 Notifications Design

**Document ID:** 10_Notifications.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** UI/UX Designer  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the **Visual and Interactive Design Standards** for all local notifications, system-level alarms, banners, and push reminders in LifeOS.

---

## 2. Objectives
- Define notification visual layouts, text hierarchies, and color tokens.
- Establish vibration patterns and sound characteristics based on alert priority levels.
- Define actionable buttons for rapid input directly from notifications.

---

## 3. Scope
This document covers layout designs, copy rules, sound selections, and vibration patterns. It excludes the coding structure for platform notification services, located in [20_Notification_Engine.md](file:///d:/LifeOS/Technical/20_Notification_Engine.md).

---

## 4. Visual Layout & Actions

### 4.1 Critical Alarms (e.g. Wake-up Alarm)
- **Visuals:** Fullscreen overlay sheet or high-priority heads-up card. High-contrast Slate Blue header (`#4A5E8C`) with gold text.
- **Action Buttons:**
  1. **Dismiss:** Swipe to stop alarm.
  2. **Log Check-in:** Closes alarm and opens Recovery Check-in instantly.
- **Vibration Pattern:** Continuous pulsing pattern ($500\text{ms}$ vibrate, $250\text{ms}$ pause, repeat).
- **Sound:** Ascending volume, calming tone (custom sound file: `alarm_gentle.mp3`).

### 4.2 Habit Reminders (e.g. Smoking)
- **Visuals:** Standard Android push card. Small logo icon. Clear text: "Log Habit check. Did you smoke?"
- **Action Buttons:**
  1. **+1 Cigarette:** One-tap action from notification tray, increments count in background and dismisses.
  2. **Detailed Log:** Launches app and redirects to the detailed habits sheet.
- **Vibration Pattern:** Double brief vibration ($100\text{ms}$).
- **Sound:** Standard subtle system click (custom sound file: `click_subtle.mp3`).

### 4.3 Recovery Recommendations
- **Visuals:** Low-priority status bar card. Small recovery icon. Text: "Recovery state indicates rest is suggested."
- **Action Buttons:**
  1. **Accept:** Silences future project task reminder cards for the day.
- **Vibration:** None (silent).
- **Sound:** Silent.

---

## 5. Dependencies
- **Technical/20_Notification_Engine.md:** Platform notification scheduling implementation.
- **Design/09_Design_System.md:** Visual tokens and colors.

---

## 6. Acceptance Criteria
- Tapping action buttons completes operations in the background in under 100ms.
- Notification card layouts conform to Android Material 3 layouts.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial notifications design layout. |