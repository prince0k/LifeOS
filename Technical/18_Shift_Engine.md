# 18 Shift Engine Technical Design

**Document ID:** 18_Shift_Engine.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the technical implementation, layout managers, and scheduling algorithms that compose the **Shift Engine** (MOD-Planner) in LifeOS.

---

## 2. Objectives
- Initialize and manage the daily timeblock grid array.
- Apply shift templates dynamically to resolve available active hours.
- Coordinate task scheduling offsets based on templates.

---

## 3. Scope
This document covers time blocking array declarations, template parse interfaces, and task auto-placement methods in Version 1.0. It excludes frontend grid widgets.

---

## 4. Technical Specifications

### 4.1 Time Block Grid Representation
The Shift Engine models today's schedule using a list of 96 blocks representing 15-minute intervals:
```dart
class TimeBlock {
  final int index; // 0 to 95
  final String startTime; // "HH:MM"
  final String endTime; // "HH:MM"
  String? taskId; // References active task
  BlockType type; // Work, DeepWork, Rest, Personal, Available
}
```

### 4.2 Shift Template Parsing
Templates are loaded as profile records from the database and parsed into active constraints:
- **Night Shift Template:** Sets `type = BlockType.Work` for indices 78 to 95 (7:30 PM – 11:30 PM) and indices 0 to 14 (12:00 AM – 3:30 AM). Sets available Deep Work slots in indices 52 to 64 (1:00 PM – 4:00 PM).
- **Morning Shift Template:** Sets `type = BlockType.Work` for indices 42 to 74 (10:30 AM – 6:30 PM).

### 4.3 Task Auto-Placement Algorithm
1. Retrieve open tasks sorted by priority score ($TPS$) from the provider.
2. For each task:
   - Search the `TimeBlock` array for the earliest consecutive block segment matching the task's estimated duration where `type == BlockType.Available` or `BlockType.DeepWork` (depending on priority).
   - If a slot is found, write the `taskId` to those blocks and update block status.
   - If no slot matches, move task to the overflow backlog directory.

---

## 5. Dependencies
- **Product/02_Master_PRD/2.17_Adaptive_Planner.md:** Planner functional rules.
- **Technical/13_Database_Design.md:** DB schema.

---

## 6. Acceptance Criteria
- Timeblock arrays initialize successfully, resolving timezone changes.
- Auto-placement correctly aligns tasks around locked work hours.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial detailed shift scheduler engine architecture. |