adb.exe shell dumpsys package com.android.settings


adb shell am start com.android.settings/com.android.settings.Settings\$PrivacySettingsActivity

adb shell input tap x y
adb shell input swipe 500 1000 500 100

change to english please

get admin by command - adb -s XXXXXXXX shell dpm set-device-owner com.futuredial.fdbox721/.fdbox721Receiver
shell pm grant com.futuredial.fdbox721 android.permission.CHANGE_CONFIGURATION
shell pm grant com.futuredial.fdbox721 android.permission.CHANGE_CONFIGURATION

shell settings put secure install_non_market_apps 1

adb shell am broadcast -a fdSyncReceiver.setLanguage -n com.futuredial.fdbox721/.fdSyncReceiver --es language en_US

shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task GetInfo --es result phoneinfo.txt
file: /data/data/com.futuredial.fdbox721/files/phoneinfo.txt, 

shell settings list secure

shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es result runapk.txt
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task Clean --es result clean.txt
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task flight --es result airline_disable.txt --ez enable false
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task get_screen_timeout_list --es result timeoutlist.txt
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task set_screen_timeout --es result timeout.txt --ei timeout 600000
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task turn_screen_on --es result turn_on.txt
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task unlock_screen --es result unlockscreen.txt
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task rotation --es result rotation.txt --ez enable false
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task set_screen_orientation --es result orientation.txt --ei value 1
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task format --es result formatsd.txt
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task WipeData --es result wipedata.txt
shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task RemoveAdmin --es result removeadmin.txt
