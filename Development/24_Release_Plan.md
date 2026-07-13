# 24 Release Plan

**Document ID:** 24_Release_Plan.md  
**Version:** 1.0  
**Status:** Approved  
**Owner:** Technical Lead  
**Last Updated:** July 2026  

---

## 1. Purpose
The purpose of this document is to specify the **Release and Deployment Plan** for LifeOS, detailing code signing, Gradle configurations, build profiles, and update distribution pathways.

---

## 2. Objectives
- Establish secure processes for building and signing release APKs locally.
- Detail the version-bump pipeline for app release iterations.
- Prevent release footprint bloat to maintain the APK budget ($< 50\text{MB}$).

---

## 3. Scope
This document covers Android keystores setup, build scripts configurations, APK distributions, and package version bumps. It excludes App Store or Play Console registration details as the app targets direct local APK installation.

---

## 4. Technical Specifications

### 4.1 Release Signing (Android Keystore)
- **Key Generation:** Locally generated key using `keytool` with AES/RSA.
- **Keystore Storage:** The keystore file (`release.keystore`) is ignored in Git (`.gitignore`) and stored locally on the secure developer build machine.
- **Credentials:** Stored as local environment variables during build execution:
```properties
# android/key.properties (local only)
storePassword=KEYSTORE_PASSWORD_ENV
keyPassword=KEY_PASSWORD_ENV
keyAlias=lifeos_key
storeFile=../release.keystore
```

### 4.2 Gradle Build Configurations
- **Build Variant:** Release config uses `minifyEnabled true` and `shrinkResources true` to strip unused code classes and asset files, helping hit the size budget.
- **Architecture Splits:** Build split APKs per CPU architecture to reduce download footprint:
```groovy
// android/app/build.gradle
android {
    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', 'arm64-v8a', 'x86_64'
            universalApk false
        }
    }
}
```

### 4.3 Version Increments
- **Format:** Version format is `vMajor.Minor.Patch+Build` (e.g. `v1.0.0+1`).
- Bumping version numbers must be updated inside `pubspec.yaml` before running release builds.

---

## 5. Workflows

### 5.1 Local APK compilation pipeline
1. Clean local caches: `flutter clean`
2. Fetch package dependencies: `flutter pub get`
3. Verify test coverage: `flutter test`
4. Compile release binaries: `flutter build apk --split-per-abi`
5. Retrieve outputs from `/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.
6. Verify size is $< 50\text{MB}$.

---

## 6. Dependencies
- **Technical/21_Security.md:** Security parameters.
- **Technical/Performance_Budget.md:** APK size budgets.

---

## 7. Acceptance Criteria
- Release builds sign successfully without compilation errors.
- Output APK installs and runs on clean Android virtual emulators without debug bridges.

---

## 8. Revision History
| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | July 13, 2026 | Antigravity | Initial detailed release build and compile specs. |