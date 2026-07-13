# 15 Local Storage

**Document ID:** 15_Local_Storage.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the **Local Storage Configuration**, caching guidelines, data folders, box compaction triggers, and encryption parameters for Hive in LifeOS.

---

## 2. Directory Structure & Paths
LifeOS restricts all file writes to the application's secure sandboxed storage. On Android:
- **Root Path:** `getApplicationDocumentsDirectory()` from the `path_provider` package.
  - Resolves to: `/data/user/0/com.lifeos.app/app_flutter/`
- **Hive Folder:** `/data/user/0/com.lifeos.app/app_flutter/hive/`
- **Backups Folder:** `/data/user/0/com.lifeos.app/app_flutter/backups/`

---

## 3. Storage Optimization & Compaction

#### RULE-STORAGE-001: Automatic Box Compaction
Hive database files grow continuously unless compaction is run. LifeOS registers compaction routines upon database initialization:
- **Compaction Trigger:** Run auto-compaction when database boxes are opened, if the file size has grown by more than $30\%$ AND has at least 50 deleted/overwritten entries.
```dart
Hive.openBox<TaskModel>(
  'tasks_box',
  compactionStrategy: (entries, deletedEntries) {
    return deletedEntries > 50 && (deletedEntries / entries) > 0.3;
  },
);
```

---

## 4. Encryption Layer
- **Secure Boxes:** Boxes containing sensitive entries (e.g. `journal_box` and `recovery_log_box`) require encryption.
- **Key Generation:** Generates a 256-bit encryption key on launch using `Hive.generateSecureKey()`. The key is saved securely in the hardware Keystore/Keychain using the `flutter_secure_storage` package.
- **Access Pipeline:** Key is retrieved during boot initialization, decrypted, and passed to open the secure boxes:
```dart
final encryptionKey = await secureStorage.read(key: 'hive_key');
final secureBox = await Hive.openBox('journal_box', encryptionCipher: HiveAesCipher(encryptionKey));
```

---

## 5. Dependencies
- **Technical/21_Security.md:** Security keys lifecycle.
- **package:path_provider:** Native directories manager.

---

## 6. Acceptance Criteria
- Database compaction runs successfully without blocking the main rendering frame.
- Unencrypted reads are blocked on secure boxes if encryption keys are absent.

---

## 7. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial storage paths and compaction rules mapping. |