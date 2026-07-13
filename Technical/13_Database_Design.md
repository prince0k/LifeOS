# 13 Database Design

**Document ID:** 13_Database_Design.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the physical database schemas, Hive adapter properties, and storage key models of LifeOS. It serves as the master database reference for implementing persistence.

---

## 2. Database Paradigm (Hive NoSQL)
LifeOS utilizes **Hive** as its primary on-device database. Data is stored in lightweight, binary, key-value stores called "Boxes." To maintain the single source of truth, boxes are structured around discrete entity types.

---

## 3. Hive Box Schemas

### 3.1 Settings Box (Box Name: `settings_box`, TypeId: 1)
Stores app preferences and weights configuration.
- **Key:** `"user_config"`
- **Schema Model (`SettingsModel`):**
  - `shiftTemplates`: Map<String, ShiftTemplateModel>
  - `recoveryWeights`: Map<String, double> (keys: sleep, energy, stress, habits)
  - `selectedAppPackages`: List<String>
  - `unhealthyHabitCeiling`: int
  - `schemaVersion`: int

### 3.2 Recovery Log Box (Box Name: `recovery_log_box`, TypeId: 2)
Stores daily check-ins.
- **Key Format:** `"YYYY-MM-DD"`
- **Schema Model (`RecoveryModel`):**
  - `date`: String (ISO 8601 Date)
  - `sleepStartTime`: String (HH:MM)
  - `sleepEndTime`: String (HH:MM)
  - `nightWakeUps`: int
  - `sleepQuality`: int (1-4: Excellent=4, Good=3, Average=2, Poor=1)
  - `energyRating`: int (1-10)
  - `stressRating`: int (1-10)
  - `mood`: String
  - `checkedPhysicalActivities`: List<String>
  - `checkedMentalActivities`: List<String>
  - `computedRecoveryScore`: double (0-100)
  - `computedState`: String

### 3.3 Tasks Box (Box Name: `tasks_box`, TypeId: 3)
Stores user task backlog records.
- **Key:** UUID String
- **Schema Model (`TaskModel`):**
  - `id`: String
  - `projectId`: String (nullable)
  - `title`: String
  - `priority`: String (High, Medium, Low)
  - `isCompleted`: bool
  - `targetDate`: String (ISO Date)
  - `rolloverCount`: int
  - `completedTimestamp`: String (nullable)

### 3.4 Habits Log Box (Box Name: `habits_log_box`, TypeId: 4)
Tracks incremental and time-based habits.
- **Key Format:** `"YYYY-MM-DD"`
- **Schema Model (`HabitLogModel`):**
  - `date`: String (ISO Date)
  - `smokingCount`: int
  - `detailedSmokingLogs`: List<DetailedSmokingLogModel> (TypeId: 5)
    - `timestamp`: String
    - `trigger`: String
    - `mood`: String
    - `notes`: String
  - `totalScreenTimeMinutes`: int
  - `appScreenTimes`: Map<String, int> (keys: Instagram, YouTube, Chrome, WhatsApp)

### 3.5 Projects Box (Box Name: `projects_box`, TypeId: 6)
Tracks active project milestones and configurations.
- **Key:** String (e.g. `"mailing"`, `"cityhost"`)
- **Schema Model (`ProjectModel`):**
  - `id`: String
  - `name`: String
  - `description`: String
  - `weeklyTargetHours`: double
  - `creationTimestamp`: String

---

## 4. Dependencies
- **Technical/15_Local_Storage.md:** Local directories and compaction.
- **Product/02_Master_PRD/2.18_Data_Model_Overview.md:** Conceptual data relationships.

---

## 5. Acceptance Criteria
- All database schemas declare unique Hive TypeIds.
- Nullable fields are initialized with default values where necessary to prevent read crashes.

---

## 6. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial database schema models mapping. |