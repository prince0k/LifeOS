# 16 Backup System Technical Design

**Document ID:** 16_Backup_System.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the technical implementation details for file archiving, ZIP streams, key derivations, and safety cache rollbacks in the LifeOS **Backup System** (MOD-Settings).

---

## 2. Objectives
- Detail file stream utilities for packaging Hive database logs.
- Document key derivation interfaces derived from user passwords.
- Ensure import procedures protect against crash states and data corruption.

---

## 3. Scope
This document covers directory queries, compression classes, cryptography adapters, and restore checkpoints in Version 1.0. It excludes UI widgets, located in [08_UI_UX_Specification.md](file:///d:/LifeOS/Design/08_UI_UX_Specification.md).

---

## 4. Technical Architecture & Implementations

### 4.1 Compression & ZIP Streams
LifeOS utilizes the `archive` Dart package to compile database files:
- **Procedure:**
  1. Retrieve the path of the active Hive box binaries (`.hive` and `.lock` files).
  2. Instantiate an `Archive` object.
  3. Loop through files in the Hive directory, adding each as an `ArchiveFile` stream.
  4. Encode the directory using `ZipEncoder().encode()`.
  5. Write the resulting bytes to a temporary backup file.

### 4.2 Decryption & Key Derivation (PBKDF2)
- **Key Derivation Function:** `PBKDF2` from the `cryptography` package.
- **Salt:** Generates a random 128-bit salt per backup file.
- **Iterations:** 10,000 rounds using SHA-256.
- **Cipher Initialization:**
```dart
final pbkdf2 = Pbkdf2(
  macAlgorithm: Hmac(Sha256()),
  iterations: 10000,
  bits: 256,
);
final keyBytes = await pbkdf2.deriveKey(
  secretKey: SecretKey(userEnteredPassword.codeUnits),
  nonce: backupSaltBytes,
);
```

### 4.3 Recovery Safety Checkpoint
During database import, before any active files are overwritten:
1. Copy `/hive/` folder contents to `/hive_backup_temp/`.
2. Attempt write operations.
3. If Hive throws initialization errors, close active boxes, delete `/hive/` contents, copy `/hive_backup_temp/` back to `/hive/`, and reload.

---

## 5. Dependencies
- **package:archive:** For ZIP encoding and decoding.
- **package:cryptography:** PBKDF2 and AES-GCM primitives.

---

## 6. Acceptance Criteria
- ZIP encryption completes in under 2.0s for databases up to 20MB.
- Rollback mechanisms restore original states if encryption parameters fail during import.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial detailed compression and encryption code specs. |