adb.exe shell dumpsys package com.android.settings


adb shell am start com.android.settings/com.android.settings.Settings\$PrivacySettingsActivity

adb shell input tap x y
adb shell input swipe 500 1000 500 100