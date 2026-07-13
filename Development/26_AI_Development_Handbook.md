# 26 AI Development Handbook

**Document ID:** 26_AI_Development_Handbook.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the rules, workflows, conventions, and hierarchies that the AI Development Agent (Antigravity/Gemini) must adhere to when writing code, making architectural decisions, or updating files in this repository.

---

## 2. Objectives
- Ensure that the LifeOS project philosophy is strictly maintained throughout all implementation phases.
- Establish clean coding, state, and database boundaries for modular development.
- Serve as a checklist to verify feature correctness prior to marking tasks complete.

---

## 3. Project Understanding
Before writing any code, the AI must understand that LifeOS is not a typical productivity application. LifeOS is an adaptive personal operating system that combines:
- Shift Management
- Adaptive Daily Planning
- Project Management
- Habit Tracking
- Recovery Management
- Health Tracking
- Deep Work
- Analytics
- Decision Support

The AI must preserve this philosophy throughout development.

---

## 4. Development Workflow
Every implementation task must follow this workflow:
1. Read all related documentation.
2. Identify Requirement IDs.
3. Identify Rule IDs.
4. Review dependencies.
5. Implement only the requested feature.
6. Write clean, modular code.
7. Verify functionality.
8. Update documentation if required.
9. Mark completed tasks.
10. Generate a summary of changes.

The AI must never skip documentation review.

---

## 5. Documentation Reading Order
Before implementing any feature, the AI must read documents in the following order:
1. Product Constitution
2. Product Vision
3. Master PRD
4. User Flows
5. Rules Engine
6. Information Architecture
7. UI/UX Specification
8. Database Design
9. Flutter Architecture
10. Coding Standards

If any document conflicts with another, the Product Constitution takes precedence.

---

## 6. Implementation Rules
The AI must never:
- Implement undocumented functionality.
- Rename Requirement IDs.
- Change business rules.
- Introduce paid services.
- Remove offline functionality.
- Create duplicate logic.
- Hardcode values that should be configurable.
- Ignore Recovery Mode.
- Ignore Shift Templates.

Every feature must remain modular.

---

## 7. Code Quality Standards
Every implementation must satisfy the following:
- Single Responsibility Principle
- Modular Architecture
- Reusable Components
- Strong Typing
- Null Safety
- Consistent Naming
- Minimal Dependencies
- Comprehensive Error Handling
- Readable Code
- Easy Testability

---

## 8. Folder Ownership
Each folder has a specific responsibility:
- `core/`: Shared application infrastructure.
- `features/`: Feature modules.
- `services/`: Business services.
- `models/`: Data models.
- `providers/`: Riverpod providers.
- `widgets/`: Reusable widgets.
- `database/`: Hive repositories and adapters.
- `notifications/`: Notification scheduling.
- `analytics/`: Analytics calculations.

The AI must respect these boundaries.

---

## 9. State Management Rules
- Riverpod is the only state management solution.
- Business logic must never exist inside widgets.
- Widgets display data only.
- Providers manage state.
- Services perform operations.
- Repositories manage persistence.

---

## 10. Database Rules
Hive is the primary database. The AI must:
- Never access Hive directly from UI widgets.
- Always use repositories.
- Never duplicate stored data.
- Support future migrations.
- Preserve backward compatibility.

---

## 11. UI Rules
- The UI must follow Material 3.
- Every screen must:
  - Support dark mode.
  - Support responsive layouts.
  - Maintain consistent spacing.
  - Follow Design System tokens.
  - Keep common actions within three taps.
- Animations should remain subtle.

---

## 12. Performance Requirements
Target performance:
- App launch <2 seconds.
- Database reads <50ms.
- Database writes <50ms.
- Smooth 60 FPS animations.
- Low battery usage.
- APK size below target.

The AI should prioritize performance over unnecessary visual complexity.

---

## 13. Testing Requirements
Every completed feature should include:
- Unit Tests
- Widget Tests (where applicable)
- Integration Tests (where applicable)

The AI should verify that all tests pass before marking work complete.

---

## 14. Error Handling
Every feature must gracefully handle:
- Missing data.
- Corrupted database entries.
- Permission denial.
- Invalid user input.
- Notification failures.
- Backup failures.

The application must never crash due to expected user actions.

---

## 15. AI Decision Hierarchy
When making implementation decisions, follow this priority:
1. Product Constitution
2. Product Vision
3. Master PRD
4. Rules Engine
5. Database Design
6. Flutter Architecture
7. Coding Standards

Lower-level documents must never override higher-level documents.

---

## 16. Completion Checklist
Before completing any task, verify:
- Documentation reviewed.
- Requirement IDs implemented.
- Rule IDs respected.
- Tests passing.
- No duplicate code.
- No architecture violations.
- Performance maintained.
- Documentation updated.
- Task status updated.

Only then may the task be considered complete.

---

## 17. AI Communication Rules
The AI should:
- Explain architectural decisions.
- Reference Requirement IDs in responses.
- Ask questions if requirements conflict.
- Never guess missing functionality.
- Clearly distinguish assumptions from documented requirements.
- Recommend improvements without changing approved specifications.

---

## 18. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial integration of the full AI Development Rules and hierarchies. |