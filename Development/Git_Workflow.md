# Git Workflow

**Document ID:** Git_Workflow.md  
**Version:** 1.0  
**Status:** In Progress  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the **Git Workflows**, branching strategies, commit conventions, and release management rules for the LifeOS codebase.

---

## 2. Branching Strategy
LifeOS utilizes a simplified Git Flow architecture:
- **`main`:** Stable release branch. Every commit on main must compile successfully, pass all automated tests, and map to a tag.
- **`dev`:** Active development branch. Feature branches merge here after code review.
- **`feature/feature-name`:** Short-lived branches for implementing specific PRD modules (e.g. `feature/screen-time-sync`). Branches must map to a Requirement ID.

---

## 3. Commit Convention
LifeOS enforces **Conventional Commits 1.0.0** to ensure a clean, automated changelog:
- **Format:** `<type>(<scope>): <subject>`
- **Types:**
  - `feat`: A new user-facing feature.
  - `fix`: A bug fix.
  - `docs`: Documentation-only changes.
  - `style`: Code formatting changes (whitespaces, semi-colons).
  - `refactor`: Code changes that neither fix bugs nor add features.
  - `test`: Adding or correcting tests.
  - `chore`: Update build configurations or package dependencies.
- **Example:** `feat(habits): implement Android Usage Stats API integration REQ-HABIT-002`

---

## 4. Pull Request & Release Rules
- **Code Review:** Every PR merging into `dev` requires review and passing static lint checks.
- **Release Versioning:** Follows **Semantic Versioning 2.0.0** ($MAJOR.MINOR.PATCH$).
- **Git Tags:** Release builds must be tagged on the `main` branch:
  - Format: `vX.Y.Z` (e.g. `v1.0.0`).

---

## 5. Dependencies
- **28_Changelog.md:** Target file populated by Conventional Commits.

---

## 6. Acceptance Criteria
- Release builds match tags exactly.
- Branch structures follow feature prefixes.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial draft detailing branch flows and commit syntax. |
