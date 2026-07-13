# 05 Decision Log

**Document ID:** 05_Decision_Log.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** Product Owner  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to record and track every major architectural, technical, and product design decision made during the development of LifeOS, outlining the justification and implications for each.

---

## 2. Decision Index

| Decision ID | Decision | Status | Date Approved |
|---|---|---|---|
| **DEC-001** | **Offline First Architecture** | Approved | July 13, 2026 |
| **DEC-002** | **Single User Focus** | Approved | July 13, 2026 |
| **DEC-003** | **Zero Monthly Cost Commitment** | Approved | July 13, 2026 |
| **DEC-004** | **Hive Local NoSQL Database** | Approved | July 13, 2026 |
| **DEC-005** | **Flutter Framework** | Approved | July 13, 2026 |
| **DEC-006** | **Riverpod State Management** | Approved | July 13, 2026 |
| **DEC-007** | **Recovery Before Productivity Principle** | Approved | July 13, 2026 |
| **DEC-008** | **Adaptive Timetable Scheduling** | Approved | July 13, 2026 |
| **DEC-009** | **Local Data Ownership & Local Backups** | Approved | July 13, 2026 |
| **DEC-010** | **Documentation Before Development Workflow** | Approved | July 13, 2026 |

---

## 3. Detailed Decision Rationale

### DEC-001: Offline First
- **Rationale:** The target user runs rotating shifts and requires absolute utility regardless of internet stability. Disconnecting the app from network servers ensures zero synchronization lags and guarantees availability.
- **Implications:** The database engine must run on-device. Network calls are prohibited.

### DEC-004: Hive Local Database
- **Rationale:** Hive provides a lightweight, pure Dart NoSQL key-value database designed for Flutter. It out-performs SQLite for simple key-lookup operations, keeps memory footprints low, and supports encryption natively.
- **Implications:** Complex SQL joins must be modeled in memory via Riverpod providers.

### DEC-007: Recovery Before Productivity
- **Rationale:** Traditional schedule planners burn out users by suggesting rigid workloads when the user is fatigued. Shifting schedule targets based on sleep/stress prevents burnout.
- **Implications:** Daily Check-in completion blocks the normal loading of tasks until recovery states are computed.

---

## 4. Dependencies
- **00_Product_Constitution.md:** Provides guiding principles for decision rationale.

---

## 5. Acceptance Criteria
- Decisions marked as "Approved" are locked and cannot be violated by functional requirements.

---

## 6. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Compiled decision indexes and justification context. |