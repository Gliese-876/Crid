package app.crid

import android.app.AlarmManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BackgroundRuntimeBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_MY_PACKAGE_REPLACED &&
            action != AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED
        ) {
            return
        }

        val enabled = context
            .getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_BACKGROUND_ENABLED, false)
        if (!enabled) {
            return
        }

        try {
            val serviceIntent = Intent(context, PersistentBackgroundService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        } catch (_: RuntimeException) {
            // Some Android versions and OEM builds can reject background starts.
        }
    }

    private companion object {
        const val PREFERENCES_NAME = "android_background_runtime"
        const val KEY_BACKGROUND_ENABLED = "background_enabled"
    }
}
