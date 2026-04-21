# ============================================================================
# Route Rush — ProGuard / R8 Rules
# ============================================================================
#
# Flutter's deferred-components support references Google Play Core classes.
# If the app does NOT use deferred components (dynamic feature modules) and
# does NOT bundle the Play Core library, R8 will fail because it cannot
# resolve those classes.
#
# The -dontwarn rules below tell R8 to silently ignore the missing classes.
# This is safe because the deferred-components code path is never executed
# at runtime in this app.
# ============================================================================

# --- Google Play Core: Split Install (deferred components) -----------------
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.splitinstall.model.SplitInstallSessionStatus

# --- Google Play Core: Tasks ----------------------------------------------
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# --- Google Play Core: Common / Review / App Update ------------------------
-dontwarn com.google.android.play.core.common.PlayCoreDialogWrapperActivity
-dontwarn com.google.android.play.core.review.ReviewManager
-dontwarn com.google.android.play.core.review.ReviewManagerFactory
-dontwarn com.google.android.play.core.review.ReviewInfo
-dontwarn com.google.android.play.core.appupdate.AppUpdateManager
-dontwarn com.google.android.play.core.appupdate.AppUpdateManagerFactory
-dontwarn com.google.android.play.core.appupdate.AppUpdateInfo
-dontwarn com.google.android.play.core.install.InstallStateUpdatedListener
-dontwarn com.google.android.play.core.install.model.AppUpdateType
-dontwarn com.google.android.play.core.install.model.InstallStatus
-dontwarn com.google.android.play.core.install.model.UpdateAvailability
