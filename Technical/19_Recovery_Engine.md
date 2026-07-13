# 19 Recovery Engine Technical Design

**Document ID:** 19_Recovery_Engine.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the technical implementation details, calculation scripts, and state-machine transitions that compose the **Recovery Engine** (MOD-Recovery) in LifeOS.

---

## 2. Objectives
- Codify the recovery score formula and its weight preferences.
- Implement the user state machine and the burnout escalation rule.
- Standardize manual check-in verification loops.

---

## 3. Scope
This document covers computational logic, state assignments, and historical score evaluations. It excludes visual check-in sliders, located in [08_UI_UX_Specification.md](file:///d:/LifeOS/Design/08_UI_UX_Specification.md).

---

## 4. Technical Specifications

### 4.1 Daily Score Computations
Upon check-in completion, the engine retrieves settings weights and calculates components:
- **Sleep Duration ($SD$):**
```dart
double calculateSleepDuration(String start, String end, int wakeUps) {
  final startTime = DateTime.parse('2026-07-13T$start:00');
  var endTime = DateTime.parse('2026-07-13T$end:00');
  if (endTime.isBefore(startTime)) {
    endTime = endTime.add(const Duration(days: 1));
  }
  final difference = endTime.difference(startTime);
  final totalMinutes = difference.inMinutes - (wakeUps * 15);
  return totalMinutes / 60.0;
}
```

### 4.2 State Machine & Burnout Check
The engine runs the check-in script:
1. Calculates Recovery Score ($RS$) via `RULE-RECOVERY-002`.
2. Queries the last 2 days' scores from `recovery_log_box`.
3. Checks `RULE-RECOVERY-003` (Burnout Risk):
```dart
RecoveryState evaluateState(double currentScore, List<double> pastScores) {
  if (pastScores.length >= 2 && currentScore < 50 && pastScores[0] < 50 && pastScores[1] < 50) {
    return RecoveryState.burnoutRisk;
  }
  if (currentScore < 40) return RecoveryState.burnoutRisk;
  if (currentScore < 50) return RecoveryState.recoveryNeeded;
  if (currentScore < 60) return RecoveryState.lowRecovery;
  if (currentScore < 70) return RecoveryState.moderateRecovery;
  if (currentScore < 80) return RecoveryState.goodRecovery;
  return RecoveryState.fullyRecovered;
}
```

---

## 5. Dependencies
- **Product/02_Master_PRD/2.4_User_States.md:** User states specifications.
- **Technical/13_Database_Design.md:** DB models.

---

## 6. Acceptance Criteria
- Sleep duration math computes correctly for sleep spanning midnight boundaries.
- Burnout risk state activates if score is under 50 for three consecutive days.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial detailed recovery engine transition schemas. |