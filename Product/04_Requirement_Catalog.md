# 04 Requirement Catalog

**Document ID:** 04_Requirement_Catalog.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** Product Owner  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to maintain every functional, non-functional, and platform requirement of **LifeOS** in a single master index to ensure traceability across the software development lifecycle.

---

## 2. Master Requirement Catalog

| ID | Requirement Description | Module | Status |
|---|---|---|---|
| **REQ-DASH-001** | Show active shift template and current task on the dashboard. | MOD-Dashboard | Approved |
| **REQ-DASH-002** | Display computed Recovery State and Recovery Score visual gauges. | MOD-Dashboard | Approved |
| **REQ-DASH-003** | Display "Quick Log" button for smoking (+1 Cigarette). | MOD-Dashboard | Approved |
| **REQ-DASH-004** | Render today's adaptive timeline. | MOD-Dashboard | Approved |
| **REQ-DASH-005** | Display "Smart Recovery Recommendation" card on low score. | MOD-Dashboard | Approved |
| **REQ-PLAN-001** | Load shift templates: Morning Shift, Night Shift, 12-Hour, Off Day. | MOD-Planner | Approved |
| **REQ-PLAN-002** | Adjust timeline task placements based on active template. | MOD-Planner | Approved |
| **REQ-PLAN-003** | Allow manual drag, drop, and editing of schedule blocks. | MOD-Planner | Approved |
| **REQ-PLAN-004** | Suppress all project tasks when in Burnout Risk state. | MOD-Planner | Approved |
| **REQ-TASK-001** | Support task tags split by project or admin categories. | MOD-Tasks | Approved |
| **REQ-TASK-002** | Support task priority levels: High, Medium, Low. | MOD-Tasks | Approved |
| **REQ-TASK-003** | Update daily Consistency Score immediately on checking a task. | MOD-Tasks | Approved |
| **REQ-HABIT-001** | Support quick (+1) and detailed logging (trigger, mood) for habits. | MOD-Habits | Approved |
| **REQ-HABIT-002** | Query and aggregate app screen time via Android Usage Stats API. | MOD-Habits | Approved |
| **REQ-HABIT-003** | Support manual override and entry of screen time metrics. | MOD-Habits | Approved |
| **REQ-PROJECT-001** | Track hours worked, tasks list, and targets for Mailing. | MOD-Mailing | Approved |
| **REQ-PROJECT-002** | Categorize Mailing tasks under specific development headers. | MOD-Mailing | Approved |
| **REQ-PROJECT-003** | Track tasks, events, and hours for CityHost. | MOD-CityHost | Approved |
| **REQ-PROJECT-004** | Display a chronological list of campaigns and events. | MOD-CityHost | Approved |
| **REQ-SLEEP-001** | Prompt adaptive Daily Recovery Check-in for missing variables. | MOD-Sleep | Approved |
| **REQ-SLEEP-002** | Auto-import sleep duration via Health Connect if active. | MOD-Sleep | Approved |
| **REQ-SLEEP-003** | Calculate Recovery Score and transition Recovery State. | MOD-Recovery | Approved |
| **REQ-ANALYTICS-001** | Render historical charts for Consistency Score over time. | MOD-Analytics | Approved |
| **REQ-ANALYTICS-002** | Plot local correlations (e.g. stress rating vs. smoking count). | MOD-Analytics | Approved |
| **REQ-NOTIFICATION-001**| Schedule push alerts for alarms and habits locally. | MOD-Notifications | Approved |
| **REQ-NOTIFICATION-002**| Suppress reminders during Deep Work focus slots. | MOD-Notifications | Approved |
| **REQ-NOTE-001** | Support multi-line text input for Brain Dumps. | MOD-BrainDump | Approved |
| **REQ-NOTE-002** | Process Brain Dump line items to tasks, projects, or journals. | MOD-BrainDump | Approved |
| **REQ-NOTE-003** | Provide simple text Journal entries for daily review. | MOD-Journal | Approved |
| **REQ-SET-001** | Support data export to local encrypted JSON/SQLite file. | MOD-Settings | Approved |
| **REQ-SET-002** | Restore database via importing local backup file. | MOD-Settings | Approved |
| **REQ-SET-003** | Support customizing shift templates configuration. | MOD-Settings | Approved |
| **REQ-SET-004** | Support manual configuration of recovery weights. | MOD-Settings | Approved |
| **REQ-GOAL-001** | Calculate daily Consistency Score using rules-engine weightings. | MOD-Analytics | Approved |
| **REQ-GOAL-002** | Calculate weekly Focus Score using deep work targets. | MOD-Analytics | Approved |
| **REQ-NFR-001** | Cold start app launch time must be under 2.0s. | NFR | Approved |
| **REQ-NFR-002** | Database read query latencies must be under 50ms. | NFR | Approved |
| **REQ-NFR-003** | Database write transaction latencies must be under 50ms. | NFR | Approved |
| **REQ-NFR-005** | Standalone 100% offline local functionality. | NFR | Approved |
| **REQ-NFR-008** | APK compiled installation package size under 50MB. | NFR | Approved |
| **REQ-NFR-010** | Support AES-256 local database encryption. | NFR | Approved |

---

## 3. Dependencies
- Upstream PRD documentation files.

---

## 4. Acceptance Criteria
- Catalog updates synchronously with newly approved PRD sections.

---

## 5. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial compilation of requirements into a centralized catalog. |