package app.crid

import android.Manifest
import android.app.AlarmManager
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class AndroidBackgroundBridge(
    private val activity: FlutterActivity,
) : MethodChannel.MethodCallHandler {
    private val context: Context = activity.applicationContext
    private val preferences =
        context.getSharedPreferences("android_background_runtime", Context.MODE_PRIVATE)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "getStatus" -> result.success(status())
                "setPersistentBackgroundEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setPersistentBackgroundEnabled(enabled)
                    result.success(status())
                }
                "openNotificationSettings" -> {
                    openNotificationSettings()
                    result.success(null)
                }
                "openBatteryOptimizationSettings" -> {
                    openBatteryOptimizationSettings()
                    result.success(null)
                }
                "openExactAlarmSettings" -> {
                    openExactAlarmSettings()
                    result.success(null)
                }
                "openAutoStartSettings" -> {
                    openAutoStartSettings()
                    result.success(null)
                }
                "requestIgnoreBatteryOptimizations" -> {
                    requestIgnoreBatteryOptimizations()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error("ANDROID_BACKGROUND_ERROR", error.message, null)
        }
    }

    private fun status(): Map<String, Any?> {
        val enabled = preferences.getBoolean(KEY_BACKGROUND_ENABLED, false)
        if (enabled && !PersistentBackgroundService.isRunning) {
            try {
                startPersistentBackgroundService()
            } catch (_: RuntimeException) {
                // Status should remain readable if the system rejects a restart.
            }
        }
        return mapOf(
            "available" to true,
            "manufacturer" to Build.MANUFACTURER.orEmpty(),
            "brand" to Build.BRAND.orEmpty(),
            "model" to Build.MODEL.orEmpty(),
            "androidRelease" to Build.VERSION.RELEASE.orEmpty(),
            "sdkInt" to Build.VERSION.SDK_INT,
            "notificationsAllowed" to notificationsAllowed(),
            "exactAlarmsAllowed" to canScheduleExactAlarms(),
            "batteryOptimizationIgnored" to isIgnoringBatteryOptimizations(),
            "persistentBackgroundEnabled" to enabled,
            "persistentBackgroundRunning" to PersistentBackgroundService.isRunning,
        )
    }

    private fun setPersistentBackgroundEnabled(enabled: Boolean) {
        preferences.edit().putBoolean(KEY_BACKGROUND_ENABLED, enabled).apply()
        if (enabled) {
            startPersistentBackgroundService()
        } else {
            context.stopService(Intent(context, PersistentBackgroundService::class.java))
        }
    }

    private fun startPersistentBackgroundService() {
        val intent = Intent(context, PersistentBackgroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }

    private fun openNotificationSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(
                Settings.EXTRA_APP_PACKAGE,
                context.packageName,
            )
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(
                Uri.parse("package:${context.packageName}"),
            )
        }
        startSettingsActivity(intent)
    }

    private fun openBatteryOptimizationSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(
                Uri.parse("package:${context.packageName}"),
            )
        }
        startSettingsActivity(intent)
    }

    private fun openExactAlarmSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).setData(
                Uri.parse("package:${context.packageName}"),
            )
        } else {
            appDetailsIntent()
        }
        startSettingsActivity(intent)
    }

    private fun openAutoStartSettings() {
        for (intent in manufacturerBackgroundSettingsIntents()) {
            if (tryStartActivity(intent)) {
                return
            }
        }
        openBatteryOptimizationSettings()
    }

    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || isIgnoringBatteryOptimizations()) {
            return
        }
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).setData(
            Uri.parse("package:${context.packageName}"),
        )
        startSettingsActivity(intent)
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true
        }
        val powerManager = context.getSystemService(PowerManager::class.java)
        return powerManager.isIgnoringBatteryOptimizations(context.packageName)
    }

    private fun notificationsAllowed(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return true
        }
        return context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun canScheduleExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return true
        }
        val alarmManager = context.getSystemService(AlarmManager::class.java)
        return alarmManager.canScheduleExactAlarms()
    }

    private fun startSettingsActivity(intent: Intent) {
        if (!tryStartActivity(intent)) {
            tryStartActivity(appDetailsIntent())
        }
    }

    private fun tryStartActivity(intent: Intent): Boolean {
        return try {
            activity.startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        } catch (_: SecurityException) {
            false
        }
    }

    private fun appDetailsIntent(): Intent {
        return Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(
            Uri.parse("package:${context.packageName}"),
        )
    }

    private fun manufacturerBackgroundSettingsIntents(): List<Intent> {
        val manufacturer = Build.MANUFACTURER.orEmpty().lowercase(Locale.ROOT)
        val brand = Build.BRAND.orEmpty().lowercase(Locale.ROOT)
        val packageName = context.packageName
        val candidates = mutableListOf<Intent>()

        fun add(packageName: String, className: String) {
            candidates += Intent().setComponent(ComponentName(packageName, className))
        }

        if ("xiaomi" in manufacturer || "redmi" in brand || "poco" in brand) {
            add(
                "com.miui.securitycenter",
                "com.miui.permcenter.autostart.AutoStartManagementActivity",
            )
            add(
                "com.miui.securitycenter",
                "com.miui.powercenter.PowerSettings",
            )
        }
        if ("huawei" in manufacturer || "honor" in manufacturer || "honor" in brand) {
            add(
                "com.huawei.systemmanager",
                "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
            )
            add(
                "com.huawei.systemmanager",
                "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity",
            )
        }
        if ("oppo" in manufacturer || "realme" in manufacturer || "oneplus" in manufacturer) {
            add(
                "com.coloros.safecenter",
                "com.coloros.safecenter.startupapp.StartupAppListActivity",
            )
            add(
                "com.oplus.safecenter",
                "com.oplus.safecenter.permission.startup.StartupAppListActivity",
            )
        }
        if ("vivo" in manufacturer || "iqoo" in manufacturer) {
            add("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity")
            add("com.iqoo.secure", "com.iqoo.secure.safeguard.PurviewTabActivity")
        }
        if ("meizu" in manufacturer) {
            add("com.meizu.safe", "com.meizu.safe.permission.SmartBGActivity")
        }
        if ("samsung" in manufacturer) {
            add("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity")
        }

        candidates += Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(
            Uri.parse("package:$packageName"),
        )
        return candidates
    }

    companion object {
        private const val KEY_BACKGROUND_ENABLED = "background_enabled"
    }
}
