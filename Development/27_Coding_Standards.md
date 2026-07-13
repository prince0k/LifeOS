# 27 Coding Standards

**Document ID:** 27_Coding_Standards.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to define the programming guidelines, conventions, naming standards, and architectural boundaries for the Dart and Flutter codebase in LifeOS.

---

## 2. Naming Conventions

### 2.1 File & Directory Names
- **Rule:** Use `snake_case` for all files and directories.
- **Example:** `daily_planner_widget.dart`

### 2.2 Classes & Widgets
- **Rule:** Use `PascalCase` for all classes, enums, extensions, and widgets.
- **Example:** `class DashboardScreen extends ConsumerWidget`

### 2.3 Variables & Functions
- **Rule:** Use `camelCase` for all variables, constants, properties, and functions.
- **Example:** `final int dailyCigaretteLimit = 10;`

---

## 3. State Management Rules (Riverpod)
- **Notifier Usage:** Use `Notifier` or `AsyncNotifier` for complex state mutations. Avoid `StateProvider` for values manipulated by multiple widgets.
- **State Read:** Use `ref.watch()` in build methods for reactive rebuilds. Use `ref.read()` inside event callbacks (e.g. `onPressed`) to avoid unnecessary rebuild loops.
- **State Immutability:** All states emitted by providers must be immutable. Use `@freezed` or `.copyWith()` for mutating model attributes.

---

## 4. Error Handling & Logging Standards

### 4.1 Error Handling
- **Rule:** Never catch broad exceptions (e.g. `catch(e)`) without logging them and alerting the UI layer via functional states.
- **Database exceptions:** Wrap all Hive reads/writes in `try-catch` catching `HiveError` and returning default fallback collections to prevent app crashes.

### 4.2 Logging Standards
- **Rule:** Avoid raw print statements (`print()`) in production code. Use `developer.log()` from `dart:developer`.
- **Formatting:** Log output format must prefix logs with the origin class: `[ClassName] Action Trigger: StatusDetails`.

---

## 5. Dependencies
- **package:flutter_lints:** Standard Dart lint rules.
- **package:riverpod:** State manager.

---

## 6. Acceptance Criteria
- Code passes static code analysis (`flutter analyze`) without warnings or errors.
- Variable and class name styles match the conventions defined in this document.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial draft defining code style conventions. |