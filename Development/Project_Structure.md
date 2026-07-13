# Project Structure

**Document ID:** Project_Structure.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to define the physical directory layout, package structures, and architectural boundaries of the LifeOS codebase. This ensures the application remains modular, testable, and clean as new features are added.

---

## 2. Directory Layout
LifeOS utilizes a **Feature-First** architecture. Code is organized into standalone feature directories, supported by centralized core and shared service layers.

```text
lib/
├── main.dart                  # Application entry point & service initialization
│
├── core/                      # Global app-level specifications & components
│   ├── theme/                 # Material 3 colors & fonts (from Design Tokens)
│   ├── routing/               # GoRouter paths & transitions
│   └── constants/             # Global configurations & local keys
│
├── shared/                    # Reusable elements shared across features
│   ├── widgets/               # Custom UI controls, buttons, cards
│   ├── services/              # Core SQLite/Hive database drivers & platform wrappers
│   └── models/                # Abstract data models & serializable adapters
│
└── features/                  # Independent feature modules
    ├── dashboard/             # MOD-Dashboard views & controllers
    ├── planner/               # MOD-Planner time-blocking grid & templates
    ├── tasks/                 # MOD-Tasks backlog list & categorizations
    ├── habits/                # MOD-Habits log, screen-time sync, and triggers
    ├── projects/              # MOD-Mailing and MOD-CityHost Kanban boards
    ├── recovery/              # MOD-Sleep & MOD-Recovery calculations & check-in
    ├── analytics/             # MOD-Analytics aggregation & charts
    ├── journal/               # MOD-Journal & MOD-BrainDump text processing
    └── settings/              # MOD-Settings backup export & config preference
```

---

## 3. Architectural Boundaries
To maintain maintainability and clean boundaries, the following rules must be enforced during code reviews:
- **Feature Isolation:** Feature directories must not import components directly from other features. Any cross-feature state interactions must route through global Riverpod providers in the `shared/` layer.
- **Data Locality:** Database adapters (Hive boxes) must reside inside their respective features, but register their TypeAdapters inside `shared/services/database/` to ensure safe app boot initialization.
- **UI Decoupling:** UI widgets must never initiate database transactions directly. All mutations must go through Riverpod notifier providers.

---

## 4. Dependencies
- **package:riverpod:** State injection and provider scaffolding.
- **package:hive:** Data persistence.

---

## 5. Acceptance Criteria
- Folder structure matches the defined architecture layout.
- Static analysis checks (Lints) enforce feature isolation, throwing warnings on circular imports.

---

## 6. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial draft defining directories and package boundaries. |
