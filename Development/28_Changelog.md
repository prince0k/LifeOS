# 28 Changelog

**Document ID:** 28_Changelog.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to record the release history, version bumps, and semantic updates of the LifeOS product ecosystem.

---

## 2. Release History

### [1.0.0-alpha.3] — 2026-07-13
Implementation of Riverpod state providers and Dashboard UI screens.

#### Added
- Created `settingsProvider` pre-populating shift templates.
- Created `recoveryProvider` managing today's check-ins, calculations, and overrides.
- Implemented `DashboardScreen` showing active state banners and progress gauges.
- Created `RecoveryGauge` custom painter arc showing scores dynamically.
- Created `CheckInSheet` bottom modal sheet for user inputs.
- Created `dashboard_provider_test.dart` and refactored `widget_test.dart` to verify UI components.

### [1.0.0-alpha.2] — 2026-07-13
Implementation of recovery scoring mathematics and user state transition machine.

#### Added
- Scaffolded checklist activity constants in `activity_constants.dart`.
- Defined user states in `recovery_state.dart` enum.
- Created `RecoveryCalculator` representing sleep, energy, stress, and habits components.
- Integrated shift modifier metrics (Off Day, Night Shift, 12-Hour Shift).
- Programmed stateful transitions for burnout locks (RS < 50 for 3 days) and escape triggers (RS >= 70).
- Created `recovery_calculator_test.dart` verification suite.

### [1.0.0-alpha.1] — 2026-07-13
Initial codebase configuration, package integration, secure database scaffold, and unit test suites.

#### Added
- Initialized Flutter 3.44.6 stable workspace.
- Configured `pubspec.yaml` with third-party components (Hive, Riverpod, secure storage, fl_chart, google_fonts).
- Created 6 core Hive database models and generated code adapters.
- Created `DatabaseService` supporting on-device hardware-backed key derivation and unencrypted/encrypted box partitions.
- Created `database_service_test.dart` verification suite.

### [1.0.0-docs] — 2026-07-13
Centralized documentation release. All core design, technical engine, functional requirements, and guidelines files created and finalized.

#### Added
- 14 core PRD sections (`Executive_Summary.md` to `Future_Roadmap.md`).
- 6 PRD engine modules (`Decision_Engine.md` to `Search_and_Quick_Actions.md`).
- 6 technical design modules (`Notification_Engine.md` to `Performance_Budget.md`).
- 5 UI/UX design specifications (`UI_UX_Specification.md` to `Accessibility.md`).
- 4 catalogs and workflows (`User_Journeys.md` to `Rule_Catalog.md`).
- 4 developer standards files (`Project_Structure.md` to `Coding_Standards.md`).
- Established `task.md` and `walkthrough.md` tracking logs.

---

## 3. Versioning Guidelines
LifeOS conforms to Semantic Versioning ($MAJOR.MINOR.PATCH$):
- **MAJOR:** Significant functional updates or core principle adjustments.
- **MINOR:** New feature modules (e.g. task boards, widgets).
- **PATCH:** Minor bug fixes, performance optimizations, and documentation clean-ups.

---

## 4. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial changelog configuration detailing documentation releases. |