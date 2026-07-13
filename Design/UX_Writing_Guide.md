# UX Writing Guide

**Document ID:** UX_Writing_Guide.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** UI/UX Designer  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the tone, voice, and copy standards for all user-facing text in LifeOS. Consistent phrasing reduces cognitive load and maintains the supportive, consistency-focused product identity.

---

## 2. Voice & Tone
- **Supportive, Never Judgmental:** The application never scolds the user for missing habits or targets (e.g. smoking increases). Instead, it highlights recovery options and consistency paths.
- **Clear & Actionable:** Buttons and messages must clearly describe what action will occur, avoiding ambiguous words.
- **Empathetic & Calming:** Focuses on recovery. Prefers words like "Rest," "Recharge," and "Wind Down."

---

## 3. Copy Specifications

### 3.1 Button Labels
- **Preferred:** Action verb + Object (e.g. "Save Task", "Complete Check-in", "Log Cigarette").
- **Avoid:** Generic "OK", "Submit", "Proceed" if a specific action exists.
- **System Resets:** The confirmation button must read "Delete All Data" instead of "Confirm."

### 3.2 Error Phrasing
- **Rule:** Never display raw system stack traces (e.g. "HiveException: Lock failed"). Explain what happened and how to recover.
- **Example (Import Fail):** "Unable to read backup file. The file might be corrupted or created in a newer app version. Please verify the file and try again."
- **Example (Invalid Recovery Weights):** "Total weight must equal 100%. Currently at [Sum]%. Adjust sliders to match."

### 3.3 Success Messages
- **Rule:** Keep toast alerts brief and dismissible within 1.5 seconds.
- **Examples:**
  - "Backup saved successfully."
  - "Level Up! You reached Level [Number]."
  - "Daily Win achieved!"

### 3.4 Empty States
- **Daily Planner:** "No tasks scheduled for today. Tap + to add, or enjoy a recovery rest."
- **Brain Dump:** "No ideas captured. Write down raw thoughts here and process them later."

### 3.5 Recovery State Cards
- **Burnout Risk:** "System overloaded. Project tasks are hidden. Focus on hydration, a walk, and getting to sleep early tonight."
- **Productive:** "High energy detected. Excellent time for a Deep Work focus session."

---

## 4. Dependencies
- **08_UI_UX_Specification.md:** Defines screens where copy renders.

---

## 5. Acceptance Criteria
- App copy matches the standards defined in this guide.
- Localized language variables utilize these strings.

---

## 6. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial draft establishing copywriting rules. |
