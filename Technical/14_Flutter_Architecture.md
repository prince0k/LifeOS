# 14 Flutter Architecture

**Document ID:** 14_Flutter_Architecture.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the **Software Architecture Pattern**, state propagation pipelines, and Riverpod provider scopes implemented in LifeOS.

---

## 2. Architecture Overview
LifeOS leverages Flutter with **Riverpod** for state management and dependency injection. The architecture follows a strict **Uni-directional Data Flow (UDF)**.

```text
[ Hive Local DB ] 
      ↑ (Persist mutations)
[ Riverpod Notifier Providers ] (Holds active immutable state)
      ↑ (Dispatches Actions)
[ Flutter View Widgets ] (Listens & rebuilds reactively)
```

---

## 3. Provider Scopes & State Lifecycle

### 3.1 Global Providers (`shared/providers/`)
- **`databaseProvider`:** Exposes the Hive database wrapper service, initialized asynchronously during app boot.
- **`settingsNotifierProvider`:** Manages the user's active preferences, recovery weights, and selected apps configurations.
- **`recoveryNotifierProvider`:** Holds computed Wellness variables, Recovery State, and Recovery Score for the current day.

### 3.2 Feature-Specific Providers (`features/`)
- **`plannerNotifierProvider`:** Subscribes to `settingsNotifierProvider` and `recoveryNotifierProvider` to compute the active day's timetable.
- **`tasksBacklogProvider`:** Queries the active tasks box. Maps tasks according to active project selection.
- **`habitsSyncProvider`:** Manages app screen time queries and quick logs increment commands.

---

## 4. State Immutability Rules
- Every state class must declare a `@freezed` annotation (code generation) to ensure fields are read-only:
```dart
@freezed
class TaskState with _$TaskState {
  const factory TaskState({
    required List<TaskModel> tasks,
    required bool isLoading,
    required String? errorMessage,
  }) = _TaskState;
}
```
- Mutating state must occur exclusively via creating copy instances (`state = state.copyWith(...)`).

---

## 5. Dependencies
- **Development/Project_Structure.md:** Features directory architecture.
- **package:flutter_riverpod:** Core state runner.

---

## 6. Acceptance Criteria
- Unit tests verify that dispatching action triggers update subscribers without circular loops.
- All provider definitions follow code generation patterns (`@riverpod`).

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial Flutter architecture and state rules mapping. |