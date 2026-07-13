# 17 Analytics Engine Technical Design

**Document ID:** 17_Analytics_Engine.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the technical implementation, database query aggregations, background execution models, and correlation algorithms that compose the **Analytics Engine** (MOD-Analytics) in LifeOS.

---

## 2. Objectives
- Compute Daily Consistency and Weekly Focus Scores without frame lag.
- Map wellness correlation matrices locally using standard math libraries.
- Standardize data retrieval from Hive logs.

---

## 3. Scope
This document covers data aggregations, Pearson Correlation equations code logic, and background Dart Isolates configuration. It excludes UI charting canvas definitions.

---

## 4. Technical Architecture & Calculations

### 4.1 Background Isolates (Performance Protection)
To comply with the frame render budgets ($\ge 60$ FPS), compiling records across multiple months is offloaded to background execution blocks:
- **Dart Isolates:** The UI dispatches an isolate spawning command (`Isolate.run()`) to calculate correlation indices and metrics aggregations, keeping the main Flutter rendering thread free.

### 4.2 Pearson Correlation Engine
The engine computes the correlation ($r$) between two variables (e.g. stress ratings vs. cigarette counts) using Dart double list arrays:
```dart
double calculatePearsonCorrelation(List<double> X, List<double> Y) {
  if (X.length != Y.length || X.isEmpty) return 0.0;
  
  double sumX = 0, sumY = 0, sumXY = 0;
  double sumX2 = 0, sumY2 = 0;
  int n = X.length;
  
  for (int i = 0; i < n; i++) {
    sumX += X[i];
    sumY += Y[i];
    sumXY += X[i] * Y[i];
    sumX2 += X[i] * X[i];
    sumY2 += Y[i] * Y[i];
  }
  
  double numerator = n * sumXY - sumX * sumY;
  double denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
  
  if (denominator == 0) return 0.0;
  return numerator / denominator;
}
```

### 4.3 App Screen Time Fetcher
Queries the native Android `UsageStatsManager` service locally, parses aggregated usage totals in minutes, and writes the results to `habits_log_box` on check-in cycles.

---

## 5. Dependencies
- **Technical/13_Database_Design.md:** DB schema.
- **dart:math & dart:isolate:** Core libraries.

---

## 6. Acceptance Criteria
- Running Pearson calculations on 365 daily logs executes in under 10ms.
- Running query pipelines on Usage Stats updates registers app times correctly.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial detailed math engine code layout. |