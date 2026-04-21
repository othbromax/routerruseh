# Route Rush — Signing & CI/CD Guide

## Overview

This project uses **GitHub Actions** to automatically build a **signed APK** and **AAB** on every push to `main` or `master`. The signing keystore is stored securely in GitHub Secrets and decoded at build time — it never exists in the repository.

---

## Quick Start (3 Steps)

### Step 1 — Generate the Keystore

Run the keystore generation script from the project root:

```bash
bash scripts/generate_keystore.sh
```

The script will prompt you for **company details only**:

| Prompt                  | Example           |
|-------------------------|-------------------|
| Company / Org Name      | Acme Corp         |
| Organisational Unit     | Mobile Dev        |
| City / Locality         | Berlin            |
| State / Province        | Berlin            |
| Country Code (2-letter) | DE                |
| Key Alias               | upload            |
| Keystore Password       | *(you choose)*    |
| Key Password            | *(you choose)*    |

> **Privacy guarantee:** The script does **not** read any system information — no hostname, no username, no IP address, no MAC address, no location data. Every value comes from what you type.

After generation, the script prints a **base64-encoded keystore** and the exact values to save.

### Step 2 — Save GitHub Secrets

Go to the company's GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

Create these 4 secrets:

| Secret Name          | Value                                    |
|----------------------|------------------------------------------|
| `KEYSTORE_BASE64`    | The base64 string the script printed     |
| `KEYSTORE_PASSWORD`  | The keystore password you entered        |
| `KEY_ALIAS`          | The key alias you entered                |
| `KEY_PASSWORD`       | The key password you entered             |

### Step 3 — Push Code

Push to `main` or `master`. GitHub Actions will:

1. Check out the code
2. Set up Java 17 and Flutter (stable)
3. Decode the keystore from `KEYSTORE_BASE64`
4. Create a temporary `key.properties` file
5. Build a **release-signed APK**
6. Build a **release-signed AAB**
7. Verify the artifacts are release-signed (not debug)
8. Upload both as downloadable **workflow artifacts**
9. Delete the keystore and credentials from the runner

Download the APK and AAB from the **Actions** tab → select the workflow run → **Artifacts** section.

---

## Security Details

| Concern                  | How it's handled                                             |
|--------------------------|--------------------------------------------------------------|
| Keystore in repo         | `.gitignore` excludes `*.jks`, `*.keystore`, `key.properties`|
| Secrets in logs          | GitHub auto-masks `${{ secrets.* }}` values in logs          |
| Keystore on runner       | Decoded to temp file, deleted in `always()` cleanup step     |
| Debug signing fallback   | **Disabled.** Release builds require `key.properties` or produce unsigned output |
| Personal data in script  | Script prompts only for company info; reads zero system data |
| Personal data in push    | `.gitignore` excludes `local.properties`, `.idea/`, `.dart_tool/`, and all build artifacts |

---

## File Reference

| File                                        | Purpose                                              |
|---------------------------------------------|------------------------------------------------------|
| `.github/workflows/build-android.yml`       | GitHub Actions workflow for signed APK + AAB         |
| `scripts/generate_keystore.sh`              | Keystore generation script (company prompts only)    |
| `android/app/build.gradle.kts`              | Gradle build config with release signing + R8        |
| `android/app/proguard-rules.pro`            | ProGuard/R8 rules (Play Core dontwarn)               |
| `.gitignore`                                | Excludes keystores, secrets, build outputs, IDE data |

---

## ProGuard / R8 Notes

The release build enables R8 code shrinking (`isMinifyEnabled = true`). Flutter's deferred-components support references Google Play Core classes that are not bundled in this app. The `proguard-rules.pro` file contains `-dontwarn` rules for all affected classes so R8 completes without errors. This is safe because the app does not use deferred components at runtime.

---

## Troubleshooting

**Build fails with "null cannot be cast to non-null type String"**
→ `key.properties` is missing or incomplete. Verify all 4 GitHub Secrets are set.

**APK/AAB is unsigned**
→ `key.properties` was not found. Check the "Decode keystore" and "Create key.properties" steps in the workflow log.

**R8 fails with "Missing class com.google.android.play.core..."**
→ Ensure `android/app/proguard-rules.pro` exists and is referenced in `build.gradle.kts`.

**"keytool not found" when running the script**
→ Install a Java JDK (17+) and add it to your PATH.
