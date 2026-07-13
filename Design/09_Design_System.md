# 09 Design System

**Document ID:** 09_Design_System.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** UI/UX Designer  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the **Design System and Tokens** for LifeOS. These visual properties ensure a consistent Material 3 appearance across all application components, routes, and widgets.

---

## 2. Objectives
- Detail the light and dark color palettes, avoiding generic colors.
- Define typography scales using modern, premium fonts (e.g. Google Fonts Outfit / Inter).
- Standardize layout spacing, border radii, shadows, and animation parameters.

---

## 3. Scope
This document covers colors, typography, spacing, elevations, icons, and transitions. It applies to all Flutter widgets, home screen widgets, and layouts.

---

## 4. Design Tokens

### 4.1 Color Palettes (Material 3 Tailored HSL)
LifeOS utilizes a dark-first aesthetic tailored to rotating night/morning shift workers, minimizing eye strain.

| Token Name | Light Theme Hex | Dark Theme Hex | Purpose |
|---|---|---|---|
| **Primary (Slate Blue)** | `#4A5E8C` | `#A2B5E8` | Primary brand elements, active states. |
| **Secondary (Sage Green)** | `#5B6E59` | `#C2D6BF` | Positive habit completions, healthy markers. |
| **Tertiary (Warm Amber)** | `#8C6B4A` | `#E8C9A2` | Focus states, XP indicators, warnings. |
| **Background** | `#F8F9FA` | `#0E1117` | Screen backgrounds. |
| **Surface** | `#FFFFFF` | `#181D26` | Card backgrounds, list cells. |
| **Error (Ruby)** | `#B3261E` | `#F2B8B5` | Alert states, unhealthy habit spikes. |

### 4.2 Typography (Google Fonts: Outfit & Inter)
- **Brand/Headers Font:** *Outfit* (Geometric, premium structure).
- **Body Text Font:** *Inter* (High legibility at small sizes).

| Token Name | Font Family | Size | Weight |
|---|---|---|---|
| **Header Large** | Outfit | 32sp | Bold (700) |
| **Header Medium** | Outfit | 24sp | Medium (500) |
| **Title Medium** | Outfit | 18sp | Semi-Bold (600) |
| **Body Regular** | Inter | 14sp | Regular (400) |
| **Label Small** | Inter | 11sp | Medium (500) |

### 4.3 Spacing & Padding
Grid alignment conforms to an 8dp linear scale:
- `spacing-xs`: 4dp
- `spacing-sm`: 8dp
- `spacing-md`: 16dp
- `spacing-lg`: 24dp
- `spacing-xl`: 32dp

### 4.4 Elevation & Shadows (Material 3 Elevations)
- `elevation-0`: No shadow, flat layout.
- `elevation-1`: Blended surface overlay.
- `elevation-2` (Default Cards): Shadow blur 4dp, color offset `rgba(0,0,0,0.06)`.

### 4.5 Border Radius
- `radius-sm`: 4dp (Badge borders).
- `radius-md`: 12dp (Timetable cards, task checkboxes).
- `radius-lg`: 18dp (Bottom sheets, primary dashboard panels).

### 4.6 Animation Durations
- `duration-fast`: 150ms (Button presses, hover states).
- `duration-medium`: 300ms (Page transitions, bottom sheet overlays).
- `duration-slow`: 500ms (Level-up animations, dashboard shimmers).

---

## 5. Dependencies
- **package:google_fonts:** To download and load Outfit and Inter locally.

---

## 6. Acceptance Criteria
- App uses theme context tokens exclusively instead of hardcoded hex values.
- Dark mode activates automatically based on OS preferences.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial draft defining colors, fonts, and grid tokens. |